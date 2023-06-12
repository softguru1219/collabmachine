module Utils
  module Locales
    extend self

    def translated_param_names(*param_names)
      param_names.map do |param_name|
        I18n.available_locales.map do |locale|
          :"#{param_name}_#{Mobility.normalize_locale(locale)}"
        end
      end.flatten
    end
  end
end
