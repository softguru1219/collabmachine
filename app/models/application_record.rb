class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # use string columns as enums (not supported by ActiveRecord enum)
  def self.string_enum(field_name, options, allow_nil: false)
    define_singleton_method "#{field_name}_values" do
      options
    end

    # lets us do (for instance) `Product.states.for_review`
    strict_options_container = Struct.new(*options.map(&:to_sym)).new(*options).freeze
    define_singleton_method field_name.to_s.pluralize.to_s do
      strict_options_container
    end

    options.each do |option|
      define_method "#{field_name}_is_#{option}?" do
        send(field_name) == option
      end
    end

    define_singleton_method "translate_#{field_name}_value" do |value|
      I18n.t("activerecord.enums.#{self.to_s.underscore}.#{field_name}.#{value}")
    end

    define_method "translated_#{field_name}" do
      self.class.send("translate_#{field_name}_value", send(field_name))
    end

    before_validation do
      assign_attributes(field_name => nil) if send(field_name) == ""
    end

    validates_inclusion_of field_name,
                           in: options,
                           allow_nil: allow_nil

    define_singleton_method "#{field_name}_select_options" do
      send("#{field_name}_values").map do |value|
        [send("translate_#{field_name}_value", value), value]
      end
    end
  end
end
