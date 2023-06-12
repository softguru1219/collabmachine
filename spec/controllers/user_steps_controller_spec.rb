require "rails_helper"

describe UserStepsController, type: :controller do
  render_views

  let!(:user) { create :user }
  before { sign_in user }

  describe "details#show" do
    it "renders the details page" do
      get :show, params: { id: :details }

      expect(response).to render_template(:details)
    end
  end

  describe "details#update" do
    let!(:valid_params) {
      {
        "user" => {
          "username" => "test_username",
          "headline" => "test_headline",
          "description" => "<p>test_description</p>",
          "github_url" => "https://www.github.com/test",
          "linkedin_url" => "https://www.linkedin.com/test",
          "web_site_url" => "http://www.example.com"
        },
        "id" => "details"
      }
    }

    it "updates the record with details" do
      patch :update, params: valid_params

      user.reload

      expect(user.username).to eq("test_username")
      expect(user.headline).to eq("test_headline")
      expect(user.description).to eq("<p>test_description</p>")
      expect(user.github_url).to eq("https://www.github.com/test")
      expect(user.linkedin_url).to eq("https://www.linkedin.com/test")
      expect(user.web_site_url).to eq("http://www.example.com")

      expect(response).to redirect_to(user_step_path(id: "experiences"))
    end
  end

  describe "experiences#show" do
    it "renders the experiences page" do
      get :show, params: { id: :experiences }

      expect(response).to render_template(:experiences)
    end
  end

  describe "experiences#update" do
    let!(:valid_params) {
      {
        "user" => {
          "skill_list" => ["", "Coaching"],
          "interest_list" => ["", "Higher Education"]
        },
        "id" => "experiences"
      }
    }

    it "renders the experiences page" do
      patch :update, params: valid_params

      user.reload

      expect(user.skill_list).to eq(["Coaching"])
      expect(user.interest_list).to eq(["Higher Education"])

      expect(response).to redirect_to(user_step_path(id: "wicked_finish"))
    end
  end
end
