require 'rails_helper'

describe LinkedinProfileImporter do
  describe '#call' do
    it 'fill a profile with information found on linkedin' do
      user = create(:user, description: 'The best', interest_list: 'a,b,c')
      profile = LinkedIn::Mash.new(
        first_name: 'Guirec', last_name: 'Corbel',
        headline: 'The best programmer ever', summary: 'God like'
      )
      client = double(profile: profile)

      allow(LinkedIn::Client).to receive(:new).and_return(client)
      allow(client).to receive(:authorize_from_access).with('token')

      LinkedinProfileImporter.new(user: user, token: 'token').call

      expect(user.description).to eq 'The best'
      expect(user.interest_list).to eq ['a', 'b', 'c']
    end
  end
end
