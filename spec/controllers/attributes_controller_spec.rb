require 'rails_helper'

describe AttributesController do
  render_views

  let!(:user) { create :user }
  let!(:admin) { create :admin }

  before { sign_in admin }

  shared_context "existing_attribute" do
    let!(:attribute) {
      create(
        :meta_attribute,
        name: "some_attribute_name",
        value: "some_attribute_value",
        user: user,
        source_user_id: admin.id
      )
    }
  end

  describe "#new" do
    it "renders a form for a new attribute" do
      get :new, params: { user_id: user.id }

      expect(response).to render_template(:new)
    end
  end

  let!(:valid_params) {
    {
      "user_id" => user.id.to_s,
      "source_user_id" => admin.id.to_s,
      "name" => "some_attribute",
      "value" => "some_attribute_value"
    }
  }

  describe "#create" do
    it "creates a new private attribute" do
      expect {
        post :create, params: { "meta_attribute" => valid_params, "user_id" => user.id.to_s }
      }.to change(MetaAttribute, :count).by(1)

      attribute = MetaAttribute.last

      expect(attribute.user).to eq(user)
      expect(attribute.source_user_id).to eq(admin.id)
      expect(attribute.name).to eq("some_attribute")
      expect(attribute.value).to eq("some_attribute_value")
      expect(attribute.visibility).to eq("private")

      expect(response).to redirect_to(user_path(user, anchor: "summary"))
    end

    it "creates a new public attribute" do
      valid_params["visibility"] = "public"

      expect {
        post :create, params: { "meta_attribute" => valid_params, "user_id" => user.id.to_s }
      }.to change(MetaAttribute, :count).by(1)

      attribute = MetaAttribute.last

      expect(attribute.user).to eq(user)
      expect(attribute.source_user_id).to eq(admin.id)
      expect(attribute.name).to eq("some_attribute")
      expect(attribute.value).to eq("some_attribute_value")
      expect(attribute.visibility).to eq("public")

      expect(response).to redirect_to(user_path(user, anchor: "summary"))
    end
  end

  describe "#edit" do
    include_context "existing_attribute"

    it "renders a form to edit an existing attribute" do
      get :edit, params: { user_id: user.id, id: attribute.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    include_context "existing_attribute"

    it "updates an existing attribute" do
      patch :update, params: {
        "meta_attribute" => {
          "user_id" => user.id.to_s,
          "source_user_id" => admin.id.to_s,
          "name" => "some_attribute",
          "value" => "updated_value"
        },
        "user_id" => user.id.to_s,
        "id" => attribute.id.to_s
      }

      attribute.reload

      expect(attribute.value).to eq("updated_value")

      expect(response).to redirect_to(user_path(user, anchor: "summary"))
    end
  end

  describe "#destroy" do
    include_context "existing_attribute"

    it "destroys the attribute" do
      expect {
        delete :destroy, params: { user_id: user.id, id: attribute.id }
      }.to change(MetaAttribute, :count).by(-1)

      expect(MetaAttribute.find_by(id: attribute.id)).to eq(nil)

      expect(response).to redirect_to(user_path(user, anchor: "summary"))
    end
  end
end
