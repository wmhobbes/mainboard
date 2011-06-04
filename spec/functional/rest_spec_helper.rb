
require File.expand_path("../../spec_helper", __FILE__)

require 'right_aws'
require 'right_http_connection'

# do not retry
RightAws::AWSErrorHandler::reiteration_time = 0
Rightscale::HttpConnection::params[:http_connection_retry_count] = 0



def connect_as role

  account = Account.where(:role => role).first
  @s3_settings = {
    :key => account.key,
    :secret => account.secret,
    :bucket_name => 'none',
    :settings => {
      :server => '127.0.0.1',
      :port => 3000,
      :protocol => 'http'
    }
  }

  RightAws::S3.new @s3_settings[:key], @s3_settings[:secret], @s3_settings[:settings]
end
