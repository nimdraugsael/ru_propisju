# -*- encoding: utf-8 -*-
$KCODE = 'u' if RUBY_VERSION < '1.9.0'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require "test/unit"
require "ru_propisju"

class TestRuPropisju < Test::Unit::TestCase

  def test_propisju_for_ints
    I18n.with_locale(:ru) do
      assert_equal "пятьсот двадцать три", RuPropisju.propisju(523)
      assert_equal "шесть тысяч семьсот двадцать семь", RuPropisju.propisju(6727)
      assert_equal "восемь миллионов шестьсот пятьдесят два", RuPropisju.propisju(8000652, 1)
      assert_equal "восемь миллионов шестьсот пятьдесят две", RuPropisju.propisju(8000652, 2)
      assert_equal "восемь миллионов шестьсот пятьдесят два", RuPropisju.propisju(8000652, 3)
      assert_equal "сорок пять", RuPropisju.propisju(45)
      assert_equal "пять", RuPropisju.propisju(5)
      assert_equal "шестьсот двенадцать", RuPropisju.propisju(612)
    end

    I18n.with_locale(:en) do
      assert_equal "five hundred twenty three", RuPropisju.propisju(523)
      assert_equal "six thousands seven hundred twenty seven", RuPropisju.propisju(6727)
      assert_equal "eight millions six hundred fifty two", RuPropisju.propisju(8000652, 1)
      assert_equal "eight millions six hundred fifty two", RuPropisju.propisju(8000652, 2)
      assert_equal "eight millions six hundred fifty two", RuPropisju.propisju(8000652, 3)
      assert_equal "fourty five", RuPropisju.propisju(45)
      assert_equal "five", RuPropisju.propisju(5)
      assert_equal "six hundred twelve", RuPropisju.propisju(612)
    end
  end

  def test_propisju_shtuk
    I18n.with_locale(:ru) do
      assert_equal "шесть целых", RuPropisju.propisju_shtuk(6, "целая", "целых", "целых", 2)
      assert_equal "двадцать пять колес", RuPropisju.propisju_shtuk(25, "колесо", "колеса", "колес", 3)
      assert_equal "двадцать одна подстава", RuPropisju.propisju_shtuk(21, "подстава", "подставы", "подстав", 2)
      assert_equal "двести двенадцать сволочей", RuPropisju.propisju_shtuk(212.00, "сволочь", "сволочи", "сволочей", 2)
      assert_equal "двести двенадцать целых четыре десятых куска", RuPropisju.propisju_shtuk(212.40, "кусок", "куска", "кусков", 1)
    end

    I18n.with_locale(:en) do
      assert_equal "six pieces", RuPropisju.propisju_shtuk(6, "piece", "pieces", "pieces", 2)
      assert_equal "twenty five wheels", RuPropisju.propisju_shtuk(25, "wheel", "wheels", "wheels", 3)
      assert_equal "twenty one star", RuPropisju.propisju_shtuk(21, "star", "stars", "stars", 2)
      assert_equal "two hundred twelve bastards", RuPropisju.propisju_shtuk(212.00, "bastard", "bastards", "bastards", 2)
      assert_equal "two hundred twelve and four tenths litres", RuPropisju.propisju_shtuk(212.40, "litre", "litres", "litres", 1)
    end
  end

  def test_propisju_for_floats
    I18n.with_locale(:ru) do
      assert_equal "шесть целых пять десятых", RuPropisju.propisju(6.50)
      assert_equal "триста сорок одна целая девять десятых", RuPropisju.propisju(341.9)
      assert_equal "триста сорок одна целая двести сорок пять тысячных", RuPropisju.propisju(341.245)
      assert_equal "двести три целых сорок одна сотая", RuPropisju.propisju(203.41)
      assert_equal "четыреста сорок две целых пять десятых", RuPropisju.propisju(442.50000)
      assert_equal "двенадцать тысяч триста сорок пять целых шестьсот семьдесят восемь тысячных", RuPropisju.propisju(12345.678)
    end

    I18n.with_locale(:en) do
      assert_equal "six and five tenths", RuPropisju.propisju(6.50)
      assert_equal "three hundred fourty one and nine tenths", RuPropisju.propisju(341.9)
      assert_equal "three hundred fourty one and two hundred fourty five thousandths", RuPropisju.propisju(341.245)
      assert_equal "two hundred three and fourty one hundredth", RuPropisju.propisju(203.41)
      assert_equal "four hundred fourty two and five tenths", RuPropisju.propisju(442.50000)
      assert_equal "twelve thousands three hundred fourty five and six hundred seventy eight thousandths", RuPropisju.propisju(12345.678)
    end
  end

  def test_choose_plural
    I18n.with_locale(:ru) do
      assert_equal "чемодана", RuPropisju.choose_plural(523, "чемодан", "чемодана", "чемоданов")
      assert_equal "партий", RuPropisju.choose_plural(6727, "партия", "партии", "партий")
      assert_equal "козлов", RuPropisju.choose_plural(45, "козел", "козла", "козлов")
      assert_equal "колес", RuPropisju.choose_plural(260, "колесо", "колеса", "колес")
    end

    I18n.with_locale(:en) do
      assert_equal "bags", RuPropisju.choose_plural(523, "bag", "bags", "bags")
      assert_equal "flocks", RuPropisju.choose_plural(6727, "flock", "flocks", "flocks")
      assert_equal "goats", RuPropisju.choose_plural(45, "goat", "goats", "goats")
      assert_equal "wheels", RuPropisju.choose_plural(260, "wheel", "wheels", "wheels")
    end
  end

  def test_rublej
    I18n.with_locale(:ru) do
      assert_equal "сто двадцать три рубля", RuPropisju.rublej(123)
      assert_equal "триста сорок три рубля 20 копеек", RuPropisju.rublej(343.20)
      assert_equal "42 копейки", RuPropisju.rublej(0.4187)
      assert_equal "триста тридцать два рубля", RuPropisju.rublej(331.995)
      assert_equal "один рубль", RuPropisju.rubl(1)
      assert_equal "три рубля 14 копеек", RuPropisju.rublja(3.14)
      assert_equal "одна тысяча рублей", RuPropisju.rublej(1000)
    end

    I18n.with_locale(:en) do
      assert_equal "one hundred twenty three roubles", RuPropisju.rublej(123)
      assert_equal "three hundred fourty three roubles 20 kopecks", RuPropisju.rublej(343.20)
      assert_equal "42 kopecks", RuPropisju.rublej(0.4187)
      assert_equal "three hundred thirty two roubles", RuPropisju.rublej(331.995)
      assert_equal "one rouble", RuPropisju.rubl(1)
      assert_equal "three roubles 14 kopecks", RuPropisju.rublja(3.14)
    end
  end

  def test_griven
    I18n.with_locale(:ru) do
      assert_equal "сто двадцать три гривны", RuPropisju.griven(123)
      assert_equal "сто двадцать четыре гривны", RuPropisju.griven(124)
      assert_equal "триста сорок три гривны двадцать копеек", RuPropisju.griven(343.20)
      assert_equal "сорок две копейки", RuPropisju.griven(0.4187)
      assert_equal "триста тридцать две гривны", RuPropisju.griven(331.995)
      assert_equal "одна гривна", RuPropisju.grivna(1)
      assert_equal "три гривны четырнадцать копеек", RuPropisju.grivny(3.14)
    end

    I18n.with_locale(:en) do
      assert_equal "one hundred twenty three hryvnas", RuPropisju.griven(123)
      assert_equal "one hundred twenty four hryvnas", RuPropisju.griven(124)
      assert_equal "three hundred fourty three hryvnas twenty kopecks", RuPropisju.griven(343.20)
      assert_equal "fourty two kopecks", RuPropisju.griven(0.4187)
      assert_equal "three hundred thirty two hryvnas", RuPropisju.griven(331.995)
      assert_equal "one hryvna", RuPropisju.grivna(1)
      assert_equal "three hryvnas fourteen kopecks", RuPropisju.grivny(3.14)
    end
  end

  def test_kopeek
    I18n.with_locale(:ru) do
      assert_equal "сто двадцать три рубля", RuPropisju.kopeek(12300)
      assert_equal "три рубля 14 копеек", RuPropisju.kopeek(314)
      assert_equal "32 копейки", RuPropisju.kopeek(32)
      assert_equal "21 копейка", RuPropisju.kopeika(21)
      assert_equal "3 копейки", RuPropisju.kopeiki(3)
    end

    I18n.with_locale(:en) do
      assert_equal "one hundred twenty three roubles", RuPropisju.kopeek(12300)
      assert_equal "three roubles 14 kopecks", RuPropisju.kopeek(314)
      assert_equal "32 kopecks", RuPropisju.kopeek(32)
      assert_equal "21 kopeck", RuPropisju.kopeika(21)
      assert_equal "3 kopecks", RuPropisju.kopeiki(3)
    end
  end
end
