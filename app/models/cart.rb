class Cart < ApplicationRecord
  ABANDONED_THRESHOLD = 3.hours
  REMOVABLE_THRESHOLD = 7.days

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  scope :abandoned_candidates, -> { where(abandoned_at: nil).where("updated_at < ?", ABANDONED_THRESHOLD.ago) }
  scope :removable_abandoned, -> { where("abandoned_at < ?", REMOVABLE_THRESHOLD.ago) }

  before_validation :set_default_total_price, on: :create

  def update_total_price!
    update!(total_price: cart_items.reload.sum(&:total_price))
  end

  private

  def set_default_total_price
    self.total_price ||= 0.0
  end
end
