module SpecialtiesHelper
	def alphabetic_sort object
		object.sort_by { |hash| hash[:name][I18n.locale] }
	end
end
