require 'optparse'
require 'machine_nics/actions'
require 'singleton'
require 'pathname'
require 'psych'
module MachineNics
  class Config
    include Singleton

    attr_reader :type, :definition, :dry_run

    def initialize
      @options = Hash.new('')
      @options[:dry_run] = false
      @parser  = OptionParser.new do |opts|
        opts.on("-f", "--file=FILE") {|file| @options[:file] = file }
        opts.on_tail(
                "-a",
                "--action=CMD",
                "Optional.  Choose between [create], destroy") \
        {|action| @options[:action] = action }
        opts.on_tail(
                "-t",
                "--type=TYPE",
                "Optional,  Guessed by default. Can be #{MachineNics::Actions.list_types}") \
        {|type| @options[:type] = type }
        opts.on_tail(
                "-n",
                "--dry-run",
                "Juste output what would be done") \
        { @options[:dry_run] = true }
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
    end
    def dry_run
      @options[:dry_run]
    end
    def type
      @options[:type]
    end

    def action
      @options[:action]
    end

    def parse
      begin
        @parser.parse(ARGV)
      rescue Exception => err
        err_msg = err.to_s.sub(/^([^:]*)(.*)/) {|msg| $1.upcase + $2}
        puts err_msg
        puts @parser
        exit
      end
      unless @options[:file]
        puts @parser
        exit
      end
      unless File.exists?(@options[:file])
        puts "Missing file \"#{@options[:file]}\""
        puts @parser
        exit
      end
      @definition = Psych.load_file(@options[:file])
    end
  end
end
