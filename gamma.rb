#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

module Gamma

class Options < ::OptionParser
    @@version = '0.0.2'
    attr_reader :options

    def initialize(args)
        super()
        @version = @@version

        @options = OpenStruct.new
        @options.action = :crypt
        @options.gamma = nil
        @options.dictionaries = {}
        init
        parse!(args = args.dup)
        @options.strings = args
        validate
    end

    def init
        on('-c', '--crypt', 'Crypt message (default)') do
            @options.action = :crypt
        end

        on('-d', '--decrypt', 'Decrypt message') do
            @options.action = :decrypt
        end

        on('-D', '--dictionary DICTIONARY', 'Dictionary') do |d|
            k, v = d.split(':', 2)
            @options.dictionaries[k.to_sym] = v
        end

        on('-G', '--gamma GAMMA', 'Gamma') do |g|
            @options.gamma = g
        end

        on_tail('-h', '--help', 'Show this help') do
            puts self
            exit
        end
    end

    def validate
        if @options.gamma && ! @options.strings.empty?
            return
        end
        puts self
        exit
    end
end

class Dictionary < ::String
private
    DEFAULT = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'

public
    def self.reset(default = DEFAULT)
        @@string = {:string => default, :gamma => default }
    end

reset

    def self.set(value)
        if ! value
            reset
        elsif value.kind_of?(Hash)
            value.each do |k, v|
                @@string[k] = v if @@string[k]
            end
        else
            reset(value)
        end
    end

    def self.get(key)
        raise 'Dictionary not defined for %s!' % key unless @@string[key]
        @@string[key]
    end

    def self.indexof(value, key)
        char = value[0, 1]
        index = @@string[key].index(char)
        raise 'Index for `%s` not defined' % char unless index
        return index + 1
    end
end

class CryptDecrypt < ::String
    def initialize(value, gamma)
        super(value)
        # increase length of a gamma to a source string length
        len = value.length / gamma.length
        @gamma = gamma * (len + 1)
        @result = nil
        dostuff
    end

    def dostuff
        raise 'Derive `dostuff` method in class %s' % self.class.name
    end

    def to_s
        @result
    end
end

class Crypt < CryptDecrypt
    def dostuff
        value = self
        c = 0
        @result = ''
        value.split(//).each do |char|
            index_dict = Dictionary.indexof(char, :string)
            gamma_char = @gamma[c, 1]
            index_gamma = Dictionary.indexof(gamma_char, :gamma)
            r = (index_dict + index_gamma) % Dictionary.get(:string).length
            @result += Dictionary.get(:string)[r - 1, 1]
            c += 1
        end
    end
end

class Decrypt < CryptDecrypt
    def dostuff
        value = self
        c = 0
        @result = ''
        value.split(//).each do |char|
            index_dict = Dictionary.indexof(char, :string)
            gamma_char = @gamma[c, 1]
            index_gamma = Dictionary.indexof(gamma_char, :gamma)
            r = (index_dict - index_gamma) + Dictionary.get(:string).length
            r %= Dictionary.get(:string).length
            @result += Dictionary.get(:string)[r - 1, 1]
            c += 1
        end
    end
end

class Crypter
    def initialize(opts)
        @opts = opts.options
    end

    def run
        Dictionary.set(@opts.dictionaries)
        _class = @opts.action == :decrypt ? Decrypt : Crypt
        @opts.strings.each do |string|
            puts _class.new(string, @opts.gamma).to_s
        end
    end
end

end

if $0 == __FILE__
    opts = Gamma::Options.new(ARGV)
    crypter = Gamma::Crypter.new(opts)
    crypter.run
end
