class EstimatesController < ApplicationController
  before_action :create_resource, only: :new
  before_action :create_with_params, only: :create
  skip_before_action :authenticate_user!, only: [:new, :create]

  def index
    @estimates = Estimate.all.order(created_at: :desc)
    authorize(@estimates)
    @body_classes = "bg-light"
  end

  def show
    @estimate = Estimate.find(params[:id])
    authorize(@estimate)
  end

  def new
    @estimate[:for] = params[:for]
    @estimate[:description] = params[:description]

    @skip_footer = true
    render layout: 'front'
  end

  def create
    @skip_footer = true
    if verify_recaptcha(model: @estimate) && @estimate.save
      Message.create(
        item: @estimate,
        message_type: 'creation',
        sender: 0,
        recipient: 0,
        audience: Message.audiences.admin,
        subject: I18n.t("notifications.estimates.admin.subject", title: @estimate.title)
      )

      MessageMailer.prepare_new_quick_estimate(@estimate)

      render layout: 'front'
    else
      render :new, layout: 'front'
    end
  end

  def destroy
    @estimate = Estimate.find(params[:id])
    authorize(@estimate)
    @estimate.destroy
    respond_with(@estimate)
  end

  private

  def create_resource
    @estimate = Estimate.new
  end

  def create_with_params
    @estimate = Estimate.new(estimate_params)
  end

  def estimate_params
    params.require(:estimate).permit(
      :description,
      :email,
      :for,
      :phone,
      :title
    )
  end
end
