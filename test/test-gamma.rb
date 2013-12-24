#!/usr/bin/env ruby

require 'test/unit'
require 'gamma'

module Gamma

class TestDictionary < Test::Unit::TestCase
    def setup
        Dictionary.reset
    end

    def test_set
        dict = '1qaz'
        Dictionary.set(dict)
        assert_equal dict, Dictionary.get
        assert_equal dict.length, Dictionary.get.length
    end

    def test_indexof
        assert_equal 1, Dictionary.indexof('а')
        assert_equal 7, Dictionary.indexof('ё')
        assert_equal 33, Dictionary.indexof('я')
    end
end

class TestCryptDecrypt < Test::Unit::TestCase
    def setup
        Gamma::Dictionary.set('АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ 0123456789')
        @gamma = 'ТИГР'
    end

    def test_gamma_crypt
        assert_equal '3ОЖЪ1Ч3ЙР', Gamma::Crypt.new('РЕГИОН 27', @gamma).to_s
        assert_equal 'ХОХЖТА4ЖЮМ', Gamma::Crypt.new('ВЕС 900 КГ', @gamma).to_s
    end

    def test_gamma_decrypt
        assert_equal 'ВЕС 900 КГ', Gamma::Decrypt.new('ХОХЖТА4ЖЮМ', @gamma).to_s
        assert_equal 'РЕГИОН 27', Gamma::Decrypt.new('3ОЖЪ1Ч3ЙР', @gamma).to_s
    end
end

end
