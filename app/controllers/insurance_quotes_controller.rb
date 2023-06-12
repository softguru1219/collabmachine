class InsuranceQuotesController < ApplicationController
  before_action :check_terms, only: :new
  before_action :create_resource, only: :new
  before_action :create_with_params, only: :create
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    @skip_footer = true
    render layout: 'front'
  end

  def create
    if @quote.save
      Message.create(
        item: @quote,
        message_type: 'creation',
        sender: 0,
        recipient: 0,
        audience: Message.audiences.admin,
        subject: I18n.t("notifications.insurance_quote.admin.subject", name: @quote.name)
      )

      MessageMailer.prepare_quick_insurance_quote(@quote)

      @skip_footer = true
      render layout: 'front'
    else
      render :new, layout: 'front'
    end
  end

  private

  def create_resource
    @quote = InsuranceQuote.new
  end

  def create_with_params
    @quote = InsuranceQuote.new(quote_params)
  end

  def quote_params
    params.require(:insurance_quote).permit(
      :name,
      :email,
      :phone,
      :note
    )
  end
end
