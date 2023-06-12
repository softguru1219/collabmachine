require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class GoogleSheetsToCollab
  include BlitzHelper

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
  CREDENTIALS_PATH = "credentials.json".freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

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

      row[v[title]] = DateTime.now if title == :cm__last_sync

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

  def fetch_from_sheet
    # Initialize the API
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # Selection in the spreadsheet
    spreadsheet_id = "1K6yN1qb4tNiZF3u6ud0-MtRuTiAuBngLDqa4m-5RBzs"
    range = "ALL-MEMBERS!A1:BG"
    # range = "ALL-MEMBERS!A1:BE2"

    service.get_spreadsheet_values spreadsheet_id, range
  end

  def sync_from_google_sheet
    response = fetch_from_sheet

    # runtime params
    dry_run = false # set to false to save entries at run time
    activation = false
    pending = true
    # runtime params

    created = 0
    updated = 0
    unprocessed = 0

    if response.values.empty?
      puts "No data found."
    else

      titles = response.values.shift
      v = {
        PROCESS: -1,
        SYNC: -1,
        fullname: -1,
        cm__slack__userid: -1,
        cm__id: -1,                 # coming soon
        cm__modifier__pin: -1,
        cm__modifier__flag: -1,     # tags ?
        cm__modfier__float: -1,
        cm__intention__focus: -1,
        cm__notes: -1,
        cm__step: -1,
        cm__ABC: -1,
        cm__importance: -1,
        cm__urgency: -1,
        cm__is__dev: -1,
        cm__is__core_team: -1,
        cm__is__talent: -1,
        cm__is__client: -1,
        cm__is__partner: -1,
        cm__is__collective: -1,
        cm__is__investor: -1,
        cm__reach: -1,
        cm__lever: -1,
        cm__climate: -1,
        cm__proxi: -1,
        cm__freshness: -1,
        cm__tags: -1,
        cm__intention__getC: 30,
        cm__intention__get: -1,
        cm__intention__ask_for_referals: -1,
        cm__assigned_to: -1,
        email: -1,
        cm__slack__status: -1,
        cm__slack__username: -1,
        displayname: -1,
        cm__facebook__page: -1,
        cm__facebook__group: -1,
        cm__pl__linkedin: -1,
        cm__linkedin__group: -1,
        cm__platform__profile_status: -1,
        cm__platform__profile_quality: -1,
        cm__platform__terms_accepted: -1,
        cm__newsletter__subscribed: -1,
        cm__last_sync: -1,
        firstname: -1,
        lastname: -1
      }

      # set reference table
      v.each do |k, _val|
        v[k] = titles.find_index(k.to_s)
      end

      skip_list = %w[
        juliend2@gmail.com
        gsaad@spektrummedia.com
        tamara@magnificentsystems.com
        support@collabmachine.com
      ]

      response.values.each do |row|
        next if @selection != ['all'] && (@selection.include?(row[v[:email]]) == false)

        if skip_list.include?(row[v[:email]])
          puts "skip #{row[v[:email]]}"
          next
        end

        if row[v[:PROCESS]] == "FALSE"
          puts "Skip #{row[v[:email]]}: PROCESS is set to FALSE"
          next
        end

        if row[v[:SYNC]] == "FALSE"
          puts "Skip #{row[v[:email]]}: sync is set to FALSE"
          next
        end

        if row[v[:email]] == ""
          puts "!!! No email for this line: see #{row[v[:fullname]]}"
          unprocessed += 1

        elsif (found_user = User.find_by_email(row[v[:email]]))
          updated += 1
          puts "User found, updating attributes for: #{found_user.full_name}."
          attrs = build_attributes(row, v, found_user.id)
          found_user.maintain_meta_attributes(attrs)
        else
          puts "Creating user (#{row[v[:email]]}) with 'pending' status."

          rand_pass = (0...12).map { ('a'..'z').to_a[rand(26)] }.join

          u = User.new(
            username: row[v[:cm__slack__username]],
            email: row[v[:email]],
            password: rand_pass,
            password_confirmation: rand_pass,
            first_name: row[v[:firstname]],
            last_name: row[v[:lastname]],
            # headline: '',
            # avatar: (File.new("#{avatar_image_path}#{file_name}") if m.profile.is_custom_image | nil),
            balance: 0,
            active: activation,
            pending: pending
          )
          u.save

          attrs = build_attributes(row, v, u.id)
          u.maintain_meta_attributes(attrs)

          created += 1
        end
        # set slack user id and slack profile if user exist and slack data exists
      end

      puts "Total updated users: #{updated}"
      puts "Total created users: #{created}"
      puts "Total unprocessed users: #{unprocessed}"
      puts "Run mode: #{dry_run ? 'dry run (nothing created)' : 'not dry run'}"
    end
  end
end
