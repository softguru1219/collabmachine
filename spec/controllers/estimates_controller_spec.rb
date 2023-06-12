require 'rails_helper'

describe EstimatesController do
  render_views

  let!(:admin) { create :admin }
  let!(:estimate) { create :estimate, title: "Some Estimate" }

  describe "#index" do
    it "renders the estimates index" do
      sign_in admin

      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("Some Estimate")
    end
  end

  describe "#show" do
    it "renders the estimat show page" do
      sign_in admin

      get :show, params: { id: estimate.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("Some Estimate")
    end
  end

  describe "#new" do
    it "renders the new estimate form" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    it "creates the estimate" do
      valid_params = {
        "estimate" => {
          "for" => "",
          "email" => "test@example.com",
          "phone" => "123-123-1234",
          "title" => "Some project",
          "description" => "Some project details"
        }
      }

      expect(MessageMailer).to receive(:prepare_new_quick_estimate).with(be_a(Estimate)).and_call_original

      expect {
        post :create, params: valid_params
      }.to change(Estimate, :count).by(1)

      estimate = Estimate.last
      expect(estimate.email).to eq("test@example.com")
      expect(estimate.phone).to eq("123-123-1234")
      expect(estimate.title).to eq("Some project")
      expect(estimate.description).to eq("Some project details")

      message = Message.last
      expect(message.item).to eq(estimate)
      expect(message.audience).to eq('admin')
      expect(message.message_type).to eq('creation')

      expect(response).to render_template(:create)
    end
  end

  describe "#destroy" do
    it "destroys the estimate" do
      sign_in admin

      delete :destroy, params: { id: estimate.id }

      expect(Estimate.find_by(id: estimate.id)).to eq(nil)

      expect(response).to redirect_to(estimates_path)
    end
  end
end
