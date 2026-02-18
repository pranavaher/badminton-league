require 'rails_helper'

RSpec.describe AutoDecideWinnerJob, type: :job do
  let(:player_a) { create(:player) }
  let(:player_b) { create(:player) }
  let(:match) { create(:match, :auto_decide, :scheduled_in_past, player_a: player_a, player_b: player_b) }

  describe '#perform' do
    it 'assigns a winner randomly' do
      job = described_class.new
      job.perform(match.id)
      match.reload
      expect(match.winner).to be_present
      expect([player_a, player_b]).to include(match.winner)
    end

    it 'assigns a loser' do
      job = described_class.new
      job.perform(match.id)
      match.reload
      expect(match.loser).to be_present
      expect([player_a, player_b]).to include(match.loser)
    end

    it 'winner and loser are different' do
      job = described_class.new
      job.perform(match.id)
      match.reload
      expect(match.winner).not_to eq(match.loser)
    end

    it 'skips if match already has winner' do
      decided_match = create(:match, :auto_decide, :with_winner, player_a: player_a, player_b: player_b)
      original_winner = decided_match.winner
      job = described_class.new
      job.perform(decided_match.id)
      decided_match.reload
      expect(decided_match.winner).to eq(original_winner)
    end

    it 'skips if auto_decide is false' do
      manual_match = create(:match, auto_decide: false, player_a: player_a, player_b: player_b)
      job = described_class.new
      job.perform(manual_match.id)
      manual_match.reload
      expect(manual_match.winner).to be_nil
    end

    it 'handles missing match gracefully' do
      job = described_class.new
      expect { job.perform(99999) }.not_to raise_error
    end
  end
end
