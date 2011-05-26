Mainboard.controllers do

  # list all my buckets
  get :index do
    logger.debug "+ bucket index"

    aws_authenticate

    list_buckets
  end

  # get bucket
  get %r{/([^\/]+)/?} do
    logger.debug "+ bucket get"

    aws_authenticate

    @input = request.params
    bucket_name = params[:captures].first

    if @input.has_key? 'torrent'
      raise NotImplemented
    end

    get_bucket_content bucket_name

  end


  # bucket create
  put %r{/([^\/]+)/?} do
    logger.debug "+ bucket create"

    aws_authenticate

    bucket_name = params[:captures].first
    create_bucket bucket_name

  end


  # bucket delete
  delete %r{/([^\/]+)/?} do
    logger.debug "+ bucket delete"

    aws_authenticate

    bucket_name = params[:captures].first
    delete_bucket bucket_name

  end

end