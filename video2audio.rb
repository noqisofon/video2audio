#!/usr/bin/env ruby
# -*- coding: utf-8; mode: ruby; -*-

require_relative 'converter'

progn = Video2Audio::Converter.new
status = progn.start
