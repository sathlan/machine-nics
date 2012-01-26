require 'rubygems'
require 'bundler/setup'
require "machine_nics/logger"
require "machine_nics/version"
require "machine_nics/config"
require "machine_nics/tree"
require "machine_nics/actions"

module MachineNics
  def log
    MachineNics::Log.instance
  end
end
