Admin.controllers :slots do

  get :index do
    @slots = Slot.all
    render 'slots/index'
  end

  get :new do
    @slot = Slot.new
    render 'slots/new'
  end

  post :create do
    @slot = Slot.new(params[:slot])
    if @slot.save
      flash[:notice] = 'Slot was successfully created.'
      redirect url(:slots, :edit, :id => @slot.id)
    else
      render 'slots/new'
    end
  end

  get :edit, :with => :id do
    @slot = Slot.find(params[:id])
    render 'slots/edit'
  end

  put :update, :with => :id do
    @slot = Slot.find(params[:id])
    if @slot.update_attributes(params[:slot])
      flash[:notice] = 'Slot was successfully updated.'
      redirect url(:slots, :edit, :id => @slot.id)
    else
      render 'slots/edit'
    end
  end

  delete :destroy, :with => :id do
    slot = Slot.find(params[:id])
    if slot.destroy
      flash[:notice] = 'Slot was successfully destroyed.'
    else
      flash[:error] = 'Impossible destroy Slot!'
    end
    redirect url(:slots, :index)
  end
end