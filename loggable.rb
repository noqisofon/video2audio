# -*- coding: utf-8; mode: ruby; -*-

require 'logger'


module Video2Audio

  #
  #
  #
  class Loggable
    #
    #
    #
    def initialize(program_name = nil)
      @progname = program_name
    end

    #
    #
    #
    def debug(&block)
      @logger.debug @progname, block
    end

    #
    #
    #
    def info(&block)
      @logger.info  @progname, block
    end

    #
    #
    #
    def warn(&block)
      @logger.warn  @progname, block
    end

    #
    #
    #
    def error(&block)
      @logger.error  @progname, block
    end

    #
    #
    #
    def fatal(&block)
      @logger.fatal  @progname, block
    end
  end

end
