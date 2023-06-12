require 'rails_helper'

describe MessageDecorator do
  let(:recipient) { create(:user, access_level: 'freemium') }
  let(:admin) { create(:user, access_level: 'admin') }
  let(:user) { create(:user, access_level: 'freemium') }
  let(:message) { create(:message, audience: 'public', recipient: recipient.id).decorate }

  describe '#can_be_viewed_by' do
    context 'when the message is public' do
      it 'can be viewed by everbody' do
        message.update(audience: 'public')

        expect(message.can_be_viewed_by?(recipient)).to be_truthy
        expect(message.can_be_viewed_by?(admin)).to be_truthy
        expect(message.can_be_viewed_by?(user)).to be_truthy
      end
    end

    context 'when the message is private' do
      it 'can be viewed by the receiver' do
        message.update(audience: 'private')

        expect(message.can_be_viewed_by?(recipient)).to be_truthy
        expect(message.can_be_viewed_by?(admin)).to be_falsy
        expect(message.can_be_viewed_by?(user)).to be_falsy
      end
    end

    context 'when the message is for admin' do
      it 'can be viewed by admin' do
        message.update(audience: 'admin')

        expect(message.can_be_viewed_by?(recipient)).to be_falsy
        expect(message.can_be_viewed_by?(admin)).to be_truthy
        expect(message.can_be_viewed_by?(user)).to be_falsy
      end
    end
  end
end
