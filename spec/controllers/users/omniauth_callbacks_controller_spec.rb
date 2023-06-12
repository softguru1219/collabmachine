require 'rails_helper'

describe Users::OmniauthCallbacksController do
  describe '#stripe_connect' do
    context 'when there is a user connected' do
      context 'when the user doesn\'t have a stripe profile' do
        it 'creates a new profile' do
          user = create(:user)
          auth = double(
            provider: 'stripe_connect',
            uid: 'stripe_uid',
            info: double(stripe_publishable_key: '123'),
            credentials: double(token: '123')
          )
          sign_in(user)

          @request.env["devise.mapping"] = Devise.mappings[:user]
          @request.env["omniauth.auth"] = auth
          get :stripe_connect

          last_profile = user.profiles.reload.last

          expect(last_profile.provider).to eq 'stripe_connect'
          expect(last_profile.uid).to eq 'stripe_uid'
        end
      end
    end
  end

  describe '#linkedin' do
    context 'when there is user connected' do
      context 'when the user doesn\'t have a linkedin profile' do
        it 'creates a new profile' do
          linkedin_profile_importer = double(call: true)
          allow(LinkedinProfileImporter).to receive(:new).and_return(linkedin_profile_importer)
          user = create(:user)
          auth = double(
            provider: 'linkedin',
            uid: 'linkedin_uid',
            credentials: double(token: '123')
          )
          sign_in(user)

          @request.env["devise.mapping"] = Devise.mappings[:user]
          @request.env["omniauth.auth"] = auth
          get :linkedin

          last_profile = user.profiles.reload.last

          expect(last_profile.provider).to eq 'linkedin'
          expect(last_profile.uid).to eq 'linkedin_uid'
        end
      end
    end

    context 'when there is user not connected' do
      context 'when the user is valid' do
        it 'creates a new profile' do
          linkedin_profile_importer = double(call: true)
          allow(LinkedinProfileImporter).to receive(:new).and_return(linkedin_profile_importer)
          auth = double(
            provider: 'linkedin',
            uid: 'linkedin_uid',
            info: double(email: 'test@test.com'),
            credentials: double(token: '123')
          )

          @request.env["devise.mapping"] = Devise.mappings[:user]
          @request.env["omniauth.auth"] = auth
          expect {
            get :linkedin
          }.to change { User.count }.by(1)

          user = User.last
          last_profile = user.profiles.reload.last

          expect(last_profile.provider).to eq 'linkedin'
          expect(last_profile.uid).to eq 'linkedin_uid'
        end
      end

      context 'when the email is already took' do
        it 'doesn\'t create a new user' do
          linkedin_profile_importer = double(call: true)
          allow(LinkedinProfileImporter).to receive(:new).and_return(linkedin_profile_importer)
          user = create(:user)

          auth = double(
            provider: 'linkedin',
            uid: 'linkedin_uid',
            info: double(email: user.email),
            credentials: double(token: '123')
          )

          @request.env["devise.mapping"] = Devise.mappings[:user]
          @request.env["omniauth.auth"] = auth
          expect { get :linkedin }.to_not change { User.count }
        end
      end
    end
  end
end
