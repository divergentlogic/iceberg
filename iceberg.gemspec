# -*- encoding: utf-8 -*-
require File.expand_path("../lib/iceberg/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "iceberg"
  s.version     = Iceberg::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christopher Durtschi"]
  s.email       = ["christopher.durtschi@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/iceberg"
  s.summary     = "Forum as Rack middleware"
  s.description = "Forum as Rack middleware"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "iceberg"

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rake', '~> 0.8.7'
  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency "rack-test"
  s.add_development_dependency 'webrat'
  s.add_development_dependency 'be_valid_asset'
  s.add_development_dependency 'dm-sqlite-adapter', '1.1.0'
  s.add_development_dependency 'dm-sweatshop', '1.1.0'

  case RUBY_VERSION
  when /^1\.9/
    s.add_development_dependency "ruby-debug19"
  when /^1\.8/
    s.add_development_dependency "ruby-debug" unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"
  end

  s.add_runtime_dependency 'sinatra', '~> 1.2.0'
  s.add_runtime_dependency 'rack-flash', '0.1.2'
  s.add_runtime_dependency 'dm-core', '1.1.0'
  s.add_runtime_dependency 'dm-migrations', '1.1.0'
  s.add_runtime_dependency 'dm-types', '1.1.0'
  s.add_runtime_dependency 'dm-serializer', '1.1.0'
  s.add_runtime_dependency 'dm-aggregates', '1.1.0'
  s.add_runtime_dependency 'dm-timestamps', '1.1.0'
  s.add_runtime_dependency 'dm-validations', '1.1.0'
  s.add_runtime_dependency 'dm-tags', '1.1.0'
  s.add_runtime_dependency 'dm-is-list', '1.1.0'
  s.add_runtime_dependency 'dm-is-tree', '1.1.0'
  s.add_runtime_dependency 'padrino'
  s.add_runtime_dependency 'haml'
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'activesupport', '~> 3.0.0'
  s.add_runtime_dependency 'i18n'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
