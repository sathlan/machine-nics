# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "machine_nics/version"

Gem::Specification.new do |s|
  s.name        = "machine_nics"
  s.version     = MachineNics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["sathlan"]
  s.email       = ["mypublicaddress-code@ymail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "machine_nics"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "rspec", "~> 2.8"
  s.add_development_dependency "cucumber", "~> 1.1"
  s.add_development_dependency "aruba", "~> 0.4"
end