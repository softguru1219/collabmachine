module Utils
  module BigDecimal
    extend self

    # Use Banker's Rounding
    # https://shopify.engineering/eight-tips-for-hanging-pennies
    # https://wiki.c2.com/?BankersRounding#:~:text=Bankers%20Rounding%20is%20an%20algorithm,1.5%20rounds%20up%20to%202.
    def round_money(decimal)
      decimal.round(2, :half_even)
    end
  end
end
