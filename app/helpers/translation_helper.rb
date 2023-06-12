module TranslationHelper
  # see https://github.com/shioyama/mobility/wiki/Using-Mobility-with-Forms
  def locale_fields(record, field_name, &block)
    locales = I18n.available_locales.sort_by { |l| l == I18n.locale ? 0 : 1 }

    locales.each do |locale|
      normalized_locale = Mobility.normalize_locale(locale)
      attr_name = "#{field_name}_#{normalized_locale}"
      label = "#{record.class.human_attribute_name(field_name)} (#{normalized_locale})"

      block.call(attr_name, label)
    end
  end

  def locale_field(record, field_name, locale, &block)
    normalized_locale = Mobility.normalize_locale(locale)
    attr_name = "#{field_name}_#{normalized_locale}"
    label = "#{record.class.human_attribute_name(field_name)} (#{normalized_locale})"

    block.call(attr_name, label)
  end
end
