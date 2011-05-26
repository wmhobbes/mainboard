

Mainboard.controllers do

  # get slot
  get %r{/([^\/]+?)/(.+)} do

    aws_authenticate

    bucket_name, file_name = params[:captures]


  end


end