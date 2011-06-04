Admin.controllers :slots, :parent => :bucket do

  get :index do
    @bucket = Bucket.find(params[:bucket_id])
    # check permission on bucket

    @slots = Slot.where(:bucket_id => @bucket.id).all
    render 'slots/index'
  end

  get :slot, :map => 'slot/:id' do
    bucket = Bucket.find(params[:bucket_id])
    only_admin_or_owner_of bucket

    slot = bucket.slots.find(params[:id])

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

  get :new do
    @bucket = Bucket.find(params[:bucket_id])
    only_admin_or_owner_of @bucket

    @slot = Slot.new
    render 'slots/new'
  end

  post :create do
    @bucket = Bucket.find(params[:bucket_id])
    only_admin_or_owner_of @bucket
    logger.error params[:slot].pretty_inspect
    tempfile = params[:slot][:uploaded_file][:tempfile]

    @slot = @bucket.slots.build(
      :bit => tempfile.open,
      :bit_name => (params[:slot][:bit_name].blank? ? params[:slot][:uploaded_file][:filename] :
        params[:slot][:bit_name]).sub(/^[\/\.]*/,''),
      :access => params[:slot][:access]
    )

    if @slot.save
      flash[:notice] = 'Slot was successfully created.'
#      redirect url(:slots, :edit, :id => @slot.id, :bucket_id => @bucket)
      redirect url(:slots, :index, :bucket_id => @bucket.id)
    else
      render 'slots/new'
    end
  end

  get :edit, :with => :id do
    @bucket = Bucket.find(params[:bucket_id])
    only_admin_or_owner_of @bucket
    @slot = @bucket.slots.find(params[:id])
    render 'slots/edit'
  end

  put :update, :with => :id do
    @bucket = Bucket.find(params[:bucket_id])
    only_admin_or_owner_of @bucket

    @slot = @bucket.slots.find(params[:id])
    params[:slot][:bit_name].sub!(/^[\/\.]*/,'') if params[:slot]

    if @slot.update_attributes(allow_attributes(params[:slot], :bit_name, :access))
      flash[:notice] = 'Slot was successfully updated.'
      redirect url(:slots, :edit, :id => @slot.id, :bucket_id => @bucket.id)
    else
      render 'slots/edit'
    end
  end

  delete :destroy, :with => :id do
    bucket = Bucket.find(params[:bucket_id])
    only_admin_or_owner_of bucket

    slot = bucket.slots.find(params[:id])
    if slot.destroy
      flash[:notice] = 'Slot was successfully destroyed.'
    else
      flash[:error] = 'Impossible destroy Slot!'
    end
    redirect url(:slots, :index, :bucket_id => bucket)
  end
end
