require 'rails_helper'

describe User do
  describe '#full_name' do
    it 'gives the first name and the last name' do
      user = build(:user, first_name: 'Guirec', last_name: 'Corbel')
      expect(user.full_name).to eq 'Guirec Corbel'
    end
  end

  describe '#save' do
    it 'creates a customer on stripe' do
      original = Rails.application.config.disable_stripe_user_creation
      Rails.application.config.disable_stripe_user_creation = false

      user = build(:user, stripe_customer_id: nil)
      stripe_customer = double(Stripe::Customer, id: 1)
      allow(Stripe::Customer).to receive(:create).and_return(stripe_customer)

      user.save!

      expect(user.stripe_customer_id).to eq '1'

      Rails.application.config.disable_stripe_user_creation = original
    end
  end

  describe '#has_payment_info?' do
    context 'when there is payment info on stripe' do
      it 'gives true' do
        user = build(:user)
        stripe_customer = double(Stripe::Customer, sources: [1])
        allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)
        expect(user).to have_payment_info
      end
    end
  end

  describe '#stripe_customer' do
    it 'gives the stripe customer corresponding to the ID' do
      user = build(:user, stripe_customer_id: 1)
      stripe_customer = double

      allow(Stripe::Customer).to receive(:retrieve)
        .and_return(stripe_customer)
        .with('1')

      expect(user.stripe_customer).to eq(stripe_customer)
    end
  end

  describe '#linkedin_profile' do
    it 'gives the linkedin profile' do
      user = create(:user)
      profile = create(:profile, provider: 'linkedin', user: user)
      expect(user.linkedin_profile).to eq(profile)
    end
  end

  describe '#stripe_profile' do
    it 'gives the stripe profile' do
      user = create(:user)
      profile = create(:profile, provider: 'stripe_connect', user: user)
      expect(user.stripe_profile).to eq(profile)
    end
  end

  describe ".by_name" do
    it "matches by first_name" do
      matching = create :user, first_name: "Matching"
      _other = create :user, first_name: "Other"

      expect(User.by_name("matching")).to eq([matching])
    end

    it "matches by last_name" do
      matching = create :user, last_name: "Matching"
      _other = create :user, last_name: "Other"

      expect(User.by_name("matching")).to eq([matching])
    end

    it "matches by username" do
      matching = create :user, username: "Matching"
      _other = create :user, username: "Other"

      expect(User.by_name("matching")).to eq([matching])
    end

    it "matches by company" do
      matching = create :user, company: "Matching"
      _other = create :user, company: "Other"

      expect(User.by_name("matching")).to eq([matching])
    end

    it "matches by email" do
      matching = create :user, email: "Matching@example.com"
      _other = create :user, email: "Other@example.com"

      expect(User.by_name("matching")).to eq([matching])
    end
  end

  describe ".by_description" do
    it "matches by description" do
      matching = create :user, description: "Matching"
      _other = create :user, description: "Other"

      expect(User.by_description("matching")).to eq([matching])
    end
  end

  describe ".sorted_by" do
    it "sorts by display_name" do
      user_1 = create :user, first_name: "B"
      user_2 = create :user, first_name: "A"

      users = User.sorted_by("display_name_asc")

      expect(users).to eq([user_2, user_1])
    end
  end

  describe "#handle_from_email" do
    it "creates a handle from the user's email" do
      user = build(:user, email: "john@doe.com")
      expect(user.handle_from_email).to eq("john")
    end
  end

  describe "access level methods" do
    it "generates predicates for each access level" do
      expect(build(:user, access_level: "freemium").freemium?).to eq(true)
      expect(build(:user, access_level: "premium").premium?).to eq(true)
      expect(build(:user, access_level: "admin").admin?).to eq(true)
    end

    it "generates gte_predicates for each access level" do
      expect(build(:user, access_level: "freemium").gte_freemium?).to eq(true)
      expect(build(:user, access_level: "freemium").gte_premium?).to eq(false)
      expect(build(:user, access_level: "freemium").gte_admin?).to eq(false)

      expect(build(:user, access_level: "premium").gte_freemium?).to eq(true)
      expect(build(:user, access_level: "premium").gte_premium?).to eq(true)
      expect(build(:user, access_level: "premium").gte_admin?).to eq(false)

      expect(build(:user, access_level: "admin").gte_freemium?).to eq(true)
      expect(build(:user, access_level: "admin").gte_premium?).to eq(true)
      expect(build(:user, access_level: "admin").gte_admin?).to eq(true)
    end

    it "generates scopes for each access level" do
      freemium = create :user, access_level: "freemium"
      premium = create :user, access_level: "premium"
      admin = create :user, access_level: "admin"

      expect(User.freemium).to eq([freemium])
      expect(User.premium).to eq([premium])
      expect(User.admin).to eq([admin])
    end
  end
end
