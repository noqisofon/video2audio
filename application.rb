# -*- coding: utf-8; mode: ruby; -*-
require 'logger'

module Video2Audio

  #
  #
  #
  class Application
    #
    #
    #
    def initialize(appname = nil)
      @application_name = appname
      @logger = Logger.new( STDERR )
    end

    #
    #
    #
    def appname
      @application_name
    end

    #
    #
    #
    def log(severity, message = nil, &block)
      @logger.add serverity, message, @application_name, &block if @logger
    end

    #
    #
    #
    def run
      # override please!!
      0
    end

    #
    #
    #
    def start
      result = run

      result = 0 if result.nil?

      result
    end
  end

end
