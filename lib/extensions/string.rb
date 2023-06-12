class String
  def ucfirst!
    self[0] = self[0, 1].upcase
    self
  end

  # keep the original string untouched
  def ucfirst
    str = self.clone
    str[0] = str[0, 1].upcase
    str
  end

  alias upf ucfirst!

  def to_bool
    return true   if self == true   || self =~ /(true|t|yes|y|1)$/i

    return false  if self == false  || self.blank? || self =~ /(false|f|no|n|0)$/i

    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  def sanitize_filename
    # Split the name when finding a period which is preceded by some
    # character, and is followed by some character other than a period,
    # if there is no following period that is followed by something
    # other than a period (yeah, confusing, I know)
    fn = self.split(/(?<=.)\.(?=[^.])(?!.*\.[^.])/m)

    # We now have one or two parts (depending on whether we could find
    # a suitable period). For each of these parts, replace any unwanted
    # sequence of characters with an underscore
    fn.map! { |s| s.gsub(/[^a-z0-9\-]+/i, '_') }

    # Finally, join the parts with a period and return the result
    fn.join '.'
  end
end

[String].each do |klass|
  klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1

  def utf8_downcase
    mb_chars.downcase.to_s
  end

  def utf8_upcase
    mb_chars.upcase.to_s
  end

  def utf8_capitalize
    mb_chars.capitalize.to_s
  end

  def utf8_titleize
    mb_chars.titleize.to_s
  end

  RUBY
end
