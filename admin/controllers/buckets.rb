Admin.controllers :buckets do

  get :index do
    @buckets = current_account.administrator? ? Bucket.all :
      Bucket.where(:account_id => current_account.id).all
    render 'buckets/index'
  end

  get :new do
    @bucket = Bucket.new
    render 'buckets/new'
  end

  post :create do
    @bucket = Bucket.new(params[:bucket])
    @bucket.account = current_account
    @bucket.type = :data # for now
    if @bucket.save
      flash[:notice] = 'Bucket was successfully created.'
      redirect url(:buckets, :edit, :id => @bucket.id)
    else
      render 'buckets/new'
    end
  end

  get :edit, :with => :id do
    @bucket = Bucket.find(params[:id])
    only_admin_or_owner_of @bucket

    render 'buckets/edit'
  end

  put :update, :with => :id do
    @bucket = Bucket.find(params[:id])
    only_admin_or_owner_of @bucket

    if @bucket.update_attributes(params[:bucket])
      flash[:notice] = 'Bucket was successfully updated.'
      redirect url(:buckets, :edit, :id => @bucket.id)
    else
      render 'buckets/edit'
    end
  end

  delete :destroy, :with => :id do
    bucket = Bucket.find(params[:id])
    only_admin_or_owner_of bucket

    if bucket.destroy
      flash[:notice] = 'Bucket was successfully destroyed.'
    else
      flash[:error] = 'Impossible destroy Bucket!'
    end
    redirect url(:buckets, :index)
  end
end
