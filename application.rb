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
    attr_reader :application_name
    attr_reader :logger

    def initialize(appname = nil)
      @application_name = appname
      @logger = Logger.new(STDERR)
    end

    #
    #
    #
    alias appname application_name

    #
    #
    #
    def log(severity, message = nil, &block)
      logger.add(serverity, message, application_name, &block) if logger
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
      result ? result : 0
    end
  end

end
