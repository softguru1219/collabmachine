class Mission < ActiveRecord::Base
  acts_as_paranoid # soft deletes
  acts_as_taggable_on :tags

  # will paginate
  self.per_page = 25

  belongs_to :project
  has_one :user, through: :project
  delegate :user_id,
           :title,
           :description,
           :admin_client,
           :admin_client_summary,
           :admin_references_links,
           :admin_project_type,
           :admin_talents_resources,
           :admin_budget,
           :admin_delivery,
           :admin_position_in_process,
           :admin_extra_info,
           to: :project, prefix: true, allow_nil: true
  delegate :state, to: :mission, prefix: true, allow_nil: true

  has_many :applicants
  has_many :users, through: :applicants
  has_many :messages, as: :item
  has_many :invoice_parents, as: :invoiceable
  has_many :invoices, through: :invoice_parents

  before_validation :default_title, on: :create

  filterrific(
    available_filters: [
      :by_state,
      :by_user,
      :by_assignee,
      :by_search,
      :by_tags
    ]
  )

  scope :by_state, lambda { |state|
    where(state:  state)
  }

  scope :by_tags, lambda { |tags|
    return nil  if tags.blank? or (tags.count <= 1 and tags[0] == '')

    tagged_with(tags).distinct
  }

  scope :by_assignee, lambda { |assignee_id|
    where('applicants.user_id = ? and applicants.state = ? ', assignee_id, "assigned").joins(:applicants)
  }

  scope :with_open_for_candidate, lambda { |open_for_candidate|
    where(open_for_candidate: open_for_candidate)
  }

  scope :by_user, ->(user_id) { joins(:project).where(projects: { user_id: user_id }) }

  scope :by_search, lambda { |query|
    return nil  if query.blank?

    terms = query.to_s.downcase.split(/\s+/)

    terms = terms.map do |e|
      "%#{e.tr('*', '%')}%".gsub(/%+/, '%')
    end

    num_or_conds = 2

    where(
      terms.map do
        "(LOWER(missions.title) LIKE ? OR
        LOWER(missions.description) LIKE ?)"
      end.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :assigned_to, lambda { |user|
    mission_assigned_to_user_ids = Applicant.includes(:mission)
      .where(user_id: user.id, state: "assigned").pluck(:mission_id)
    where(id: mission_assigned_to_user_ids)
  }

  scope :with_state, ->(state) { where(state: state) }

  # NOTE: this is not actually used as documented to define an AR enum
  # the attribute name is `state` not `states`
  enum states: {
    draft: I18n.t('status.draft.title'),
    for_review: I18n.t('status.for_review.title'),
    reviewed: I18n.t('status.reviewed.title'),
    open_for_candidates: I18n.t('status.open_for_candidates.title'),
    assigned: I18n.t('status.assigned.title'),
    started: I18n.t('status.started.title'),
    finished: I18n.t('status.finished.title'),
    archived: I18n.t('status.archived.title')
  }

  state_machine :state, initial: :draft do
    after_transition(on: :submit)             { |mission, action| Notifier.call(mission, action.event, audience: Message.audiences.admin) }
    after_transition(on: :review)             { |mission, action| Notifier.call(mission, action.event) }
    after_transition(on: :invite_candidates)  { |mission, action| Notifier.call(mission, action.event, audience: Message.audiences.public) }
    after_transition(on: :start)              { |mission, action| Notifier.call(mission, action.event) }
    after_transition(on: :reopen)             { |mission, action| Notifier.call(mission, action.event) }
    after_transition(on: :finish)             { |mission, action| Notifier.call(mission, action.event) }
    after_transition(on: :assign)             { |mission, action| Notifier.call(mission, action.event, recipient: mission.assignment.notification_default_recipient) if mission.assignment }
    after_transition(on: :archive)            { |mission, action| Notifier.call(mission, action.event, recipient: mission.assignment.notification_default_recipient) if mission.assignment }

    # the project owner submit the project for review.
    event :submit do
      transition draft: :for_review
    end

    # A project needs to be reviewed before anyone can apply to work on it
    # A reviewed project can be assigned, can be worked
    event :review do
      transition for_review: :reviewed
    end

    event :invite_candidates do
      transition [:started, :assigned, :reviewed] => :open_for_candidates
    end

    event :assign do
      transition [:open_for_candidates, :reviewed] => :assigned
    end

    event :start do
      transition assigned: :started
    end

    event :finish do
      transition [:started] => :finished
    end

    event :reopen do
      transition [:finished] => :started
    end

    event :archive do
      transition [:draft, :for_review, :reviewed, :open_for_candidates, :assigned, :started,  :finished] => :archived
    end
  end

  def default_title
    self.title = "Mission for project" if self.title.nil?
  end

  # returns the assignee (user) or nil
  def assignee
    assignment&.user
  end

  def assigned?
    assignee
  end

  def assignee_id
    assignee.try(:id) || false
  end

  def assignment
    Applicant.find_by(mission_id: self.id, state: "assigned")
  end

  def unassign
    assignment&.update(state: 'rejected')
  end

  def notification_default_sender
    self.project_user_id
  end

  def notification_default_recipient
    self.project_user_id
  end

  def notification_attributes
    {
      id: self.id,
      title: self.title,
      project_title: self.project_title,
      applicant_first_name: self.assignee&.first_name,
      applicant_last_name: self.assignee&.last_name
    }
  end
end
