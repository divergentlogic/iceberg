require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "iceberg"
    gem.summary = %Q{Forum as Rack middleware}
    gem.description = %Q{Forum as Rack middleware}
    gem.email = "christopher.durtschi@gmail.com"
    gem.homepage = "http://github.com/robotapocalypse/iceberg"
    gem.authors = ["Christopher Durtschi"]
    gem.add_development_dependency "rspec"
    files = `git ls-files`.split("\n").sort.reject{ |file| file =~ /^\./ }.reject { |file| file =~ /^doc/ }
    %w[sinatra_more].each do |dir|
      files.delete(dir)
      FileUtils.chdir(dir)
      files.concat(`git ls-files`.split("\n").sort.reject{ |file| file =~ /^\./ }.reject { |file| file =~ /^doc/ }.map {|file| "#{dir}/#{file}"})
      FileUtils.chdir('..')
    end
    gem.files = files
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "iceberg #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
