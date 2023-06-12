class Float
  def as_pct
    "#{self * 100} %"
  end

  def as_money
    format("$ %.2f", self)
  end
end
