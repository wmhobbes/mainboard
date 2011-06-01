# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require "logger"
require "pp"
Bundler.require(:default, PADRINO_ENV)

# miniconf
Miniconf.defaults do
  database.host = 'localhost'
  database.port = 27017
  database.name = 'mainboard'
end
Miniconf.boot! :root => PADRINO_ROOT, :env_prefix => 'mainboard', :env => PADRINO_ENV,
  :database_service => 'mongodb'

puts Miniconf.config.database.to_s


##
# Enable devel logging
#
# Padrino::Logger::Config[:development] = { :log_level => :devel, :stream => :stdout }
# Padrino::Logger.log_static = true
#

##
# Add your before load hooks here
#
Padrino.before_load do
  Miniconf.with_config do |c|
    logger.debug "-- options --\n#{c.to_s}"

  end
end

##
# Add your after load hooks here
#
Padrino.after_load do
end

Padrino.load!