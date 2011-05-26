require File.expand_path('../requires_parameters', __FILE__)
require File.expand_path('../ostruct', __FILE__)
require 'json'
require 'pp'

# autoconfigures applications from config file, VCAP environment, or environment variables

class Miniconf
  include RequiresParameters
  
  CONFIGURATION_FILE = 'config/options.yml'
  
  ENV_PREFIX = 'mcx'

  DB_ENV_PREFIX = 'db'
  DB_ENV_VARS = [
    'hostname',
    'port',
    'name',
    'db',
    'user',
    'password',
    'prefix'
  ]
  
  VCAP_VARS = /^VCAP_(\w+)/i
  VCAP_JSON_ENCODED = ['application', 'services']
  
  class Data < OpenStruct
    def to_s
      to_h.pretty_inspect
    end
  end
  
  attr_reader :state, :options, :database, :vcap
  
  def self.config
    @config ||= Miniconf.new
  end
  
  def self.defaults &blk
    config.instance_eval &blk
    config
  end
  
  def self.with_config &blk
    blk.call config
  end

  def self.boot!(params = {})
    config.boot! params
  end

  def initialize
      
    @options = Data.new
    @database = Data.new
  end

  def boot!(params = {})
    requires! params, :root, :env
    
    @state = Data.new(params)
    state.env_prefix  ||= ENV_PREFIX
    state.config_file ||= CONFIGURATION_FILE
    state.config_path ||= File.expand_path(state.config_file, params[:root])
    
    load_configuration_file
    acquire_environment
    acquire_vcap_environment
    guess_database_from_vcap 
    
    self
  end
  
  private
  #######
  
  def load_configuration_file
    conf = YAML.load(File.open(state.config_path))[state.env]
    @options = options.ostruct_merge conf unless conf.blank?
    @database = database.ostruct_merge options.database unless options.database.blank?
  rescue
  end

  def acquire_environment
 
    env = ENV.inject({}) do |h, e|
      key,val = e
      if key =~ Regexp.new("^#{state.env_prefix}_(\\w+)")
       h[$~.captures.first.downcase] = val
      end
      h
    end
    @options = options.ostruct_merge env
    
    db_env = DB_ENV_VARS.inject({}) do |h, k|
      v = ENV["#{state.env_prefix}_#{DB_ENV_PREFIX}_#{v}"]
      h[k] = v unless v.nil?; h
    end
    @database = database.ostruct_merge db_env
  end
  
  def acquire_vcap_environment
    return unless is_vcap?
    
    vcap_env = ENV.inject({}) do |h,e|
      key,val = e
      if key =~ VCAP_VARS
        k = $~.captures.first.downcase
        h[k] = (VCAP_JSON_ENCODED.include?(k) ? JSON.parse(val) : val)
      end
      h
    end
    @vcap = Data.new vcap_env
        
  end

  def guess_database_from_vcap
    return if !is_vcap? || vcap.services.empty? || state.database_service.nil?

    service_class = vcap.services.find {|k,v| k.include? state.database_service }.last
    return if !service_class || service_class.empty?

    service = 
      if state.database_service_name 
        service_class.find { |s| s['name'] == state.database_service_name }.last
      else
        service_class.first
      end
    
    return if !service || !service.kind_of?(Hash)  || !service.has_key?('credentials')
    @database = database.ostruct_merge service['credentials']
    
  end

  def is_vcap?
    !ENV['VCAP_APPLICATION'].nil?
  end
end

