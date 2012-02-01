require 'rubygems'
require 'bundler/setup'
require "machine-nics/logger"
require "machine-nics/version"
require "machine-nics/config"
require "machine-nics/tree"
require "machine-nics/actions"

module MachineNics
  def log
    MachineNics::Log.instance
  end
  def config
    MachineNics::Config.instance
  end
end
