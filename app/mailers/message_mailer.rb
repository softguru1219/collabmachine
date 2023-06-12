class MessageMailer < ActionMailer::Base
  include UsersHelper
  layout false, except: [:latest_activities, :product_recommended]
  before_action :add_inline_attachment!

  def notify(message)
    @message = message
    @from = message.sender? ? message.user_sender_email : 'support@collabmachine.com'
    @to = message.audience_is_admin? ? User.admin.pluck(:email) : message.user_recipient_email
    @body = message.body || message.subject
    mail(subject: message.subject, to: @to, from: @from)
  end

  def latest_activities(user_id)
    @user = User.find(user_id).decorate
    @other_messages = Message.from_last_day.not_mission
    mail(
      subject: 'Recent activities',
      to: @user.email,
      from: 'support@collabmachine.com'
    )
  end

  def product_recommended(product:, recommended_by_user:, recommended_to_user:)
    @product = product
    @recommended_by_user = recommended_by_user
    @recommended_to_user = recommended_to_user

    mail(
      subject: t("message_mailer.product_recommended.title", user: @recommended_by_user.full_name),
      to: @recommended_to_user.email,
      from: 'support@collabmachine.com'
    )
  end

  def self.prepare_new_user(user)
    [
      "support@collabmachine.com"
    ].each do |admin_email|
      new_user(admin_email, user).deliver_now
    end
  end

  def new_user(admin_email, user)
    @user = user

    if @user.has_role? :client
      mail(
        subject: "[Admin FYI] - New client #{@user.company.capitalize} initiated profile creation.",
        to: 'support@collabmachine.com',
        from: 'support@collabmachine.com',
        template_name: 'new_client'
      )
    elsif @user.blitz_roles == ["coach"] || @user.blitz_roles == ["entrepreneur"]
      mail(
        subject: "[Admin FYI] - New #{@user.email} initiated profile creation.",
        to: admin_email,
        from: 'support@collabmachine.com',
        template_name: "new_client"
      )
    else # talent
      mail(
        subject: "[Admin FYI] - New user #{@user.email} initiated profile creation.",
        to: 'support@collabmachine.com',
        from: 'support@collabmachine.com',
        template_name: 'new_user'
      )
    end
  end

  def welcome_talent(user)
    @user = user
    mail(
      subject: "[CollabMachine] Welcome message title here",
      to: @user.email,
      from: 'support@collabmachine.com'
    )
  end

  def registration_completed(user)
    @user = user
    mail(
      subject: "[CollabMachine] Registration completed",
      to: @user.email,
      from: 'support@collabmachine.com'
    )
  end

  def newcomer_to_validate(user)
    @user = user
    mail(
      subject: "[Admin action required] - New user #{@user.first_name.capitalize} is requesting your approval/to validate",
      to: 'support@collabmachine.com',
      from: 'support@collabmachine.com',
      template_name: 'new_user'
    )
  end

  def send_onboarding_message(message)
    @message = message
    @subject = message[:title]
    @from = message[:sender]
    @to = message[:recipient]
    @body = message[:body]

    mail(
      subject: @subject,
      to: @to,
      from: @from,
      template_name: 'blank'
    )
  end

  def send_message_to_merchant(message)
    @message = message
    @subject = message[:title]
    @from = message[:sender]
    @to = message[:recipient]
    @body = message[:body]

    mail(
      subject: @subject,
      to: @to,
      from: @from,
      template_name: 'blank'
    )
  end

  def send_message_to_merchant_bigblue(message)
    @message = message
    @subject = message[:title]
    @from = message[:sender]
    @reply_to = message[:bigblue]
    @to = message[:recipient]
    @body = message[:body]

    mail(
      subject: @subject,
      to: @to,
      reply_to: @reply_to,
      from: @from,
      template_name: 'blank'
    )
  end

  def send_message_to_admin_partner(message)
    @message = message
    @subject = message[:title]
    @from = message[:sender]
    @to = 'support@collabmachine.com'
    @body = message[:body]

    mail(
      subject: @subject,
      to: @to,
      from: @from,
      template_name: 'blank'
    )
  end

  def send_message_to_admin_partner_bigblue(message)
    @message = message
    @subject = message[:title]
    @from = message[:bigblue]
    @to = 'support@collabmachine.com'
    @body = message[:body]

    mail(
      subject: @subject,
      to: @to,
      reply_to: @reply_to,
      from: @from,
      template_name: 'blank'
    )
  end

  def send_user_message(user_message)
    @message = user_message
    @title = @message[:title]
    @body = @message[:message]
    @user = user_message.anonymous ? "anonymous" : User.find(@message[:user_id]).username

    mail(
      subject: "#{@user} left a message: #{@title}!",
      to: "support@collabmachine.com",

      from: "support@collabmachine.com",
      template_name: 'user_message'
    )
  end

  def purchase_receipt(purchase)
    @purchase = purchase

    mail(
      subject: "Receipt for your CollabMachine Purchase",
      to: purchase.user.email,
      from: 'support@collabmachine.com'
    )
  end

  def self.notify_admin_mission_review(mission)
    @mission = mission
    admins = User.admin
    @user = mission.user
    admins.each do |admin|
      send_admin_review_email(admin, @mission, @user).deliver_now
    end
  end

  def send_admin_review_email(admin, mission, user)
    @user = user
    @admin = admin
    @mission = mission
    mail(
      subject: "Mission Review Request",
      to: @admin.email.to_s,
      from: 'support@collabmachine.com',
      template_name: "mission_review"
    )
  end

  # product review email

  def self.notify_admin_product_review(product)
    @product = product
    admins = User.admin
    @user = product.user
    admins.each do |admin|
      send_admin_product_submitted_email(admin, @product, @user).deliver_now
    end
  end

  def send_admin_product_submitted_email(admin, product, user)
    @user = user
    @admin = admin
    @product = product
    mail(
      subject: "New Product Submitted",
      to: @admin.email.to_s,
      from: 'support@collabmachine.com',
      template_name: "product_review"
    )
  end

  def self.assigned_mission(applicant)
    @applicant = applicant
    @user = applicant.user
    @owner = @applicant.mission.project.user
    @mission = @applicant.mission

    [
      [@owner, 'owner', @user],
      [@user, 'user', @owner]
    ].each do |userarray|
      send_assign_email(userarray).deliver_now
    end
  end

  def send_assign_email(userarray)
    template = userarray[1]
    @user = userarray[0]
    @app = userarray[2]
    mail(
      subject: "Mission Assigned Confirmation",
      to: @user.email.to_s,
      from: 'support@collabmachine.com',
      template_name: "#{template}_assigned"
    )
  end

  def self.prepare_new_quick_estimate(estimate)
    [
      "pl@collabmachine.com",
      "sebastien@collabmachine.com"
    ].each do |admin_email|
      new_quick_estimate(admin_email, estimate).deliver_now
    end
  end

  def new_quick_estimate(admin_email, estimate)
    @estimate = estimate
    mail(
      subject: '[CollabMachine] - New quick estimate to look at.',
      to: admin_email,
      from: 'support@collabmachine.com'
    ) do |format|
      format.html { render 'new_quick_estimate' }
    end
  end

  def self.prepare_quick_insurance_quote(quote)
    return unless Rails.env.production?

    [
      "jason.cabral@laturquoise.ca",
      "arnouff@gmail.com",
      "claire-helene.michaud@laturquoise.ca",
      "kevin.nadeau@laturquoise.ca",
      "mathieu.dufresne@laturquoise.ca",
      "support@collabmachine.com",
      "pl@collabmachine.com"
    ].each do |recipient|
      new_quick_insurance_quote(recipient, quote).deliver_now
    end
  end

  def new_quick_insurance_quote(recipient, quote)
    @quote = quote

    mail(
      subject: "[CollabMachine] - Nouvelle demande de soumission",
      to: recipient,
      from: 'support@collabmachine.com'
    ) do |format|
      format.html { render 'new_quick_insurance_quote' }
    end
  end

  def self.prepare_suggested_for_mission(recipient, user, mission)
    [
      recipient.email,
      "pl@collabmachine.com",
      "sebastien@collabmachine.com"
    ].each do |target_email|
      suggested_for_mission(recipient, user, mission, target_email).deliver_now
    end
  end

  def suggested_for_mission(recipient, user, mission, target_email)
    @mission = mission
    @username = name_or_handle(user)
    @recipientname = name_or_handle(recipient)
    @recipient = recipient

    mention = recipient.email == target_email ? '' : "[FYI-Admin]"

    mail(
      subject: "[CollabMachine]#{mention} - #{@username} thinks you may be interested in #{@mission.title}",
      to: target_email,
      from: 'support@collabmachine.com'
    ) do |format|
      format.html { render 'suggested_for_mission' }
    end
  end

  def blitz_profile_created(user)
    @user = user
    mail(
      subject: 'Bienvenue au Blitz Coaching Défi Montréal!',
      to: @user.email,
      # cc: "pl@collabmachine.com",
      from: 'support@collabmachine.com'
    )
  end

  def self.send_wip_results(specialtyId)
    @specialty = Specialty.find(specialtyId)
    target_email = @specialty.user.email
    mail(
      subject: 'Bienvenue au Blitz Coaching Défi Montréal!',
      to: target_email,
      from: 'support@collabmachine.com'
    )
  end

  def layout; end

  private

  def add_inline_attachment!
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo/black/Collab-Machine-logo-6.png")
    attachments.inline['customer-management.png'] = File.read("#{Rails.root}/app/assets/images/icons/customer-management.png")
  end
end