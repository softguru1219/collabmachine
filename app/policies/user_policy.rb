class UserPolicy < AuthenticatedPolicy
  include BlitzHelper

  def admin?
    user.admin?
  end

  def blitz_admin?
    [
      'sale@veeza-v.com',
      'crobert@defimtl.com',
      'mduchaine@defimtl.com',
      'martin@defimtl.com',
      'pl@collabmachine.com',
      'masoud.arabi2030@gmail.com',
      'alisaib.diallo@gmail.com',
      'dg@quetal.cc',
      'andres@quetal.cc',
      'hindm2912@gmail.com'
    ].include?(user.email)
  end

  def participant_mastermind_automne_2021?
    [
      'gbourque@houstonconseils.ca',
      'elhadj.bah.ti@gmail.com',
      'martin.rodrigue@servicesconseils.ca',
      'emeline@emdeveloppement.ca',
      'guy.bernadet@azureo.ca',
      'info@lemaitrecoaching.com',
      'laurence@laurencebozec.com',
      'christian.beaubien2021@gmail.com',
      'pl@collabmachine.com',
      'masoud.arabi2030@gmail.com'
    ].include?(user.email)
  end

  def my_profile?
    user.id == record.id
  end

  def admin_or_mine?
    admin? or my_profile?
  end

  def index?
    true
  end

  def admin_index?
    user.admin?
  end

  def show?
    true
    # return true if user
  end

  def can_filter_tags?
    user.gte_premium?
  end

  def can_filter_profile_type?
    user.gte_platinum?
  end

  def create?
    return true if user.admin?
  end

  def update?
    admin_or_mine?
  end

  def destroy?
    admin_or_mine?
  end

  def payment_information?
    user
  end

  def update_payment_information?
    true
  end

  def send_invitation?
    user.gte_premium?
  end

  alias trousse_participant_automne_2021? participant_mastermind_automne_2021?

  def resend_invitation?
    admin?
  end

  def fetch_user_data?
    admin?
  end

  def fetch_all_users_data?
    admin?
  end

  def fetch_blitz_users?
    admin?
  end

  def import_coachs?
    admin? or blitz_admin?
  end

  def import_participants?
    admin? or blitz_admin?
  end

  def export_participants?
    admin? or blitz_admin?
  end

  def export_coachs?
    admin? or blitz_admin?
  end

  def slack_users?
    admin?
  end

  def metrics?
    admin?
  end

  def missions?
    user.admin?
  end

  def send_onboarding_message?
    user.admin?
  end

  def users?
    user.admin?
  end

  def blitz_context?
    blitz_admin? ||
      (user.admin_tag_list.include?(next_blitz_tag) && record.admin_tag_list.include?(next_blitz_tag))
  end

  def see_personal_info?
    user == record || blitz_context? || user.gte_premium?
  end

  def see_personal_info_gte_platinum?
    user == record || user.gte_platinum?
  end
end
