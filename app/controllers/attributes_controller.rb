class AttributesController < ApplicationController
  before_action :find_resource, only: [:edit, :update, :destroy]

  def new
    @attribute = MetaAttribute.new
    @user = User.friendly.find(params[:user_id])
    @attribute.user = @user
    @visibility = params.fetch(:visibility, 'private')
    respond_with @attribute
  end

  def edit
    @user = User.friendly.find(params[:user_id])
  end

  def create
    @attribute = MetaAttribute.new(attribute_params)
    @user = User.friendly.find(attribute_params[:user_id])

    respond_to do |format|
      if @attribute.save
        format.html { redirect_to user_path(@user, anchor: 'summary'), notice: 'MetaAttribute was successfully created.' }
        format.json { render json: @attribute.to_json }
      else
        format.html { redirect_to user_path(@user, anchor: 'summary') }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    user = @attribute.user
    @attribute.update(attribute_params)
    respond_with @attribute, location: user_path(user, anchor: 'summary')
  end

  def destroy
    user = @attribute.user
    @attribute.destroy
    respond_with @attribute, location: user_path(user, anchor: 'summary')
  end

  private

  def find_resource
    @attribute = MetaAttribute.find(params[:id])
  end

  def attribute_params
    params
      .require(:meta_attribute)
      .permit(
        :name,
        :value,
        :user_id,
        :source_user_id,
        :visibility
      )
  end
end
