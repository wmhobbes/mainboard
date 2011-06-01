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

desc 'Removes trailing whitespace across the entire application.'
task :whitespace do
  require 'rbconfig'
  if Config::CONFIG['host_os'] =~ /linux/
    sh %{find . -name '*.*rb' -exec sed -i 's/\t/  /g' {} \\; -exec sed -i 's/ *$//g' {} \\; }
  elsif Config::CONFIG['host_os'] =~ /darwin/
    sh %{find . -name '*.*rb' -exec sed -i '' 's/\t/  /g' {} \\; -exec sed -i '' 's/ *$//g' {} \\; }
  else
    puts "This doesn't work on systems other than OSX or Linux. Please use a custom whitespace tool for your platform '#{Config::CONFIG["host_os"]}'."
  end
end