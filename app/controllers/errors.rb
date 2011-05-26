
Mainboard.controllers do

  error do
    logger.debug env['sinatra.error']
    aws_fail env['sinatra.error'] if env['sinatra.error'].kind_of? AWS::S3::Error

    logger.error env['sinatra.error'].inspect ## XXX do something better, like notify exception
    aws_fail InternalError.new if settings.environment == :production
    throw :halt, [500, "Internal Server Error."]
  end

end