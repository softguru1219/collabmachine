class LinkedinProfileImporter
  attr_accessor :user, :token

  def initialize(user:, token:)
    @user = user
    @token = token
  end

  def call
    user.update(linkedin_attributes.merge(original_attributes))
  end

  private

  def original_attributes
    @original_attributes ||= user
      .attributes
      .symbolize_keys
      .slice(:first_name, :last_name, :headline, :description)
      .compact
      .reject { |_, v| v.empty? }
  end

  def linkedin_attributes
    @linkedin_attributes ||= {
      first_name: profile.first_name,
      last_name: profile.last_name,
      headline: profile.headline,
      description: profile.summary,
      username: profile.maiden_name
    }.tap do |attrs|
      attrs[:avatar] = URI.parse(profile.picture_url) if user.avatar.blank? && profile.picture_url
    end
  end

  def profile
    @profile ||= client
      .profile(fields: ['summary', 'last_name', 'first_name', 'headline', 'maiden_name', 'picture_url'])
  end

  def client
    @client ||= LinkedIn::Client.new(Figaro.env.linkedin_app_id, Figaro.env.linkedin_app_secret).tap do |client|
      client.authorize_from_access(token)
    end
  end
end
