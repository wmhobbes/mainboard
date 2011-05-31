Mainboard.controllers do

  # list all my buckets
  get :index do
    logger.debug "+ bucket index"
    aws_authenticate

    list_buckets
  end

  # get bucket
  get '/:bucket' do
    logger.debug "+ bucket get"
    aws_authenticate

    @input = request.params
    if @input.has_key? 'torrent'
      raise NotImplemented
    end

    get_bucket_content params[:bucket]
  end


  # bucket create
  put '/:bucket' do
    logger.debug "+ bucket create"
    aws_authenticate

    create_bucket params[:bucket]
  end


  # bucket delete
  delete '/:bucket' do
    logger.debug "+ bucket delete"
    aws_authenticate

    delete_bucket params[:bucket]
  end

end