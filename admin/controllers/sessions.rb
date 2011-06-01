Admin.controllers :sessions do

  get :new do
    render "/sessions/new", nil, :layout => false
  end

  post :create do
    if account = Account.authenticate(params[:identity], params[:password])
      set_current_account(account)
      redirect url(:base, :index)
    elsif Padrino.env == :development && params[:bypass]
      account = Account.first
      set_current_account(account)
      redirect url(:base, :index)
    else
      flash[:warning] = "Identity or password wrong."
      redirect url(:sessions, :new)
    end
  end

  delete :destroy do
    set_current_account(nil)
    redirect url(:sessions, :new)
  end
end
