
Mainboard.helpers do

  def get_slot_content bucket_name, slot_name
    bucket = get_bucket bucket_name
    slot = get_slot bucket, slot_name

    only_can_read slot

    since = Time.httpdate(request.env['HTTP_IF_MODIFIED_SINCE']) rescue nil

    if since && (slot.bit.upload_date) <= since
      raise NotModified
    end

    since = Time.httpdate(request.env['HTTP_IF_UNMODIFIED_SINCE']) rescue nil

    if (since && (slot.updated_at > since)) or (request.env['HTTP_IF_MATCH'] &&
      (slot.bit.get_md5 != request.env['HTTP_IF_MATCH']))
      raise PreconditionFailed
    end

    if request.env['HTTP_IF_NONE_MATCH'] && (slot.bit.get_md5 == request.env['HTTP_IF_NONE_MATCH'])
      raise NotModified
    end

    last_modified slot.updated_at
    etag slot.bit.get_md5
    content_type slot.bit.type
    attachment slot.bit.name

    [200, slot.bit]
  end

  def get_slot bucket, slot_name
    slot = bucket.slots.where(:bit_name => slot_name).first
    raise NoSuchKey if slot.nil?
    slot
  end

  def put_slot bucket_name, slot_name, io
    bucket = get_bucket bucket_name

    only_can_write bucket

    slot = bucket.slots.where(:bit_name => slot_name).first

    # fixes joint trying to access :path on every IO stream, still better than a temp file ;p
    unless io.respond_to? :path
      io.class.instance_eval { attr_accessor :path }
      io.path = slot_name
    end

    if slot.nil?
      slot = bucket.slots.create(
        :bit => io,
        :bit_name => slot_name,
        :access => amz_requested_acl
      )
    else
      raise SlotAlreadyExists
    end
  end

  def delete_slot bucket_name, slot_name

    bucket = get_bucket bucket_name
    slot = get_slot bucket, slot_name

    only_can_write slot

    slot.destroy
  end

end
