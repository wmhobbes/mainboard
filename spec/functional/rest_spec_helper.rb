
require File.expand_path("../../spec_helper", __FILE__)

require 'right_aws'
require 'right_http_connection'

# do not retry
RightAws::AWSErrorHandler::reiteration_time = 0
Rightscale::HttpConnection::params[:http_connection_retry_count] = 0