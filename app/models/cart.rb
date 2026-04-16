class Cart < ApplicationRecord
  ABANDONED_THRESHOLD = 3.hours
  REMOVABLE_THRESHOLD = 7.days

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  scope :abandoned_candidates, -> { where(abandoned_at: nil).where("updated_at < ?", ABANDONED_THRESHOLD.ago) }
  scope :removable_abandoned, -> { where("abandoned_at < ?", REMOVABLE_THRESHOLD.ago) }

  def total_price
    cart_items.inject(0) { |sum, item| sum + item.total_price }
  end
end
