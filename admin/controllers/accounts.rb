Admin.controllers :accounts do

  get :index do
    @accounts = Account.all
    render 'accounts/index'
  end

  get :new do
    @account = Account.new
    render 'accounts/new'
  end

  post :create do
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = 'Account was successfully created.'
      redirect url(:accounts, :edit, :id => @account.id)
    else
      render 'accounts/new'
    end
  end

  get :profile do 
    @account = current_account
    render 'accounts/profile'
  end

  put :update_profile do
    @account = Account.find(params[:id])
    
    profile = allow_attributes(params[:account], 
      :id,
      :name,
      :surname,
      :password,
      :password_confirmation
    )
    
    if current_account.update_attributes(params[:account])
      flash[:notice] = 'Account was successfully updated.'
      redirect url(:accounts, :profile)
    else
      render 'accounts/profile'
    end    
    
  end

  get :edit, :with => :id do
    @account = Account.find(params[:id])
    render 'accounts/edit'
  end

  put :update, :with => :id do
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Account was successfully updated.'
      redirect url(:accounts, :edit, :id => @account.id)
    else
      render 'accounts/edit'
    end
  end

  delete :destroy, :with => :id do
    account = Account.find(params[:id])
    if account != current_account && account.destroy
      flash[:notice] = 'Account was successfully destroyed.'
    else
      flash[:error] = 'Impossible destroy Account!'
    end
    redirect url(:accounts, :index)
  end

  get :regenerate_key, :with => :id do
    @account = Account.find(params[:id])
    @account.regenerate_key.save!
    flash[:notice] = "Account key was regenerated"
    redirect url(:accounts, :edit, :id => @account.id)
  end

  get :regenerate_secret, :with => :id do
    @account = Account.find(params[:id])
    @account.regenerate_secret.save!
    flash[:notice] = "Account secret was regenerated"
    redirect url(:accounts, :edit, :id => @account.id)
  end
end