# -*- coding: utf-8; mode: ruby; -*-

require 'find'
require 'fileutils'
require 'logger'
require 'optparse'

require_relative 'application'


module Video2Audio

  #
  #
  #
  class Converter < Application
    PROGRAM = File.basename __FILE__, ".*"
    EXTS = [ ".flv", ".mp4", ".webm" ]
    # オリジナルなヘルプテキスト(上のほう)を予め書いておきます。
    HELP_TEXT = <<HELP
#{PROGRAM} is extract music from videos.

Basic Command Line Usage:
  #{PROGRAM} --recursive <video directory path> --base ~/Music
  #{PROGRAM} <video file path> -o <audio file path>

Options:
HELP

    #
    #
    #
    def initialize(app_name = PROGRAM, application_specific = {}, *arguments)
      super( app_name )

      @options = {}
    end

    #
    #
    #
    def run
      argument_parse
      argument_verify

      if @search_recursive_p then
        convert_recursive_many_files
        return 0
      end

      if File.directory? @input_path then
        convert_many_files
      else
        convert_single_file
      end

      return 0
    end

    private
    #
    #
    #
    def argument_parse
      # オプションパーサーを作成し、それに追加するブロックに on を書いておきます。
      option_parser = OptionParser.new do |opts|
        opts.banner = HELP_TEXT
        #
        # 抽出する動画ファイルへのパスを指定します。
        #
        opts.on( "--file [PATH]", "video file to extract" ) do |video_filepath|
          @options[:file] = video_filepath
        end
        #
        # 音楽ファイルを置いておく場所を指定します。
        #
        opts.on( "-o [PATH]", "--output [PATH]", "path to audio file" ) do |audio_filepath|
          @options[:output] = audio_filepath
        end
        #
        # 出力する音楽ファイルをおいておくためのベースパスを指定します。
        #
        opts.on( "--base PATH", "path to audio file dir base" ) do |audio_basepath|
          @options[:audio_basepath] = audio_basepath
        end
        #
        # 指定されたディレクトリを再帰的に検索します。
        #
        opts.on( "-r", "--recursive", "search for recursive" ) do |search_recursive|
          @options[:recursive] = search_recursive
        end
        #
        # デバッグモードで起動します。
        #
        opts.on( "--debug", "run debug mode" ) do |debug_level|
          @options[:run_level] = debug_level
          #level = Logger::DEBUG
        end
      end
      # 引数のない parse はデフォルトで ARGV を使うんだと思います。
      option_parser.parse!
    end

    #
    #
    #
    def argument_verify
      @logger.debug { "option size is #{ARGV.size}" }
      case ARGV.size
      when 0
      @logger.warn { "option nothing" }
        exit 0
      when 1..2
        @logger.debug { "option at: 0. ; => #{ARGV[0]}" }
      @logger.debug { "option at: 1. ; => #{ARGV[1]}" } if ARGV.size == 2
        @input_path, @input_parent_path = found_path ARGV[0] if ARGV.size == 1
        @output_path, @output_parent_path = found_path ARGV[1], true if ARGV.size == 2
      else
        @logger.fatal { "#{PROGRAM}: invalid options. run `#{PROGRAM} --help' for assistance." }
        exit 0
      end

      @found_pattern = "*.{#{EXTS.join( ',' )}}"

      if @options.has_key? :file then
        @input_path, input_parent_path = found_path @options[:file]
      end

      if @options.has_key? :audio_basepath then
        @output_base_path = File.expand_path @options[:audio_basepath]
        @output_path, @output_parent_path = found_path @output_base_path, true
      else
        @logger.info { "no setting audio base path" }
      end

      if @options.has_key? :recursive then
        @search_recursive_p = true
        @logger.info { "search recursive on" }
      else
        @search_recursive_p = false
        @logger.info { "search recursive false" }
      end

      if @options.has_key? :output then
        @output_path, @output_parent_path = found_path @options[:output], true
      else
        # @output_parent_path = @input_parent_path unless @output_parent_path.nil?
      end

      if @logger.debug? then
        @logger.debug { "input path: #{@input_path}" }
        @logger.debug { "input parent path: #{@input_parent_path}" }
        @logger.debug { "output path: #{@output_path}" }
        @logger.debug { "output parent path: #{@output_parent_path}" }
        @logger.debug { "output base path: #{@output_base_path}" }
      end
    end

    #
    # \param path             探すパス。
    # \param absent_creation  存在しない場合、作成するかどうか。
    #
    def found_path(path, absent_creation = false)
      original_path = File.expand_path path
      @logger.debug { "original path: #{original_path}" }

      if File.directory? original_path then
        original_parent_path = original_path
      elsif File.file? original_path
        original_parent_path = File.dirname original_path
      else
        original_parent_path = original_path
      end
      @logger.debug { "original dir path: #{original_parent_path}" }
      if absent_creation and not File.exist? original_parent_path then
        @logger.debug { "create dir #{original_parent_path}" }
        FileUtils.mkdir_p original_parent_path
      else
        unless File.exist? original_parent_path then
          @logger.fatal { "#{PROGRAM}: cannot access to #{original_parent_path}: no such file or directory" }
          exit 0
        end
      end
      [ original_path, original_parent_path ]
    end

    #
    #
    #
    def default_options(options = {})
      options.merge :audio_codec => "libvorbis", :audio_bitrates => "128K", :audio_sampling => 44100, :audio_channel => 2
    end

    #
    #
    #
    def ffmpeg_convert(infile, outfile, options = {})
      options = default_options( options )

      if File.exist? outfile then
        @logger.debug { "#{File.ctime( outfile )} > #{File.ctime( infile )} # => #{File.ctime( outfile ) > File.ctime( infile )}" }
        return 1 if File.ctime( outfile ) > File.ctime( infile )
      end
      @logger.debug { "ffmpeg -i '#{infile}' -y -vn -acodec #{options[:audio_codec]} -ab #{options[:audio_bitrates]} -ar #{options[:audio_sampling]} -ac #{options[:audio_channel]} '#{outfile}'" }
      system "ffmpeg -i '#{infile}' -y -vn -acodec #{options[:audio_codec]} -ab #{options[:audio_bitrates]} -ar #{options[:audio_sampling]} -ac #{options[:audio_channel]} '#{outfile}'"
    end

    #
    #
    #
    def convert_single_file
      @logger.debug { "#{@input_path} is file." }
      in_filename = @input_path
      if File.directory? @output_path then
        out_filename = File.join @output_parent_path, "#{File.basename( @input_path, '.*' )}.ogg"
      else
        out_filename = @output_path
      end
      ffmpeg_convert in_filename, out_filename
    end

    #
    #
    #
    def convert_many_files
      @logger.debug { "#{@input_path} is directory." }

      Dir.chdir( @input_parent_path ) do |current_dir|
        Dir.glob( @found_pattern ) do |filename|
          in_filename = File.join( @input_parent_path, filename )
          out_filename = File.join( @output_parent_path, "#{File.basename( filename, '.*' )}.ogg" )
          ffmpeg_convert in_filename, out_filename
        end
      end
    end

    #
    #
    #
    def convert_recursive_many_files
      @logger.debug { "#{@input_path} is directory." }
      input_parent_dirname = File.dirname( @input_parent_path )
      Find.find( @input_parent_path ) do |path|
        if File.directory? path then
          output_parent_path = path.gsub( File.dirname( @input_parent_path ), @output_base_path )
          @logger.debug { "current path: #{path}" }
          FileUtils.mkdir_p output_parent_path unless File.exist? output_parent_path
          next
        else
          next unless EXTS.include?( File.extname path )

          temp_parent_path = File.dirname( path.gsub( input_parent_dirname, @output_base_path ) )
          @logger.debug { "temp parent path: #{temp_parent_path}" }

          unless temp_parent_path == output_parent_path then
            @logger.debug { "parent path: #{temp_parent_path}" }
            output_parent_path = temp_parent_path
          end
        end
        in_filename = path
        out_filename = File.join( output_parent_path, "#{File.basename( path, '.*' )}.ogg" )

        ffmpeg_convert in_filename, out_filename
      end
    end
  end

end
