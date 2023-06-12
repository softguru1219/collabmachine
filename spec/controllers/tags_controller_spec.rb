require 'rails_helper'

describe TagsController, type: :controller do
  render_views

  let!(:admin) { create :admin }
  before { sign_in admin }

  shared_context "existing_tag" do
    let!(:tag) { create :tag, name: "a_tag" }
  end

  describe "#index" do
    include_context "existing_tag"

    it "renders a list of tags" do
      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("a_tag")
    end
  end

  describe "#show" do
    include_context "existing_tag"

    it "renders the tag show page" do
      get :show, params: { id: tag.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("a_tag")
    end
  end

  let!(:valid_tag_params) {
    { "tag" => { "language" => "en", "name" => "a_tag_name", "position" => "0" } }
  }

  describe "#new" do
    it "renders a form for a new tag" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    it "creates a new tag" do
      expect {
        post :create, params: valid_tag_params
      }.to change(Tag, :count).by(1)

      tag = Tag.last

      expect(tag.name).to eq("a_tag_name")
      expect(tag.language).to eq("en")
      expect(tag.position).to eq(0)

      expect(response).to redirect_to(tag_path(tag))
    end
  end

  describe "#edit" do
    include_context "existing_tag"

    it "renders a form to edit the tag" do
      get :edit, params: { id: tag.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    include_context "existing_tag"

    it "updates the tag" do
      valid_tag_params["tag"]["name"] = "updated_tag_name"
      valid_tag_params["id"] = tag.id.to_s

      patch :update, params: valid_tag_params

      expect(tag.reload.name).to eq("updated_tag_name")
      expect(response).to redirect_to(tag_path(tag))
    end
  end

  describe "#destroy" do
    include_context "existing_tag"

    it "destroys the tag" do
      delete :destroy, params: { id: tag.id }

      expect(Tag.find_by(id: tag.id)).to eq(nil)
      expect(response).to redirect_to(tags_path)
    end
  end

  describe "#merge" do
    let!(:user) { create :user }
    let!(:existing_tag) { create :tag, name: "existing_tag" }
    let!(:tag_to_merge_into) { create :tag, name: "tag_to_merge_into" }

    it "merges the current tag into another tag" do
      user.skill_list.add("existing_tag")
      user.save!

      params = { "current_tag_name" => "existing_tag", "tag_name" => "tag_to_merge_into" }

      post :merge, params: params

      expect(user.reload.skill_list).to eq(["tag_to_merge_into"])
      expect(response).to redirect_to(tag_path(tag_to_merge_into))
    end
  end

  describe "#all_tags" do
    let!(:en_tag) { create :tag, language: "en", name: "en_tag" }
    let!(:fr_tag) { create :tag, language: "fr", name: "fr_tag" }

    it "shows tags in all languages" do
      get :all_tags, format: :json

      expect(JSON.parse(response.body)).to eq(["en_tag", "fr_tag"])
    end
  end

  describe "#destroy_orphean_tags" do
    let!(:used_tag) { create :tag, name: "used_tag" }
    let!(:orphan_tag) { create :tag, name: "orphan_tag" }
    let!(:user) { create :user }
    before {
      user.skill_list.add("used_tag")
      user.save!
    }

    it "destroys orphan tags" do
      delete :destroy_orphean_tags

      expect(Tag.find_by(id: orphan_tag.id)).to eq(nil)
      expect(response).to redirect_to(tags_path)
    end
  end

  describe "#tag_cloud" do
    let!(:tag) { create :tag }

    it "shows a tag cloud page" do
      get :tag_cloud

      expect(response).to render_template(:tag_cloud)
    end
  end
end
