module WiphomepageHelper
	def sector_exp_years(specialty)
		results = []
		specialty.specialty_lines.each do |l|
    	results << "#{Sector.find(l.sector_id).name} (#{l.experience} #{t("g.years")})"
    end
    results.join(', ')
	end
end
