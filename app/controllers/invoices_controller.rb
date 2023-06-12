class InvoicesController < ApplicationController
  before_action :check_terms, only: %i[new create edit update destroy]
  before_action :create_resource, only: :create
  before_action :find_resource, only: %i[edit update show destroy pay update_payment_information]
  before_action :authorize_resource, only: %i[create edit update destroy pay]
  before_action :verify_stripe_logged_in, only: %i[new create edit update destroy pay]
  skip_before_action :authenticate_user!, only: %i[show update_payment_information]

  def index
    @filterrific = initialize_filterrific(
      Invoice,
      params[:filterrific],
      persistence_id: 'shared_key',
      sanitize_params: true
    ) or return
    @invoices = @filterrific.find.page(params[:page])

    @created_invoices = policy_scope(@invoices.where(user: current_user)).to_a
    @customer_invoices = policy_scope(@invoices.where(customer: current_user)).to_a
    @body_classes = "bg-light"
  end

  def new
    @invoice = Invoice.new
    @invoice.projects = Project.where(id: params[:project])
    @invoice.missions = Mission.where(id: params[:mission])

    3.times { @invoice.invoice_lines.build }
  end

  def create
    @invoice.user = current_user
    if invoice_params[:customer_id].blank?
      @invoice.customer_id = current_user.id
      @invoice.public_token = Digest::SHA1.hexdigest([Time.now, rand].join)
    end
    totals = mission_amount_table
    3.times { @invoice.invoice_lines.build } unless InvoiceCreator.new(invoice: @invoice).call && @invoice.invoice_lines.empty?

    update_parent_amount(totals)

    if invoice_params[:mission].empty?
      respond_with @invoice, location: invoices_path
    else
      respond_with @invoice, location: mission_path(invoice_params[:mission])
    end
  end

  def edit
  end

  def show
    raise Pundit::NotAuthorizedError, "Not authorize" unless can_see_the_invoice?

    unless current_user
      if params[:token] and params[:token] == @invoice.public_token
        @from_externe = true
        @stripe_customer = true
      else
        raise Pundit::NotAuthorizedError, "must be logged in"
      end
    end

    @app_fee_rate = @invoice.app_fee_rate
  end

  def update
    @invoice.public_token = nil unless invoice_params["customer_id"].blank?
    @invoice.update(invoice_params.to_h.without('mission'))
    totals = mission_amount_table
    update_parent_amount(totals)
    respond_with @invoice, location: invoices_path
  end

  def destroy
    @invoice.destroy
    respond_to do |format|
      format.js
      format.html { respond_with Invoice, location: invoices_path }
    end
  end

  def update_payment_information
    if params[:stripe_temporary_token] && update_stripe_customer
      if @invoice.paid?
        redirect_to invoices_path, alert: 'The invoice is already paid'
      else
        transaction = Transaction.create(invoice: @invoice)
        StripeChargeCreator.new(transaction: transaction, customer: @stripe_customer).call if transaction.persisted?
        respond_with transaction, location: invoice_path(@invoice, token: @invoice.public_token)
      end
    else
      render json: {}, status: :unprocessable_enitity
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(
      :user_id,
      :customer_id,
      :external_name,
      :external_email,
      :description,
      :mission,
      mission_ids: [],
      project_ids: [],
      invoice_lines_attributes: [
        :id,
        :invoice_id,
        :rate,
        :description,
        :quantity,
        :mission_id,
        { tax_ids: [] }
      ]
    )
  end

  def can_see_the_invoice?
    if current_user.present?
      current_user.admin? or
      @invoice.user_id == current_user.id or
      @invoice.customer_id == current_user.id
    else
      params[:token] and params[:token] == @invoice.public_token
    end
  end

  def create_resource
    @invoice = Invoice.new(invoice_params.to_h.without('mission'))
  end

  def authorize_resource
    authorize @invoice
  end

  def verify_stripe_logged_in
    redirect_to invoices_path, alert: I18n.t('notifications.invoices.not_connected_to_stripe') unless current_user.stripe_profile
  end

  def find_resource
    @invoice = Invoice.find(params[:id])
  end

  def update_stripe_customer
    stripe_temporary_token = params[:stripe_temporary_token]
    @stripe_customer = Stripe::Customer.new(
      description: @invoice.external_name,
      email: @invoice.external_email
    )
    @stripe_customer.source = stripe_temporary_token
    @stripe_customer.save
  end

  def mission_amount_table
    totals = []
    @invoice.invoice_lines.each do |line|
      if line.rate > 0
        if totals.none? { |h| h[:id] == line.mission_id }
          totals.push(
            id: line.mission_id,
            sum: line.amount_without_tax
          )
        else
          hash = totals.find { |h| h[:id] == line.mission_id }
          hash[:sum] += line.amount_without_tax
        end
      end
    end
    totals
  end

  def update_parent_amount(totals)
    @invoice.invoice_parents.where(invoiceable_type: "Mission").destroy_all
    totals.each do |total|
      InvoiceParent.create(invoiceable_type: "Mission", invoiceable_id: total[:id], invoice_id: @invoice.id, total: total[:sum])
    end
  end
end
