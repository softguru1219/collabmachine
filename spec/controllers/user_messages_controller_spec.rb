require "rails_helper"

describe UserMessagesController, type: :controller do
  render_views

  shared_context "existing_message" do
    let!(:user) { create :user }
    let!(:message) { create :user_message, title: "Message Title", message: "Message Body", user: user }

    let!(:admin) { create :admin }
    before { sign_in admin }
  end

  describe "#index" do
    include_context "existing_message"

    it "shows a list of messages" do
      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("Message Title")
    end
  end

  describe "#show" do
    include_context "existing_message"

    it "shows the message" do
      get :show, params: { id: message.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("Message Title")
      expect(response.body).to include("Message Body")
    end
  end

  describe "#new" do
    it "renders a form to write a message to the site admin" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  let!(:valid_message_params) {
    { "title" => "Message Title", "message" => "<p>Message Body</p>", "anonymous" => "0" }
  }

  describe "#create" do
    let!(:user) { create :user }
    before { sign_in user }

    it "creates a non-anonymous message" do
      expect {
        post :create, params: { "user_message" => valid_message_params }
      }.to change(UserMessage, :count).by(1)

      message = UserMessage.last

      expect(message.title).to eq("Message Title")
      expect(message.message).to eq("<p>Message Body</p>")
      expect(message.anonymous).to eq(false)
      expect(message.user).to eq(user)

      expect(response).to redirect_to(dashboard_path)
    end

    it "creates an anonymous message" do
      valid_message_params["anonymous"] = "1"

      expect {
        post :create, params: { "user_message" => valid_message_params }
      }.to change(UserMessage, :count).by(1)

      message = UserMessage.last

      expect(message.title).to eq("Message Title")
      expect(message.message).to eq("<p>Message Body</p>")
      expect(message.anonymous).to eq(true)
      expect(message.user).to eq(nil)

      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "#edit" do
    include_context "existing_message"

    it "renders a form to edit the message" do
      get :edit, params: { id: message.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    include_context "existing_message"

    it "updates the message" do
      valid_message_params["title"] = "updated_title"

      patch :update, params: { id: message.id, user_message: valid_message_params }

      expect(message.reload.title).to eq("updated_title")

      expect(response).to redirect_to(user_message_path(message))
    end
  end

  describe "#destroy" do
    include_context "existing_message"

    it "destroys the message" do
      valid_message_params["title"] = "updated_title"

      expect {
        delete :destroy, params: { id: message.id }
      }.to change(UserMessage, :count).by(-1)

      expect(UserMessage.find_by(id: message.id)).to eq(nil)

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
