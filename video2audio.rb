#!/usr/bin/env ruby
# -*- coding: utf-8; mode: ruby; -*-

if File.symlink? __FILE__ then
  this_filepath = File.readlink __FILE__
  $:.unshift File.dirname( this_filepath )
else
  $:.unshift File.dirname( __FILE__ )
end

require 'converter'

progn = Video2Audio::Converter.new
status = progn.start
