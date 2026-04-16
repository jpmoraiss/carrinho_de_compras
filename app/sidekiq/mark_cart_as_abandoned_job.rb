require 'sidekiq-scheduler'

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_abandoned_carts
    delete_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.abandoned_candidates.update_all(abandoned_at: Time.current)
  end

  def delete_old_abandoned_carts
    Cart.removable_abandoned.destroy_all
  end
end
