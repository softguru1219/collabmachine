class Post < ApplicationRecord
  acts_as_taggable_on :tags
  has_rich_text :body
  has_one_attached :image

  scope :published, -> { where(published: true) }
  scope :by_recent, -> { order(published_at: :desc) }

  scope :style, -> { tagged_with('style') }
  scope :entertainment, -> { tagged_with('entertainment') }
  scope :culture, -> { tagged_with('culture') }

  def prev
    self.class.where("id < ?", id).published.by_recent.limit(1).first
  end

  def next
    self.class.where("id > ?", id).published.by_recent.limit(1).first
  end

  def acceptable_image
    return unless image.attached?

    errors.add(:image, "is too big") unless image.byte_size <= 20.megabyte

    acceptable_types = ["image/jpeg", "image/png", "image/jpg", "image/gif"]
    errors.add(:image, "must be a JPEG, PNG, JPG or GIF") unless acceptable_types.include?(image.content_type)
  end
end
