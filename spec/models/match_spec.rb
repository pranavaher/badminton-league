require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:player_a) { create(:player) }
  let(:player_b) { create(:player) }
  let(:country) { create(:country) }

  describe 'associations' do
    it { is_expected.to belong_to(:player_a) }
    it { is_expected.to belong_to(:player_b) }
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to have_one(:winner) }
    it { is_expected.to have_one(:loser) }
  end

  describe 'validations' do
    subject { build(:match) }

    it { is_expected.to validate_presence_of(:player_a) }
    it { is_expected.to validate_presence_of(:player_b) }
  end

  describe '#scheduled_in_past?' do
    it 'returns true if scheduled_at is in past' do
      match = build(:match, :scheduled_in_past)
      expect(match.scheduled_in_past?).to be true
    end

    it 'returns false if scheduled_at is in future' do
      match = build(:match, scheduled_at: 2.days.from_now)
      expect(match.scheduled_in_past?).to be false
    end
  end

  describe '#can_decide_winner?' do
    it 'returns true if scheduled_at is in past' do
      match = create(:match, :scheduled_in_past)
      expect(match.can_decide_winner?).to be true
    end

    it 'returns false if scheduled_at is in future' do
      match = create(:match, scheduled_at: 2.days.from_now)
      expect(match.can_decide_winner?).to be false
    end
  end

  describe '#decide_winner!' do
    let(:match) { create(:match, :scheduled_in_past, player_a: player_a, player_b: player_b) }

    it 'assigns player_a as winner' do
      match.decide_winner!(:a)
      expect(match.winner).to eq(player_a)
      expect(match.loser).to eq(player_b)
    end

    it 'assigns player_b as winner' do
      match.decide_winner!(:b)
      expect(match.winner).to eq(player_b)
      expect(match.loser).to eq(player_a)
    end

    it 'accepts player id as winner choice' do
      match.decide_winner!(player_a.id)
      expect(match.winner).to eq(player_a)
      expect(match.loser).to eq(player_b)
    end

    it 'raises error if invalid winner' do
      expect { match.decide_winner!(9999) }.to raise_error(ArgumentError)
    end

    it 'raises error if match not scheduled in past' do
      future_match = create(:match, scheduled_at: 2.days.from_now)
      expect { future_match.decide_winner!(:a) }.to raise_error
    end
  end

  describe 'auto_decide feature' do
    let(:future_match) { create(:match, scheduled_at: 2.hours.from_now) }

    describe '#schedule_auto_decide_job' do
      it 'schedules job if auto_decide is true and scheduled_at is in future' do
        match = create(:match, auto_decide: true, scheduled_at: 2.hours.from_now)
        expect(match.job_id).to be_present
      end

      it 'does not schedule job if auto_decide is false' do
        match = create(:match, auto_decide: false)
        expect(match.job_id).to be_nil
      end
    end

    describe '#cancel_auto_decide_job' do
      let(:match) { create(:match, auto_decide: true, scheduled_at: 2.hours.from_now) }

      it 'clears job_id' do
        job_id_before = match.job_id
        match.cancel_auto_decide_job
        expect(match.job_id).to be_nil
      end
    end
  end

  describe 'validations for auto_decide' do
    it 'validates that auto_decide requires future scheduled_at' do
      match = build(:match, auto_decide: true, scheduled_at: 1.hour.ago)
      expect(match).not_to be_valid
      expect(match.errors[:auto_decide]).to include('requires scheduled_at to be in the future')
    end

    it 'allows auto_decide for future scheduled_at' do
      match = build(:match, auto_decide: true, scheduled_at: 2.hours.from_now)
      expect(match).to be_valid
    end
  end

  describe 'players must be different' do
    it 'validates that player_a and player_b are different' do
      match = build(:match, player_a: player_a, player_b: player_a)
      expect(match).not_to be_valid
      expect(match.errors[:player_b]).to be_present
    end

    it 'allows different players' do
      match = build(:match, player_a: player_a, player_b: player_b)
      expect(match).to be_valid
    end
  end
end
