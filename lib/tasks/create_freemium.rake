namespace :collab do
  task freemium: :environment do
    user = User.find(43)
    product = Product.create(
      price: 0,
      description: "A freemium subscription to CollabMachine",
      intended_audience: "A freemium subscription to CollabMachine",
      value_proposition: "A freemium subscription to CollabMachine",
      user: user,
      subscription_access_level: "",
      stripe_price_id: "",
      title: "Freemium Subscription",
      state: Product.states.published,
      buyable: true
    )
    product.save!
  end
end
