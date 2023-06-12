class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: :index

  def index
    audience = params[:audience] ||= Message.audiences.public
    per_page = params[:per_page] ||= Message.per_page

    @messages = case audience
                when Message.audiences.public
                  policy_scope(Message).where(audience: Message.audiences.public).order(updated_at: 'desc')
                when Message.audiences.admin
                  if access_level_is_admin?
                    policy_scope(Message).where(audience: Message.audiences.admin).order(updated_at: 'desc')
                  else
                    Message.none
                  end
                else
                  policy_scope(Message).where("recipient = :user_id", user_id: current_user.id).order(updated_at: 'desc')
                end

    @messages = @messages.paginate(page: params[:page], per_page: per_page)

    @body_classes = "bg-light"
  end

  def show
    authorize @message
  end

  def new
    @message = Message.new
    authorize @message
  end

  def edit
    authorize @message
  end

  def create
    @message = Message.new(message_params)
    authorize @message

    if @message.save
      redirect_to @message, notice: 'Message was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @message
    if @message.update(message_params)
      redirect_to @message, notice: 'Message was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @message
    @message.destroy
    redirect_to messages_url, notice: 'Message was successfully destroyed.'
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def message_params
    params
      .require(:message)
      .permit(
        :sender,
        :recipient,
        :subject,
        :body,
        :status,
        :audience
      )
  end
end
