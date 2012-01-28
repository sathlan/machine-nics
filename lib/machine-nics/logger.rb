require 'singleton'
require 'logger'
module MachineNics
  class Log
    include Singleton

    attr_accessor :level
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.datetime_format = "%H:%M:%S"
      @level = 0
    end

    def method_missing(name, *args, &block)
      prefix = "  "*@level
      @logger.send(name,prefix + args.join(" "), &block) if @logger
    end
  end
end
