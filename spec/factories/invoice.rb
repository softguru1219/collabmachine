FactoryBot.define do
  factory :invoice do
    association :customer, factory: :user
    association :user, factory: :user
  end

  factory :invoice_without_customer, parent: :invoice do
    public_token { Digest::SHA1.hexdigest([Time.now, rand].join) }
  end
end
