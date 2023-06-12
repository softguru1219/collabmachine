require 'rails_helper'

describe HelloController do
  render_views

  let!(:user) { create :user }

  describe "#index" do
    it "renders the landing page" do
      get :index

      expect(response).to render_template(:index)
    end
  end

  # Missing partial hello/_partners
  # describe "#index_first" do
  #   it "renders the legacy landing page" do
  #     get :index_first

  #     expect(response).to render_template(:index_first)
  #   end
  # end

  describe "#hire" do
    it "renders the hiring page" do
      get :hire

      expect(response).to render_template(:hire)
    end
  end

  describe "#work" do
    it "renders the work page" do
      get :work

      expect(response).to render_template(:work)
    end
  end

  describe "#team" do
    it "renders the team page" do
      get :team

      expect(response).to render_template(:team)
    end
  end

  describe "#partners" do
    it "renders the partners page" do
      get :partners

      expect(response).to render_template(:partners)
    end
  end

  describe "#randomly" do
    it "renders the randomly page" do
      get :randomly

      expect(response).to render_template(:randomly)
    end
  end

  describe "#styledeck" do
    it "renders the styledeck page" do
      get :styledeck

      expect(response).to render_template(:styledeck)
    end
  end

  describe "#payment" do
    it "renders the payment page" do
      get :payment

      expect(response).to render_template(:payment)
    end
  end

  describe "#payment_gateway" do
    it "renders the payment_gateway page" do
      get :payment_gateway

      expect(response).to render_template(:payment_gateway)
    end
  end

  describe "#sandbox" do
    it "renders the sandbox page" do
      get :sandbox

      expect(response).to render_template(:sandbox)
    end
  end

  describe "#ten_slides" do
    it "renders the ten_slides page" do
      get :ten_slides

      expect(response).to render_template(:ten_slides)
    end
  end

  describe "#digital_entrepreneurs" do
    it "renders the digital_entrepreneurs page" do
      get :digital_entrepreneurs

      expect(response).to render_template(:digital_entrepreneurs)
    end
  end
end
