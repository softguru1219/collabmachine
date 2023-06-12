class UserMessagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  before_action :create_resource, only: [:new]
  before_action :create_with_params, only: [:create]
  before_action :authorize_resource, only: [:show, :edit, :destroy, :update]
  after_action :verify_authorized, except: [:new, :create]

  def index
    @user_messages = UserMessage.all
    authorize @user_messages
    @body_classes = "bg-light"
  end

  def show
    @body_classes = "bg-light"
  end

  def new
  end

  def create
    unless @user_message.anonymous
      if user_signed_in?
        @user_message.user = current_user
      else
        @user_message.anonymous = true
      end
    end

    if @user_message.save
      respond_with @user_message, location: user_signed_in? ? dashboard_path : root_path
      # email here
      MessageMailer.send_user_message(@user_message).deliver_now
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user_message.update(user_message_params)
      respond_with @user_message
    else
      render :edit
    end
  end

  def destroy
    @user_message.destroy
    respond_with @user_message, location: dashboard_path
  end

  private

  def authorize_resource
    authorize @user_message
  end

  def find_resource
    @user_message = UserMessage.find(params[:id])
  end

  def create_resource
    @user_message = UserMessage.new
  end

  def create_with_params
    @user_message = UserMessage.new(user_message_params)
  end

  def user_message_params
    params.require(:user_message).permit(
      :title,
      :message,
      :anonymous,
      :user_id
    )
  end
end
