# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "alchemy/version"

Gem::Specification.new do |s|
  s.name        = "alchemy_cms"
  s.version     = Alchemy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas von Deyen", "Robin Böning", "Carsten Fregin"]
  s.email       = ["alchemy@magiclabs.de"]
  s.homepage    = "http://alchemy-cms.com"
  s.summary     = %q{An extremly flexbile CMS for Rails 3.}
  s.description = %q{Alchemy is an awesome Rails CMS with an extremely flexible content storing architecture.}
  s.requirements << 'ImageMagick (libmagick), v6.6 or greater.'
  s.license = 'BSD New'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<rails>, ["~> 3.1"])
  s.add_runtime_dependency(%q<authlogic>)
  s.add_runtime_dependency(%q<awesome_nested_set>, ["~> 2.0"])
  s.add_runtime_dependency(%q<declarative_authorization>, ["~> 0.5.4"])
  s.add_runtime_dependency(%q<tvdeyen-fleximage>, ["~> 1.0.9"])
  s.add_runtime_dependency(%q<will_paginate>, ["~> 3.0"])
  s.add_runtime_dependency(%q<acts_as_ferret>, ["~> 0.5"])
  s.add_runtime_dependency(%q<acts_as_list>, ["~> 0.1"])
  s.add_runtime_dependency(%q<magiclabs-userstamp>, ["~> 2.0.2"])
  s.add_runtime_dependency(%q<dynamic_form>, ["~> 1.1"])
  s.add_runtime_dependency(%q<jquery-rails>, ["~> 1.0.16"])
  s.add_runtime_dependency(%q<attachment_magic>, ["~> 0.2.1"])

	s.add_development_dependency(%q<rspec-rails>, ["~> 2.8"])
	s.add_development_dependency(%q<sqlite3>)

end
