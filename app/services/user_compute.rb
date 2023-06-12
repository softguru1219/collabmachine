class UserCompute
  attr_accessor :user

  PROFILE_RATIO = 0.1
  BEHAVIOR_RATIO = 0.2
  CLIENT_RATIO = 0.3
  TALENT_RATIO = 0.2
  RELATIONS_RATIO = 0.2

  def initialize(user)
    @user = user
    @user.rating_log = ""
  end

  def compile_weight
    # system interpretation
    @profile = profile_weight
    @behavior = behavior_weight
    @client_score = client_weight
    @talent_score = talent_weight
    @relations = relation_weight

    # TODO: Info provided by user itself
    # TODO: user given attributes/values
    # TODO: admin given attributes/values
    rating = (@profile * PROFILE_RATIO) +
              (@client_score * CLIENT_RATIO) +
              (@talent_score * TALENT_RATIO) +
              (@behavior * BEHAVIOR_RATIO) +
              (@relations * RELATIONS_RATIO)

    if (all_avg = User.average(:rating)&.round(2))
      log "Average rating for all users: #{all_avg}<br>"
      compare = (rating / all_avg).round(2)
      log "Ratio current user vs group: #{compare}<br>"
    end

    log "<br>----<br>"
    log "Rough sum: #{@profile + @behavior + @relations}<br>"
    log "Compound score (balanced): #{rating}<br>"

    # The final rating is stored in the user table too for faster sort.
    # Other meta attributes are stored as a respective row (meta_attributes).
    # user_id "0" means "system entry"
    attrs = [{
      name: 'cm__rating_score',
      value: rating,
      user_id: @user.id,
      source_user_id: 0,
      visibility: 'private'
    }, {
      name: 'cm__profile_score',
      value: @profile * PROFILE_RATIO,
      user_id: @user.id,
      source_user_id: 0,
      visibility: 'private'
    }, {
      name: 'cm__client_score',
      value: @client_score * CLIENT_RATIO,
      user_id: @user.id,
      source_user_id: 0,
      visibility: 'private'
    }, {
      name: 'cm__talent_score',
      value: @talent_score * TALENT_RATIO,
      user_id: @user.id,
      source_user_id: 0,
      visibility: 'private'
    }, {
      name: 'cm__behavior_score',
      value: @behavior * BEHAVIOR_RATIO,
      user_id: @user.id,
      source_user_id: 0,
      visibility: 'private'
    }, {
      name: 'cm__relations_score',
      value: @relations * RELATIONS_RATIO,
      user_id: @user.id,
      source_user_id: 0,
      visibility: 'private'
    }]

    @user.maintain_meta_attributes(attrs)

    # Hack to send pl down in listings
    rating *= 0.8 if @user.email == 'pl@collabmachine.com' && rating != 0

    # in order to save the value to the
    # user table too (to make sorting in index happen)
    @user.rating = rating
  end

  private

  def profile_weight
    score = 0
    max = 0

    [{
      label: 'First name',
      variable: @user.first_name,
      pass_expression: @user.first_name.blank?,
      type: 'presence',
      value: 10,
      max: 10
    }, {
      label: 'Last name',
      variable: @user.last_name,
      pass_expression: @user.last_name.blank?,
      type: 'presence',
      value: 10,
      max: 10
    }, {
      label: 'Headline',
      variable: @user.headline,
      pass_expression: @user.headline.blank?,
      type: 'presence',
      value: 30,
      max: 30
    }, {
      label: 'Company',
      variable: @user.company,
      pass_expression: @user.company.blank?,
      type: 'presence',
      value: 20,
      max: 20
    }, {
      label: 'Description',
      variable: @user.description,
      pass_expression: @user.description.blank?,
      type: 'presence',
      value: 30,
      max: 30
    }, {
      label: 'Avatar',
      variable: @user.avatar_file_name,
      pass_expression: @user.avatar_file_name.blank?,
      type: 'presence',
      value: 20,
      max: 20
    }, {
      label: 'Poster image',
      variable: @user.poster_file_name,
      pass_expression: @user.poster_file_name.blank?,
      type: 'presence',
      value: 10,
      max: 10
    }].each do |check_test|
      score = check_test[:pass_expression] ? miss(score, check_test) : pass(score, check_test)
      max += check_test[:max]
    end

    # positive check
    # competences and tags

    # Admin tags ?
    #
    [{
      label: 'Tags found',
      type: 'presence',
      pass_expression: (@user.skills.count + @user.interests.count > 0),
      value: 50,
      max: 50
    }, {
      label: 'Tags: Skills',
      variable: @user.skill_list,
      pass_expression: @user.skill_list.count > 0,
      value: 20,
      max: 20
    }, {
      label: 'Tags: Interests',
      variable: @user.interest_list,
      pass_expression: @user.interest_list.count > 0,
      value: 20,
      max: 20
    }, {
      label: 'Is company profile', # Is a company (job provider maybe)
      variable: @user.profile_type,
      pass_expression: @user.profile_type == "company",
      value: 20,
      max: 20
    }].each do |check_test|
      score = check_test[:pass_expression] ? pass(score, check_test) : miss(score, check_test)
      max += check_test[:max]
    end

    log "===============================<br>"
    log "Profile sum: #{score}<br>"
    log "Profile score (ratio #{PROFILE_RATIO}): #{score * PROFILE_RATIO}<br>"
    log "<br><br>"

    score
  end

  def behavior_weight
    score = 0

    # user status is active?
    # - active means user claimed or activated his profil.
    # - can be turn off by admins to hide profiles.
    # boolean

    # logged in often or not
    crank_by = 0
    crank_by = 10 if @user.sign_in_count > 0
    crank_by = 15 if @user.sign_in_count > 10
    crank_by = 20 if @user.sign_in_count > 25
    crank_by = 30 if @user.sign_in_count > 75

    [{
      label: 'User is active (turned on)',
      variable: @user.active,
      type: 'boolean',
      pass_expression: (@user.active == true),
      value: 100,
      max: 100
    }, {
      label: 'User availability',
      variable: @user.available,
      type: 'boolean',
      pass_expression: (@user.available == true),
      value: 100,
      max: 100
    }, {
      label: 'Login frequency',
      variable: @user.sign_in_count,
      pass_expression: @user.sign_in_count,
      value: crank_by,
      max: 30
    }, {
      label: 'Last seen is today',
      # variable: @user.available,
      type: 'combined conditional',
      pass_expression: (!@user.current_sign_in_at.blank? and @user.last_seen_at&.today?),
      value: 30,
      max: 30
    }].each do |check_test|
      score = check_test[:pass_expression] ? pass(score, check_test) : miss(score, check_test)
    end

    # User is currently logged in ?
    # note: User login status must be done by using a more reliable way.
    unless @user.new_record?
      check = {
        label: 'Currently logged in.',
        variable: @user.online?,
        type: 'boolean',
        pass_expression: @user.online? == true,
        value: 50,
        max: 100
      }
      score = check[:pass_expression] ? pass(score, check) : miss(score, check)
    end

    log "===============================<br>"
    log "Behavior: #{score}<br>"
    log "Behavior score (ratio #{BEHAVIOR_RATIO}): #{score * BEHAVIOR_RATIO}"
    log "<br><br>"

    score
  end

  def client_weight
    score = 0

    log "<br>===============================<br>"
    log "User is client?"
    log "<br>===============================<br>"
    [{
      label: 'has projects (any)',
      # variable: User.where(referal: @user.id).count,
      type: 'bool',
      pass_expression: @user.projects.count > 0,
      value: 200,
      max: 200
    }].each do |check_test|
      score = check_test[:pass_expression] ? pass(score, check_test) : miss(score, check_test)
    end

    [{
      label: 'Draft projects',
      state: 'draft',
      value: 20,
      max: 20
    }, {
      label: 'For review',
      state: 'for_review',
      type: 'count',
      value: 20,
      max: 20
    }, {
      label: 'Reviewed',
      state: 'reviewed',
      type: 'count',
      value: 20,
      max: 20
    }, {
      label: 'Open for candidates',
      state: "open_for_candidates",
      type: 'count',
      value: 20,
      max: 20
    }, {
      label: 'Assigned',
      state: 'assigned',
      type: 'count',
      value: 20,
      max: 20
    }, {
      label: 'Started',
      state: 'started',
      type: 'count',
      value: 20,
      max: 20
    }, {
      label: 'Finished',
      state: 'finished',
      type: 'count',
      value: 20,
      max: 20
    }, {
      label: 'Archived',
      state: 'archived',
      type: 'count',
      value: 20,
      max: 20
    }].each do |check_test|
      missions = 0
      @user.projects.each do |p|
        missions += p.missions.where(state: check_test[:test]).count
      end

      log "#{check_test[:label]}: #{missions}"
      score = missions > 0 ? pass(score, check_test) : miss(score, check_test)
    end

    log "===============================<br>"
    log "Client score: #{score}<br>"
    log "Client score (ratio #{CLIENT_RATIO}): #{score * CLIENT_RATIO}"
    log "<br><br>"

    score
  end

  def talent_weight
    score = 0

    log "<br>===============================<br>"
    log "User is talent?"
    log "<br>===============================<br>"

    [{
      label: 'assigned on mission (any)',
      # variable: ,
      type: 'bool',
      pass_expression: Mission.assigned_to(@user).count > 0,
      value: 300,
      max: 300
    }, {
      label: 'Started missions',
      type: 'bool',
      pass_expression: Mission.assigned_to(@user).with_state(['started', 'finished', 'archived']).count > 0,
      value: 100,
      max: 100
    }, {
      label: 'has active missions',
      # variable: ,
      type: 'bool',
      pass_expression: Mission.assigned_to(@user).with_state(['started']).count > 0,
      value: 100,
      max: 100
    }, {
      label: 'Completed missions',
      type: 'bool',
      pass_expression: Mission.assigned_to(@user).with_state(['finished', 'archived']).count > 0,
      value: 200,
      max: 200
    }].each do |check_test|
      score = check_test[:pass_expression] ? pass(score, check_test) : miss(score, check_test)
    end

    log "===============================<br>"
    log "Talent score: #{score}<br>"
    log "Talent score (ratio #{TALENT_RATIO}): #{score * TALENT_RATIO}"
    log "<br><br>"

    score
  end

  def relation_weight
    score = 0

    # TODO: add followers
    # TODO: make links/friendships
    # TODO: is team player?
    check = {
      label: 'Invited people (has child)',
      # variable: User.where(referal: @user.id).count,
      type: '',
      pass_expression: User.where(invited_by_id: @user.id).count > 0,
      value: 200,
      max: 200
    }
    score = check[:pass_expression] ? pass(score, check) : miss(score, check)

    log "===============================<br>"
    log "Relations: #{score}<br>"
    log "Relations score (ratio #{RELATIONS_RATIO}): #{score * RELATIONS_RATIO}"
    log "<br><br>"

    score
  end

  def pass(variable, check)
    register(check, true)
    variable += check[:value]
    variable
  end

  def miss(variable, check)
    register(check, false)
    variable
  end

  def log(line = nil)
    if line
      @user.rating_log << line
    else
      @user.rating_log
    end
  end

  def log_message(message, state = 'false')
    log "<div class='text-#{state}'>#{message}<br></div>"
  end

  def register(check, pass = 'true')
    state = pass == true ? '' : 'danger'
    message =
      if pass
        "#{check[:value]}/#{check[:max]} : #{check[:label]} #{check[:type]}"
      else
        "0/#{check[:max]} : #{check[:label]} #{check[:type]} is FALSE"
      end
    log_message(message, state)
  end
end
