class FinancialInfo < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user

  validates :institution, presence: true
  validates :transit, presence: true
  validates :account, presence: true

  def description
    "#{institution} #{transit} #{account}"
  end
end
