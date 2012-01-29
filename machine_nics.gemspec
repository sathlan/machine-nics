# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "machine-nics/version"

Gem::Specification.new do |s|
  s.name        = "machine-nics"
  s.version     = MachineNics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '~> 1.9.1'
  s.authors     = ["sathlan"]
  s.email       = ["mypublicaddress-code@ymail.com"]
  s.homepage    = ""
  s.summary     = %q{Creates complex virtual network on Linux and FreeBSD.}
  s.description = <<-EOF
     Using a simple YAML description can create tap, bond, vlan and bridge.
     This is usefull for quicly setting up complex virtual network on a host
     for use by guest virtual machine.
EOF

  s.rubyforge_project = "machine-nics"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "rspec", "~> 2.8"
  s.add_development_dependency "cucumber", "~> 1.1"
  s.add_development_dependency "aruba", "~> 0.4"
end
