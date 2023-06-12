require 'rails_helper'

describe MessageMailer do
  describe '#notify' do
    it 'Send latest activities' do
      user = create(:user)
      project = create(:project, user: user)
      mission = create(:mission, project: project)
      message = create(:message, item: mission)

      MessageMailer.latest_activities(user.id).deliver_now

      expect(last_email.body.parts.first.to_s).to include(project.title)
      expect(last_email.body.parts.first.to_s).to include(mission.title)
      expect(last_email.body.parts.first.to_s).to include(message.subject)
    end
  end

  describe "#purchase_receipt" do
    let!(:buyer) { create :user, email: "buyer@example.com" }
    let!(:product) { create :product, title: ":product-title:" }

    it "renders a receipt for a successful serviceplace purchase" do
      purchase = create_purchase_from_products_and_user([product], buyer)

      mail = MessageMailer.purchase_receipt(purchase)

      expect(mail.to).to eq(["buyer@example.com"])
      expect(mail.body).to include(":product-title:")
    end

    it "renders a message for a failed serviceplace purchase" do
      purchase = create_purchase_from_products_and_user([product], buyer, failed: true)

      mail = MessageMailer.purchase_receipt(purchase)

      expect(mail.to).to eq(["buyer@example.com"])
      expect(mail.body).to include("not charged due to system or vendor error")
    end
  end

  describe "#latest_activities" do
    let!(:recipient) { create :user }
    let!(:project) { create :project, user: recipient }
    let!(:mission) { create :mission, project: project }
    let!(:mission_message) {
      create :message, recipient: recipient.id, subject: "update-on-mission", item: mission
    }

    let!(:product) { create :product }
    let!(:product_message) {
      create :message, recipient: recipient.id, subject: "update-on-product", item: product
    }

    it "renders a the latest activities related to project missions" do
      mail = MessageMailer.latest_activities(recipient.id)
      body = mail.html_part.body.to_s
      expect(body).to include("update-on-mission")
    end

    it "renders other messsages created in the last 24 hours" do
      mail = MessageMailer.latest_activities(recipient.id)
      body = mail.html_part.body.to_s
      expect(body).to include("update-on-mission")
    end
  end

  describe "#product_recommneded" do
    let!(:product) { create :product }
    let!(:user) { create :user }
    let!(:recommended_to) { create :user, email: "recommended_to@example.com" }

    it "renders a message recommending the product" do
      mail = MessageMailer.product_recommended(
        product: product,
        recommended_by_user: user,
        recommended_to_user: recommended_to
      )

      expect(mail.to).to eq(["recommended_to@example.com"])
    end
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end
end
