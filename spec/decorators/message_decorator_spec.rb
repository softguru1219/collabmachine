require 'rails_helper'

describe MessageDecorator do
  describe '#state_classes' do
    context 'when the message is deprecated' do
      it 'is disabled' do
        message = build_message(deprecated: true)

        expect(message.state_classes).to include 'disabled'
      end
    end

    context 'when the message is not deprecated' do
      it 'is not disabled' do
        message = build_message(deprecated: false)

        expect(message.state_classes).to_not include 'disabled'
      end
    end
  end

  def build_message(options)
    Message.new(options).decorate
  end
end
