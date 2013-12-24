#!/usr/bin/env ruby

require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new('test') do |t|
    t.libs << File.dirname(__FILE__)
    t.verbose = true
end
