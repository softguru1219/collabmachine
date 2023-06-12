require 'rails_helper'

describe MessagesController do
  render_views

  describe "#index" do
    let!(:user) { create :user }
    let!(:message) { create :message, audience: "public", subject: "the message subject" }

    before { sign_in user }

    it "renders a list of messages" do
      get :index
      expect(response).to render_template(:index)
      expect(response.body).to include("the message subject")
    end
  end

  describe "#show" do
    let!(:sender) { create :user }
    let!(:recipient) { create :user }
    let!(:message) { create :message, sender: sender.id, recipient: recipient.id, audience: "public", subject: "the message subject" }

    before { sign_in recipient }

    it "renders the message show page" do
      get :show, params: { id: message.id }
      expect(response).to render_template(:show)
      expect(response.body).to include("the message subject")
    end
  end

  describe "#new" do
    let!(:user) { create :user }
    before { sign_in user }

    it "renders a form to create a new message" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    let!(:sender) { create :user }
    let!(:recipient) { create :user }

    let!(:valid_params) {
      {
        "message" => {
          "sender" => sender.id.to_s,
          "recipient" => recipient.id.to_s,
          "audience" => "public",
          "subject" => "test message subject",
          "body" => "test message body"
        }
      }
    }

    before { sign_in sender }

    it "creates the message" do
      expect {
        post :create, params: valid_params
      }.to change(Message, :count).by(1)

      message = Message.last

      expect(message.user_sender).to eq(sender)
      expect(message.user_recipient).to eq(recipient)
      expect(message.audience).to eq("public")
      expect(message.subject).to eq("test message subject")
      expect(message.body).to eq("test message body")

      expect(response).to redirect_to(message_path(message))
    end
  end

  describe "#edit" do
    let!(:recipient) { create :user }
    let!(:message) { create :message, recipient: recipient.id }

    before { sign_in recipient }

    it "renders the edit form" do
      get :edit, params: { id: message.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    let!(:sender) { create :user }
    let!(:recipient) { create :user }
    let!(:message) { create :message, recipient: recipient.id, sender: sender.id }

    let!(:valid_params) {
      {
        "message" => {
          "sender" => sender.id.to_s,
          "recipient" => recipient.id.to_s,
          "audience" => "public",
          "subject" => "updated message subject",
          "body" => "updated message body"
        },
        "id" => message.id
      }
    }

    before { sign_in recipient }

    it "updates the message" do
      patch :update, params: valid_params

      message.reload

      expect(message.subject).to eq("updated message subject")
      expect(message.body).to eq("updated message body")

      expect(response).to redirect_to(message_path(message))
    end
  end

  describe "#destroy" do
    let!(:sender) { create :user }
    let!(:recipient) { create :user }
    let!(:message) { create :message, recipient: recipient.id, sender: sender.id }

    before { sign_in recipient }

    it "destroys the message" do
      expect {
        delete :destroy, params: { id: message.id }
      }.to change(Message, :count).by(-1)

      expect(Message.find_by(id: message.id)).to eq(nil)

      expect(response).to redirect_to(messages_path)
    end
  end
end
