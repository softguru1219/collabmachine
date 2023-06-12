require "rails_helper"

describe TrackersController, type: :controller do
  let!(:user) { create :user }
  before { sign_in user }

  describe "#index" do
    it "renders a list of trackers" do
      create :tracker

      get :index

      expect(response).to render_template(:index)
    end
  end

  describe "#show" do
    it "renders a tracker show page" do
      tracker = create :tracker

      get :show, params: { id: tracker.id }

      expect(response).to render_template(:show)
    end
  end

  describe "#new" do
    it "renders a form to create a new tracker" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe "#edit" do
    it "renders a page to edit the tracker" do
      tracker = create :tracker

      get :edit, params: { id: tracker.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#create" do
    it "creates a new tracker" do
      params = { "tracker" => { "user_id" => user.id, "target" => ":target:" } }

      expect {
        post :create, params: params
      }.to change(Tracker, :count).by(1)

      tracker = Tracker.last

      expect(tracker.user_id).to eq(user.id)
      expect(tracker.target).to eq(":target:")

      expect(response).to redirect_to(tracker_path(tracker))
    end
  end

  describe "#update" do
    it "updates a target" do
      tracker = create :tracker, target: ":target:"

      params = { "tracker" => { "user_id" => "11", "target" => ":updated-target:" }, id: tracker.id }

      patch :update, params: params

      tracker.reload

      expect(tracker.target).to eq(":updated-target:")

      expect(response).to redirect_to(tracker_path(tracker))
    end
  end

  describe "#destroy" do
    it "destroys the tracker" do
      tracker = create :tracker

      expect {
        delete :destroy, params: { id: tracker.id }
      }.to change(Tracker, :count).by(-1)

      expect(Tracker.find_by(id: tracker.id)).to eq(nil)

      expect(response).to redirect_to(trackers_path)
    end
  end
end
