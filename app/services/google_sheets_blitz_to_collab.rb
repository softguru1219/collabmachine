require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class GoogleSheetsBlitzToCollab
  include BlitzHelper

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
  CREDENTIALS_PATH = "credentials.json".freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

  # 2020-12-03 : was  "1LYACE4s-ZPWjHrPzI0ZnR1vt4It6x5NOOzlaqfgkvTI"
  # 2021-02-18 : "1zcZrNO037z555XkzNnEwLZTOcI4deFLikG0gGPfWUDk"
  # EVENT_SPREADSHEET_ID = "1yde6OeIw3VJcvzKyBREXXivZbhz7KL9wA09PNJWGNN4".freeze
  # 2021-03-25 : "1yde6OeIw3VJcvzKyBREXXivZbhz7KL9wA09PNJWGNN4".freeze
  # 2021-05-27: EVENT_SPREADSHEET_ID = "1LC8cmNhKrI-Q2S7v4ZmkstKQrU7VcICoz4ju240xl50".freeze
  # 2021-08-12: EVENT_SPREADSHEET_ID = "1SlQAD3EIG4a_5OgpNmGoF5U7-d5HT3rAiKflpHjAaiA".freeze
  # 2021-10-21: EVENT_SPREADSHEET_ID = "14R4hgn0XmxFKFbXXjHIlO6tk6jhNOjlrFEXyDgsahNA".freeze
  # 2021-12-02: EVENT_SPREADSHEET_ID = "1QuH8I1xzikwtwk48PB1r7_HMdm7st8B0ql-zVheW_bw".freeze
  # EVENT_SPREADSHEET_ID = "1E9aoKrHcm7_A9Lc6PPoDyJZyJS0cyl4OjyRwGjtGM_k".freeze
  # 2022-03-17 EVENT_SPREADSHEET_ID = "18FVN5Myaw8VAqkladj2Op2mb8_GBBMVfhZWqtMkwDkI".freeze
  # 2022-05-19 EVENT_SPREADSHEET_ID = "1KPLa4Og6LuEVGWWxJGKwXcebifm_AR4ZQYO9Nb3z4cI".freeze
  # 2022-07-28 EVENT_SPREADSHEET_ID = "19Eei5FOC95pXnHqFedpyi0ZvwN6KCuKGx3bd-QKcbV0".freeze

  # 2022-10-06
  EVENT_SPREADSHEET_ID = "1lyjVzvPUHjUdxGccTUVfoZEF4FL5GgRViSHJLhbZ-O0".freeze

  attr_accessor :selection

  # ['all']
  # ['email','email']
  def initialize(selection:)
    @selection = selection
  end

  def call
    # old_logger = ActiveRecord::Base.logger
    # ActiveRecord::Base.logger = nil
    ActiveRecord::Base.logger.level = Logger::INFO
    # To turn it back on:
    # ActiveRecord::Base.logger = old_logger
    sync_from_google_sheet
  end

  def import_coachs
    ActiveRecord::Base.logger.level = Logger::INFO
    import_coachs_from_sheet
  end

  def import_participants
    ActiveRecord::Base.logger.level = Logger::INFO
    import_participants_from_sheet
  end

  def export_participants
    ActiveRecord::Base.logger.level = Logger::INFO
    export_participants_to_sheet
  end

  def export_coachs
    ActiveRecord::Base.logger.level = Logger::INFO
    export_coachs_to_sheet
  end

  private

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts "Open the following URL in the browser and enter the " \
           "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def build_attributes(row, v, user_id)
    # Prepare attributes for the row (all cells)
    # # Attribute skeleton
    # [{
    #   name: 'cm_rating_score',
    #   value: value,
    #   user_id: user_id,
    #   source_user_id: 0,
    #   visibility: 'private'
    # }], ...]

    attrs = []
    skip_list = %w(email fullname firstname lastname cm__id displayname)

    v.each do |title, _val|
      next if skip_list.include?(title.to_s)

      attrs.push({
        name: title.to_s,
        value: row[v[title]],
        user_id: user_id,
        source_user_id: 0,  # as system
        visibility: 'private'
      })
    end
    attrs
  end

  def service_build_up
    @service_build_up ||= begin
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
      service
    end
  end

  def sync_from_google_sheet
    {
      participants: fetch_participants,
      coachs: fetch_schedule_coachs
    }
  end

  def fetch_participants
    service = service_build_up

    range = "Participants!A1:AF1"
    titles = service.get_spreadsheet_values(EVENT_SPREADSHEET_ID, range)

    range = "Participants!A2:AF"
    rows = service.get_spreadsheet_values(EVENT_SPREADSHEET_ID, range)

    # Map titles
    v = {
      PROCESS: -1,
      SYNC: -1,
      Prénom: -1,
      Nom: -1,
      Role: -1,
      Email: -1,
      Téléphone: -1,
      'Secteur principal': -1,
      Organisation: -1,
      Domaines: -1,
      Demandes: -1,
      'Notes publiques': -1,
      'Salle jitsi': -1,
      Linkedin: -1,
      'Site web': -1,
      'Nom complet': -1,
      'Utilisateur::Email': -1
    }

    v.each do |k, _val|
      v[k] = titles.values.first.find_index(k.to_s)
    end

    { titles: titles, col_names: v, rows: rows }
  end

  def fetch_schedule_coachs
    service = service_build_up

    range = "Rencontres Coachs!A1:AE1"
    titles = service.get_spreadsheet_values(EVENT_SPREADSHEET_ID, range)

    range = "Rencontres Coachs!A2:AE"
    rows = service.get_spreadsheet_values(EVENT_SPREADSHEET_ID, range)

    # Map titles
    v = {
      PROCESS: -1,
      SYNC: -1,
      Prénom: -1,
      Nom: -1,
      Role: -1,
      Email: -1,
      Téléphone: -1,
      'Secteur principal': -1,
      Organisation: -1,
      Domaines: -1,
      'Notes publiques': -1,
      'Salle jitsi': -1,
      Linkedin: -1,
      'Site web': -1,
      'Nom complet': -1
    }

    v.each do |k, _val|
      v[k] = titles.values.first.find_index(k.to_s)
    end

    { titles: titles, col_names: v, rows: rows }
  end

  # def fetch_blitz_users
  #   service = service_build_up

  #   # 2020-12-03 : spreadsheet_id = "1LYACE4s-ZPWjHrPzI0ZnR1vt4It6x5NOOzlaqfgkvTI"
  #   # 2021-02-18
  #   spreadsheet_id = "1zcZrNO037z555XkzNnEwLZTOcI4deFLikG0gGPfWUDk"

  #   # range = "ALL!A:BH"
  #   range = "ALL!A1:BH2"

  #   service.get_spreadsheet_values spreadsheet_id, range
  # end

  # to create/update profiles
  def import_coachs_from_sheet
    msg = []
    response = fetch_schedule_coachs

    # runtime params
    dry_run = false # set to false to save entries at run time
    activation = true
    pending = false
    # runtime params
    created = 0
    updated = 0
    unprocessed = 0

    if response.values.empty?
      msg.push("No data found.")
    else

      skip_list = %w[
        juliend2@gmail.com
        gsaad@spektrummedia.com
        tamara@magnificentsystems.com
        support@collabmachine.com
      ]

      v = response[:col_names]
      response[:rows].values.each do |row|
        next if row[v[:Email]].nil?
        next if @selection != ['all'] && (@selection.include?(row[v[:Email]]) == false)

        msg.push "Processing #{row[v[:Email]]} ..."

        if skip_list.include?(row[v[:Email]])
          msg.push "-- skip #{row[v[:Email]]}"
          next
        end

        if row[v[:PROCESS]] == "FALSE"
          msg.push "-- Skip #{row[v[:Email]]}: PROCESS is set to FALSE"
          next
        end

        if row[v[:SYNC]] == "FALSE"
          msg.push "-- Skip #{row[v[:Email]]}: SYNC is set to FALSE"
          next
        end

        if row[v[:Email]] == ""
          msg.push "===> !!! No email for this line: see #{row[v[:Prénom]]} #{row[v[:Nom]]}"
          unprocessed += 1

        elsif (found_user = User.find_by_email(row[v[:Email]]))
          found_user.company = row[v[:Organisation]]
          found_user.phone = row[v[:Téléphone]]
          found_user.linkedin_url = row[v[:Linkedin]]
          found_user.blitz_roles = [row[v[:Role]]]
          found_user.web_site_url = row[v[:'Site web']]
          found_user.save

          msg.push "-- User found, updating attributes for: #{found_user.full_name}."
          attrs = build_attributes(row, v, found_user.id)
          found_user.maintain_meta_attributes(attrs)
          updated += 1

        else
          msg.push "-- Creating user (#{row[v[:Email]]})"
          # rand_pass = (0...12).map { ('a'..'z').to_a[rand(26)] }.join
          pass = 'blitzcoaching20210325'

          u = User.new(
            email: row[v[:Email]],
            password: pass,
            password_confirmation: pass,
            first_name: row[v[:Prénom]],
            last_name: row[v[:Nom]],
            company: row[v[:Organisation]],
            phone: row[v[:Téléphone]],
            linkedin_url: row[v[:Linkedin]],
            blitz_roles: [row[v[:Role]]],
            web_site_url: row[v[:'Site web']],
            balance: 0,
            active: activation,
            pending: pending
          )

          u.save
          attrs = build_attributes(row, v, u.id)
          u.maintain_meta_attributes(attrs)

          if Rails.env.production?
            MessageMailer.blitz_profile_created(u).deliver_now
          else
            msg.push ">> This is development mode"
            msg.push ">>> would send mail."
            msg.push "--------------------"
          end

          created += 1
        end
        # set slack user id and slack profile if user exist and slack data exists
      end

      msg.push "Total updated users: #{updated}"
      msg.push "Total created users: #{created}"
      msg.push "Total unprocessed users: #{unprocessed}"
      msg.push "Run mode: #{dry_run ? 'dry run (nothing created)' : 'not dry run'}"
    end
    { messages: msg }
  end

  def import_participants_from_sheet
    msg = []
    response = fetch_participants

    # runtime params
    dry_run = false # set to false to save entries at run time
    activation = true
    pending = false
    # runtime params
    created = 0
    updated = 0
    unprocessed = 0

    if response.values.empty?
      msg.push("No data found.")
    else

      skip_list = %w[
        juliend2@gmail.com
        gsaad@spektrummedia.com
        tamara@magnificentsystems.com
        support@collabmachine.com
      ]

      v = response[:col_names]
      response[:rows].values.each do |row|
        next if row[v[:Email]].nil?

        next if @selection != ['all'] && (@selection.include?(row[v[:Email]]) == false)

        if skip_list.include?(row[v[:Email]])
          msg.push "-- skip #{row[v[:Email]]}"
          next
        end

        msg.push "Processing #{row[v[:Email]]} ..."

        if row[v[:PROCESS]] == "FALSE"
          msg.push "-- Skip #{row[v[:Email]]}: PROCESS is set to FALSE"
          next
        end

        if row[v[:SYNC]] == "FALSE"
          msg.push "-- Skip #{row[v[:Email]]}: SYNC is set to FALSE"
          next
        end

        if row[v[:Email]] == ""
          msg.push "==> !!! No email for this line: see #{row[v[:Prénom]]} #{row[v[:Nom]]}"
          unprocessed += 1

        elsif (found_user = User.find_by_email(row[v[:Email]]))
          found_user.company = row[v[:Organisation]]
          found_user.phone = row[v[:Téléphone]]
          found_user.linkedin_url = row[v[:Linkedin]]
          found_user.blitz_roles = [row[v[:Role]]]
          found_user.web_site_url = row[v[:'Site web']]
          found_user.save

          msg.push "-- User found, updating attributes for: #{found_user.full_name}."
          attrs = build_attributes(row, v, found_user.id)
          found_user.maintain_meta_attributes(attrs)
          updated += 1

        else
          msg.push "-- Creating user (#{row[v[:Email]]})"
          # rand_pass = (0...12).map { ('a'..'z').to_a[rand(26)] }.join
          pass = 'blitzcoaching20210812'

          u = User.new(
            email: row[v[:Email]],
            password: pass,
            password_confirmation: pass,
            first_name: row[v[:Prénom]],
            last_name: row[v[:Nom]],
            company: row[v[:Organisation]],
            phone: row[v[:Téléphone]],
            linkedin_url: row[v[:Linkedin]],
            blitz_roles: [row[v[:Role]]],
            web_site_url: row[v[:'Site web']],
            balance: 0,
            active: activation,
            pending: pending
          )
          # p u.inspect

          u.save
          attrs = build_attributes(row, v, u.id)
          u.maintain_meta_attributes(attrs)

          if Rails.env.production?
            MessageMailer.blitz_profile_created(u).deliver_now
          else
            msg.push ">> This is development mode"
            msg.push ">>> would send mail."
            msg.push "--------------------"
          end

          created += 1
        end
        # set slack user id and slack profile if user exist and slack data exists
      end

      msg.push "Total updated users: #{updated}"
      msg.push "Total created users: #{created}"
      msg.push "Total unprocessed users: #{unprocessed}"
      msg.push "Run mode: #{dry_run ? 'dry run (nothing created)' : 'not dry run'}"
    end
    { messages: msg }
  end

  def export_participants_to_sheet
    service = service_build_up
    range = 'Listing-entrepreneurs!A1:U'

    clear_sheet(range)
    puts "####clear entrepreneurs####"
    value_input_option = 'RAW'
    values = [["Horodatage", "Adresse de courriel", "Prénom", "Nom de famille",
               "Avez-vous déjà un Profil de coach sur CollabMachine.com suite à une édition précédente ?",
               "Réseau(x) de soutien aux entrepreneurs", "Nom de la société / Raison sociale",
               "Description de votre expertise / Slogan", "Site web",
               "Numéro de cellulaire (disponible pendant le Blitz)", "Page Linkedin",
               "Premier secteur d'expertise recherché", "Deuxième secteur d'expertise recherché",
               "Troisième secteur d'expertise recherché", "Besoins particuliers / Questions à aborder",
               "Noms de coachs-experts particulier à rencontrer",
               "Disponibilité pour rencontres 30 minutes avec les Coachs-Experts", "Plages de disponibilité",
               "DANS LA LISTE ?", "ID", "Role"]]

    # request_body = Google::Apis::SheetsV4::ValueRange.new
    users_blitz = User.tagged_with(next_blitz_tag, on: 'admin_tags')
    unless users_blitz&.nil?
      users_blitz.each do |user|
        next unless user.blitz_roles.include?('entrepreneur') or user.blitz_roles.include?('Entrepreneur')

        values << [user.updated_at, user.email, user.first_name, user.last_name,
                   user.profile_type, user.communities.reject(&:empty?).join(', '),
                   user.company, user.slogan, user.web_site_url, user.phone,
                   user.linkedin_url, user.area_of_expertise_1, user.area_of_expertise_2,
                   user.area_of_expertise_3, " ", user.ask_meeting_with, " ",
                   user.blitz_availability.reject(&:empty?).join(', '), " ", user.id,
                   'entrepreneur']
      end
    end

    value_range_object = Google::Apis::SheetsV4::ValueRange.new(range: range,
                                                                values: values)
    result = service.update_spreadsheet_value(EVENT_SPREADSHEET_ID,
                                              range,
                                              value_range_object,
                                              value_input_option: value_input_option)
    puts "####entrepreneurs#### #{result.updated_cells} cells updated.#######"
  end

  def export_coachs_to_sheet
    service = service_build_up
    range = 'Listing-coachs!A1:Q'

    # request_body = Google::Apis::SheetsV4::ClearValuesRequest.new
    # response = service.clear_values(EVENT_SPREADSHEET_ID, range, request_body)
    clear_sheet(range)
    puts "####clear coachs####"
    value_input_option = 'RAW'
    values = [["Horodatage", "Adresse de courriel", "Prénom", "Nom de famille",
               "Avez-vous déjà un Profil de coach sur CollabMachine.com suite à une édition précédente ?",
               "Réseau(x) de soutien aux entrepreneurs", "Nom de la société / Raison sociale",
               "Site web", "Numéro de cellulaire (disponible pendant le Blitz)", "Page Linkedin",
               "Secteur d'expertise principal", "Description de votre expertise / Slogan",
               "Disponibilité pour rencontres 30 minutes avec les entrepreneurs et dirigeants", "Plages de disponibilité",
               "DANS LA LISTE ?", "ID", "Role"]]

    # request_body = Google::Apis::SheetsV4::ValueRange.new
    users_blitz = User.tagged_with(next_blitz_tag, on: 'admin_tags')
    unless users_blitz&.nil?
      users_blitz.each do |user|
        next unless user.blitz_roles.include?('coach') or user.blitz_roles.include?('Coach')

        values << [user.updated_at, user.email, user.first_name,
                   user.last_name, user.profile_type, user.communities.reject(&:empty?).join(', '),
                   user.company, user.web_site_url, user.phone,
                   user.linkedin_url, user.area_of_expertise_1,
                   user.slogan, " ", user.blitz_availability.reject(&:empty?).join(', '),
                   " ", user.id, 'coach']
      end
    end

    value_range_object = Google::Apis::SheetsV4::ValueRange.new(range: range,
                                                                values: values)
    result = service.update_spreadsheet_value(EVENT_SPREADSHEET_ID,
                                              range,
                                              value_range_object,
                                              value_input_option: value_input_option)
    puts "####coachs#### #{result.updated_cells} cells updated.#######"
  end

  def clear_sheet(range)
    service = service_build_up
    request_body = Google::Apis::SheetsV4::ClearValuesRequest.new
    service.clear_values(EVENT_SPREADSHEET_ID, range, request_body)
  end
end
