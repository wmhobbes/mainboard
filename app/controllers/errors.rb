
Mainboard.controllers do

  error do
    boom = env['sinatra.error']
    aws_fail boom if boom.kind_of? AWS::S3::Error

    logger.error ["#{boom.class} - #{boom.message}:", *boom.backtrace].join("\n ")
    aws_fail InternalError.new  # if settings.environment == :production
    throw :halt, [500, "Internal Server Error."]
  end

end
