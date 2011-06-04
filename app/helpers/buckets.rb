
Mainboard.helpers do

  def list_buckets
    only_authorized

    buckets = @account.buckets
    content_type "application/xml"

    builder { |x|
      x.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      x.ListAllMyBucketsResult :xmlns => "http://s3.amazonaws.com/doc/2006-03-01/" do
        x.Owner {
          x.ID @account.key
          x.DisplayName @account.identity
        }
        x.Buckets {
          buckets.each do |b|
            unless b.destroyed?
              x.Bucket do
                x.Name b.name
                x.CreationDate b.created_at.strftime("%Y-%m-%dT%H:%M:%S.000%Z") # Must match Amazon API Format (i.e. "2006-02-03T16:45:09.000Z")
              end
            end
          end
        }
      end
    }
  end

  def get_bucket bucket_name
    bucket = Bucket.first(:name => bucket_name)
    raise NoSuchBucket unless bucket
    bucket
  end

  def get_bucket_acls bucket_name
    bucket = get_bucket bucket_name

    only_can_read bucket ## there's a specific permission for this
    acl_document bucket

  end

  def put_bucket_acls bucket_name, io
    bucket = get_bucket bucket_name

    only_can_write bucket ## there's a specific permission for this

    acl_parse io.read, bucket
    bucket.save!
  end


  def get_bucket_content bucket_name
    bucket = get_bucket bucket_name

    only_can_read bucket

    @input = request.params

    opts = {:conditions => {:bucket_id => bucket.id}, :order => "name"}
    limit = nil

    if @input['prefix']
      opts[:conditions] = opts[:conditions].merge({:bit_name => /^#{@input['prefix']}.*/i})
    end

    if @input['marker']
      opts[:offset] = @input['marker'].to_i
    end

    opts[:limit] =
      if @input['max-keys']
        @input['max-keys'].to_i
      else
        1000
      end

    slot_count = Slot.all(:conditions => opts[:conditions]).size
    contents = Slot.all(opts)
    truncated = slot_count > contents.length + opts['offset'].to_i

    if @input['delimiter']
      @input['prefix'] = '' if @input['prefix'].nil?

      # Build a hash of { :prefix => content_key }. The prefix will not include the supplied @input.prefix.
      prefixes = contents.inject({}) do |hash, c|
        prefix = get_prefix(c).to_sym
        hash[prefix] = [] unless hash[prefix]
        hash[prefix] << c.bit_name
        hash
      end

      # The common prefixes are those with more than one element
      common_prefixes = prefixes.inject([]) do |array, prefix|
        array << prefix[0].to_s if prefix[1].size > 1
        array
      end

      # The contents are everything that doesn't have a common prefix
      contents.reject! do |c|
        common_prefixes.include? get_prefix(c)
      end

      logger.debug "\e[1;31mContents:\e[0m " + contents.inspect
    end

    content_type :xml

    builder { |x|
      x.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      x.ListBucketResult :xmlns => "http://s3.amazonaws.com/doc/2006-03-01/" do
        x.Name bucket.name
        x.Prefix @input['prefix'] if @input['prefix']
        x.Marker @input['marker'] if @input['marker']
        x.Delimiter @input['delimiter'] if @input['delimiter']
        x.MaxKeys @input['max-keys'] if @input['max-keys']
        x.IsTruncated truncated

        contents.each { |c|
          x.Contents do
            x.Key c.bit_name
            x.LastModified c.bit.upload_date.strftime("%Y-%m-%dT%H:%M:%S.000%Z")
            x.ETag c.bit.get_md5
            x.Size c.bit.grid_io.file_length.to_i
            x.StorageClass "STANDARD"

            x.Owner {
              x.ID c.bucket.account.key
              x.DisplayName c.bucket.account.identity
            }
          end
        }
        if common_prefixes
          common_prefixes.each do |p|
            x.CommonPrefixes { x.Prefix p }
          end
        end
      end
    }
  end


  def delete_bucket bucket_name
    bucket = Bucket.first(:name => bucket_name)

    only_owner_of bucket

    if bucket.slots.size > 0
      raise BucketNotEmpty
    end

    if bucket.nil?
      raise NoSuchBucket
    end

    if Bucket.destroy(bucket.id)
      status 204
    else
      raise InternalError
    end

  end


  def create_bucket bucket_name
    only_authorized

    bucket = Bucket.first(:name => bucket_name)
    if bucket.nil?
      @account.buckets.create!(
        :name => bucket_name,
        :access => amz_requested_acl,
        :created_at => Time.now
      )
      request.env['Location'] = request.env['PATH_INFO']
      request.env['Content-Length'] = 0
      status 200
    else
      raise BucketAlreadyExists
    end

  end

  def get_prefix c
    c.bit_name.sub(@input['prefix'], '').split(@input['delimiter'])[0] + @input['delimiter']
  end

end
