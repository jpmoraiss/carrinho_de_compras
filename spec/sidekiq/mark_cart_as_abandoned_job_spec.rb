require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }

    context 'marking abandoned carts' do
      let!(:active_cart) { Cart.create!(updated_at: (Cart::ABANDONED_THRESHOLD - 1.hour).ago) }
      let!(:abandoned_candidate) { Cart.create!(updated_at: (Cart::ABANDONED_THRESHOLD + 1.hour).ago) }
      let!(:already_abandoned) { Cart.create!(updated_at: (Cart::ABANDONED_THRESHOLD + 1.hour).ago, abandoned_at: 1.day.ago) }

      it 'updates abandoned_at for carts updated more than the threshold' do
        expect { job.perform }.to change { abandoned_candidate.reload.abandoned_at }.from(nil)
      end

      it 'does not update abandoned_at for active carts' do
        expect { job.perform }.not_to change { active_cart.reload.abandoned_at }
      end

      it 'does not update abandoned_at for already abandoned carts' do
        expect { job.perform }.not_to change { already_abandoned.reload.abandoned_at }
      end
    end

    context 'deleting old abandoned carts' do
      let!(:recent_abandoned) { Cart.create!(abandoned_at: (Cart::REMOVABLE_THRESHOLD - 1.day).ago) }
      let!(:old_abandoned) { Cart.create!(abandoned_at: (Cart::REMOVABLE_THRESHOLD + 1.day).ago) }
      let!(:not_abandoned) { Cart.create!(abandoned_at: nil) }

      it 'destroys carts abandoned more than the threshold' do
        expect { job.perform }.to change { Cart.count }.by(-1)
        expect(Cart.exists?(old_abandoned.id)).to be_falsey
      end

      it 'keeps recently abandoned carts' do
        job.perform
        expect(Cart.exists?(recent_abandoned.id)).to be_truthy
      end

      it 'keeps carts that are not abandoned' do
        job.perform
        expect(Cart.exists?(not_abandoned.id)).to be_truthy
      end
    end
  end
end
