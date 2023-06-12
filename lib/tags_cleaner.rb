module TagsCleaner
  def self.clean
    Tag.all.each do |tag|
      users_tagged = User.tagged_with(tag.name).distinct
      tag.destroy if users_tagged.count == 0
    end
  end
end
