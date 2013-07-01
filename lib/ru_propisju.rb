require 'i18n'

module I18nInitialization
  extend self

  def init
    I18n.load_path.unshift *locale_files
  end

  def locale_files
    Dir[File.join(File.dirname(__FILE__), 'locales', '**/*')]
  end
end

I18nInitialization.init

# Самый лучший, прекрасный, кривой и неотразимый суперпечататель суммы прописью для Ruby.
#
#   RuPropisju.rublej(123) # "сто двадцать три рубля"
module RuPropisju

  VERSION = '1.1.1'

  def t(s)
    I18n.t("propisju.#{s}")
  end

  def t_decimals
    t("decimals").
      map{|e| [e, e.gsub(/ая$/, "ых").gsub(/th$/, "ths"), e.gsub(/ая$/, "ых").gsub(/th$/, "ths"), ]}.
      freeze
  end

  # Выбирает нужный падеж существительного в зависимости от числа
  #
  #   choose_plural(3, "штука", "штуки", "штук") #=> "штуки"
  def choose_plural(amount, *variants)
    mod_ten = amount % 10
    mod_hundred = amount % 100
    variant = if (mod_ten == 1 && mod_hundred != 11)
        1
    else
      if mod_ten >= 2 && mod_ten <= 4 && (mod_hundred <10 || mod_hundred % 100>=20)
        2
      else
        3
      end
    end
    variants[variant-1]
  end


  # Выводит целое или дробное число как сумму в рублях прописью
  #
  #   rublej(345.2) #=> "триста сорок пять рублей 20 копеек"
  def rublej(amount)
    pts = []

    pts << propisju_shtuk(amount.to_i, *t('money.rur')) unless amount.to_i == 0

    if amount.kind_of?(Float)
      remainder = (amount.divmod(1)[1]*100).round
      if (remainder == 100)
        pts = [propisju_shtuk(amount.to_i+1, *t('money.rur'))]
      else
        kop = remainder.to_i
        unless kop.zero?
          pts << kop << choose_plural(kop, *t('money.kop'))
        end
      end
    end

    pts.join(' ')
  end

  # Выбирает корректный вариант числительного в зависимости от рода и числа и оформляет сумму прописью
  #
  #   propisju(243) => "двести сорок три"
  #   propisju(221, 2) => "двести двадцать одна"
  def propisju(amount, gender = 1)
    if amount.is_a?(Integer) || amount.is_a?(Bignum)
      propisju_int(amount, nil, nil, nil, gender)
    else # также сработает для Decimal, дробные десятичные числительные в долях поэтому женского рода
      propisju_float(amount)
    end
  end

  # Выводит целое или дробное число как сумму в гривнах прописью
  #
  #  griven(32) #=> "тридцать две гривны"
  def griven(amount)
    pts = []

    pts << propisju_int(amount.to_i, *t('money.uah'), 2) unless amount.to_i == 0
    if amount.kind_of?(Float)
      remainder = (amount.divmod(1)[1]*100).round
      if (remainder == 100)
        pts = [propisju_int(amount.to_i + 1, *t('money.uah'), 2)]
      else
        pts << propisju_int(remainder.to_i, *t('money.kop'), 2)
      end
    end

    pts.join(' ')
  end

  # Выводит сумму прописью в рублях по количеству копеек
  #
  #  kopeek(343) #=> "три рубля 43 копейки"
  def kopeek(amount)
    rublej(amount / 100.0)
  end

  # Выводит сумму данного существительного прописью и выбирает правильное число и падеж
  #
  #    RuPropisju.propisju_shtuk(21, "колесо", "колеса", "колес", 3) #=> "двадцать одно колесо"
  #    RuPropisju.propisju_shtuk(21, "мужик", "мужика", "мужиков", 1) #=> "двадцать один мужик"
  def propisju_shtuk(items, one, few, many, gender = 1)
    r = if items == items.to_i
      [propisju(items, gender), choose_plural(items, one, few, many)]
    else
      [propisju(items, gender), few]
    end

    r.join(" ")
  end

  private

  def compose_ordinal(into, remaining_amount, one_item='', few_items='', many_items='', gender = 1)
    rest, rest1, chosen_ordinal, ones, tens, hundreds = [nil]*6
    #
    many_items ||= ''
    rest = remaining_amount % 1000
    remaining_amount = remaining_amount / 1000
    if rest == 0
      # последние три знака нулевые
      into = many_items + " " if into == ""
      return [into, remaining_amount]
    end

    # сотни
    hundreds = t('hundreds')[rest / 100]

    # десятки
    rest = rest % 100
    rest1 = rest / 10
    ones = ""
    tens = 1 == rest1 ? t('teens')[rest-10] : t('tens')[rest1]

    unit = rest % 10

    # единицы
    ones = (rest1 < 1 or rest1 > 1) ? t('units')[gender-1][unit] : ''

    chosen_ordinal = if unit == 1
      one_item
    elsif (2..4).include?(unit) && !(12..14).include?(rest)
      few_items
    else
      many_items
    end

    plural = [hundreds, tens, ones, chosen_ordinal,  " ",  into].join(' ').squeeze(' ').strip
    return [plural, remaining_amount]
  end

  # Выдает сумму прописью с учетом дробной доли. Дробная доля округляется до миллионной, или (если
  # дробная доля оканчивается на нули) до ближайшей доли ( 500 тысячных округляется до 5 десятых).
  # Дополнительный аргумент - род существительного (1 - мужской, 2- женский, 3-средний)
  def propisju_float(num, gender = 2)

    # Укорачиваем до триллионной доли
    formatted = ("%0.#{t_decimals.length}f" % num).gsub(/0+$/, '')
    wholes, decimals = formatted.split(/\./)

    return propisju_int(wholes.to_i) if decimals.to_i.zero?

    whole_st = propisju_shtuk(wholes.to_i, *t_decimals[0], gender)

    rem_st = propisju_shtuk(decimals.to_i, *t_decimals[decimals.length], gender)
    [whole_st, rem_st].compact.join(" ")
  end

  # Выполняет преобразование числа из цифрого вида в символьное
  #
  #   amount - числительное
  #   gender   = 1 - мужской, = 2 - женский, = 3 - средний
  #   one_item - именительный падеж единственного числа (= 1)
  #   few_items - родительный падеж единственного числа (= 2-4)
  #   many_items - родительный падеж множественного числа ( = 5-10)
  #
  # Примерно так:
  #   propisju(42, "сволочь", "сволочи", "сволочей", 1) # => "сорок две сволочи"
  def propisju_int(amount, one_item = '', few_items = '', many_items = '', gender = 1)

    return t('zero') + many_items if amount.zero?

    # единицы
    into, remaining_amount = compose_ordinal('', amount, one_item, few_items, many_items, gender)

    return into if remaining_amount == 0

    # тысячи
    into, remaining_amount = compose_ordinal(into, remaining_amount, *t('orders.t'), 2)

    return into if remaining_amount == 0

    # миллионы
    into, remaining_amount = compose_ordinal(into, remaining_amount, *t('orders.m'))

    return into if remaining_amount == 0

    # миллиарды
    into, remaining_amount = compose_ordinal(into, remaining_amount, *t('orders.b'), 2)
    return into
  end

  alias_method :rublja, :rublej
  alias_method :rubl, :rublej

  alias_method :kopeika, :kopeek
  alias_method :kopeiki, :kopeek

  alias_method :grivna, :griven
  alias_method :grivny, :griven


  public_instance_methods(true).map{|m| module_function(m) }

  module_function :propisju_int, :propisju_float, :compose_ordinal
end
