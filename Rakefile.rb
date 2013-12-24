#!/usr/bin/env ruby

require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new('test') do |t|
    t.verbose = true
end
