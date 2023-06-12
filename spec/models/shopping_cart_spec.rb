require 'rails_helper'

describe ShoppingCart do
  let!(:empty_session) { {} }

  let!(:vendor) { create :user }
  let!(:user) { create :user }
  let!(:qst) { create :tax, user: user, name: "QST", rate: 10 }
  let!(:gst) { create :tax, user: user, name: "GST", rate: 5 }
  let!(:product_1) { create :product, user: vendor, title: "Product1", price: 200, taxes: [gst, qst] }
  let!(:product_2) { create :product, user: vendor, title: "Product2", price: 100, taxes: [gst] }
  let!(:products) { [product_1, product_2] }
  let!(:session_with_products) { { shopping_cart: { product_ids: products.map(&:id) } } }

  describe ".fetch_from_session" do
    it "fetches an empty cart when there is no shopping cart key in session" do
      cart = ShoppingCart.fetch_from_session(empty_session)
      expect(cart.products).to eq([])
    end

    it "fetches a shopping cart with products in it" do
      Bullet.enable = false
      cart = ShoppingCart.fetch_from_session(session_with_products)
      expect(cart.products).to eq([product_1, product_2])
      Bullet.enable = true
    end
  end

  describe ".verify_and_present" do
    it "fetches the shopping cart from the session and presents it as a hash" do
      presented = ShoppingCart.verify_and_present(session_with_products)

      expected = {
        products: [
          { id: product_1.id, image: nil, title: "Product1", price: "$200" },
          { id: product_2.id, image: nil, title: "Product2", price: "$100" }
        ],
        totals: {
          subtotal: "$300",
          taxes: [
            { nameWithRate: "GST (5%)", amount: "$15" },
            { nameWithRate: "QST (10%)", amount: "$20" }
          ],
          total: "$335"
        }
      }

      expect(presented).to eq(expected)
    end
  end

  describe ".add_product" do
    it "adds a product to the cart" do
      new_product = create :product

      presented = ShoppingCart.add_product(session_with_products, new_product.id)

      expect(presented[:products][2][:id]).to eq(new_product.id)
    end
  end

  describe ".remove_product" do
    it "removes a product from the cart" do
      presented = ShoppingCart.remove_product(session_with_products, product_2.id)

      expect(presented[:products][1]).to eq(nil)
    end
  end

  describe "#to_currency" do
    it "presents rationals" do
      I18n.with_locale(:en) do
        expect(ShoppingCart.new.to_currency(BigDecimal("1"))).to eq("$1")
        expect(ShoppingCart.new.to_currency(BigDecimal("1.1"))).to eq("$1.10")
        expect(ShoppingCart.new.to_currency(BigDecimal("1.11"))).to eq("$1.11")
      end

      I18n.with_locale(:fr) do
        expect(ShoppingCart.new.to_currency(BigDecimal("1"))).to eq("1 $")
        expect(ShoppingCart.new.to_currency(BigDecimal("1.1"))).to eq("1,10 $") # TODO: 1,00
        expect(ShoppingCart.new.to_currency(BigDecimal("1.11"))).to eq("1,11 $")
      end
    end
  end

  describe "#to_percentage" do
    it "presents the fraction" do
      I18n.with_locale(:en) do
        expect(ShoppingCart.new.to_percentage(BigDecimal("5.0"))).to eq("5%")
        expect(ShoppingCart.new.to_percentage(BigDecimal("9.975"))).to eq("9.975%")
      end

      I18n.with_locale(:fr) do
        expect(ShoppingCart.new.to_percentage(BigDecimal("5.0"))).to eq("5%")
        expect(ShoppingCart.new.to_percentage(BigDecimal("9.975"))).to eq("9,975%")
      end
    end
  end

  describe ".build_order_lines" do
    it "builds order lines from products" do
      order_lines = ShoppingCart.build_order_lines([product_1])
      expect(order_lines.count).to eq(1)

      order_line = order_lines.first
      expect(order_line.product_id).to eq(product_1.id)
      expect(order_line.vendor).to eq(vendor)
      expect(order_line.product_price).to eq(200)
      expect(order_line.product_quantity).to eq(1)
      expect(order_line.product_amount).to eq(200)
      expect(order_line.taxes).to include(TaxLine.new(
                                            id: gst.id, name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(10)
      ))
      expect(order_line.taxes).to include(TaxLine.new(
                                            id: qst.id, name: "QST", rate_as_percent: BigDecimal(10), amount: BigDecimal(20)
      ))
      expect(order_line.total_tax_amount).to eq(30)
      expect(order_line.total_amount).to eq(230)
    end
  end

  describe ".aggregate_taxes" do
    it "aggregates taxes by name and rate" do
      tax_1 = TaxLine.new(
        id: 1,
        name: "GST",
        rate_as_percent: BigDecimal(5),
        amount: BigDecimal(10)
      )
      tax_2 = TaxLine.new(
        id: 2,
        name: "GST",
        rate_as_percent: BigDecimal(5),
        amount: BigDecimal(20)
      )
      tax_3 = TaxLine.new(
        id: 3,
        name: "QST",
        rate_as_percent: BigDecimal(10),
        amount: BigDecimal(30)
      )

      aggregated = ShoppingCart.aggregate_taxes([tax_1, tax_2, tax_3])
      expect(aggregated.length).to eq(2)

      expect(aggregated).to include(TaxLine.new(
                                      name: "GST",
                                      rate_as_percent: BigDecimal(5),
                                      amount: BigDecimal(30)
      ))

      expect(aggregated).to include(TaxLine.new(
                                      name: "QST",
                                      rate_as_percent: BigDecimal(10),
                                      amount: BigDecimal(30)
      ))
    end
  end

  describe ".build_order" do
    it "builds an order from order lines and vendor" do
      vendor = create :user, first_name: "Example", last_name: "Vendor", email: "vendor@example.com"
      line_1 = OrderLine.new(
        product_amount: 100,
        taxes: [TaxLine.new(id: 1, name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(5))],
        total_amount: 105
      )
      line_2 = OrderLine.new(
        product_amount: 200,
        taxes: [TaxLine.new(id: 1, name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(10))],
        total_amount: 210
      )

      order = ShoppingCart.build_order(vendor, [line_1, line_2])
      expect(order.vendor_id).to eq(vendor.id)
      expect(order.vendor_name).to eq("Example Vendor")
      expect(order.vendor_email).to eq("vendor@example.com")
      expect(order.total_product_amount).to eq(300)
      expect(order.taxes).to include(TaxLine.new(
                                       name: "GST",
                                       rate_as_percent: BigDecimal(5),
                                       amount: BigDecimal(15)
      ))
      expect(order.total_tax_amount).to eq(15)
      expect(order.total_amount).to eq(315)
      expect(order.order_lines).to eq([line_1, line_2])
    end
  end

  describe ".build_purchase" do
    it "builds a purchase from orders" do
      order_1 = Order.new(
        total_product_amount: 100,
        taxes: [TaxLine.new(id: 1, name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(5))],
        total_amount: 105
      )
      order_2 = Order.new(
        total_product_amount: 200,
        taxes: [TaxLine.new(id: 1, name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(10))],
        total_amount: 210
      )

      order = ShoppingCart.build_purchase([order_1, order_2])
      expect(order.total_product_amount).to eq(300)
      expect(order.taxes).to include(TaxLine.new(
                                       name: "GST",
                                       rate_as_percent: BigDecimal(5),
                                       amount: BigDecimal(15)
      ))
      expect(order.total_tax_amount).to eq(15)
      expect(order.total_amount).to eq(315)
      expect(order.orders).to eq([order_1, order_2])
    end
  end
end
