require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the apple_push_notification plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ApplePushNotification'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "apple_push_notification"
    gemspec.summary = "Rails plugin for Apple Push Notifications"
    gemspec.description = "Rails plugin for Apple Push Notifications"
    gemspec.email = "sam@samsoff.es"
    gemspec.homepage = "http://github.com/samsoffes/apple_push_notification"
    gemspec.authors = ["Sam Soffes"]
    gemspec.add_development_dependency("rspec", ">= 1.2.9")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end
