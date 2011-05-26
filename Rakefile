require 'rubygems'
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run all functional specs"
RSpec::Core::RakeTask.new (:spec_functional) do |t|
  t.pattern = FileList['spec/functional/*/*_spec.rb']
end

desc "Run all unit specs"
RSpec::Core::RakeTask.new (:spec_unit) do |t|
  t.pattern = FileList['spec/unit/*/*_spec.rb']
end

desc "Run all specs"
task :spec => [:spec_unit, :spec_functional] do
end
