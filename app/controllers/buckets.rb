Mainboard.controllers do

  before do
    logger.debug "-- before buckets --"
    aws_authenticate
    headers :server => "Mainboard"

    logger.debug "--- env ---"
    logger.debug request.env.inspect


    @input = request.params
    puts "--- input ---"
    puts @input.inspect
  end


  # GET Service
  get :index do
    logger.debug "+ bucket index"

    # if it's an anonymous request for / assume it wants the admin page
    if anonymous_request?
      logger.debug "- redirect"
      redirect '/admin'
    else
      list_buckets
    end
  end

  # get bucket
  get '/:bucket' do
    logger.debug "+ bucket get"

    case subresource
    when :policy, :logging,
         :notification
      raise NotImplemented
    when :location
      # seems easy
    when :version
      raise NotImplemented
    when :versioning
      # easy to give at least an answer
    when :website
      # seems easy
    when :acl
      get_bucket_acls params[:bucket]
    else
      get_bucket_content params[:bucket]
    end
  end

  # bucket create
  put '/:bucket' do
    logger.debug "+ bucket create"

    case subresource
    when :policy, :logging
      raise NotImplemented
    when :versioning
      # todo
    when :acl
      put_bucket_acl params[:bucket]
    else
      create_bucket params[:bucket]
    end
  end

  # delete Bucket
  delete '/:bucket' do
    logger.debug "+ bucket delete"

    case subresource
    when :website, :policy
      raise NotImplemented
    else
      delete_bucket params[:bucket]
    end
  end

end
