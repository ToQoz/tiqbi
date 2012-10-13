#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "slop"
argv = ARGV.dup
slop = Slop.new(:strict => true, :help => true)
slop.banner "$ bundle exec ruby bin/masyo [options]\n"
slop.on :use_mock=, ""

begin
  slop.parse!(argv)
rescue => e
  puts e
  exit!
end
options = slop.to_hash
unless options[:help]
  options.delete(:help)

  root = File.expand_path("../..", __FILE__)
  $LOAD_PATH.unshift root
  $LOAD_PATH.unshift File.join(root, 'lib')

  require "tiqbi"
  Tiqbi.run options
end