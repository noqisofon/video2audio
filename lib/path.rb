# -*- coding: utf-8; mode: ruby; -*-

require 'find'
require 'fileutils'

require_relative 'loggable'


module Video2Audio

  #
  #
  #
  class Path < Loggable
    #
    #
    #
    def initialize(file_or_directory_path)
      super "path"
      @entity_uri = file_or_directory_path
    end

    #
    #
    #
    def directory?
      File.directory? @entity_uri
    end
  end

end
