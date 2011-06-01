

Mainboard.controllers do

  # get slot
  get '/:bucket/*slot' do |bucket, slot|
    aws_authenticate

    get_slot_content bucket, slot.join('/')
  end

  # put slot
  put '/:bucket/*slot' do |bucket, slot|
    logger.debug "+ slot put"
    aws_authenticate

    put_slot bucket, slot.join('/'), request.body
  end

  # delete slot
  delete '/:bucket/*slot' do |bucket, slot|
    logger.debug "+ slot delete"
    aws_authenticate

    delete_slot bucket, slot.join('/')
  end
end
