require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:country) { create(:country) }

  describe 'associations' do
    it { is_expected.to belong_to(:country) }
    it { is_expected.to have_many(:wins) }
    it { is_expected.to have_many(:losses) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to belong_to(:country).required }
  end

  describe '#name' do
    let(:player) { create(:player, first_name: 'John', last_name: 'Doe') }

    it 'returns full name' do
      expect(player.name).to eq('John Doe')
    end

    it 'strips extra whitespace' do
      player.first_name = 'John'
      player.last_name = 'Doe'
      expect(player.name).to eq('John Doe')
    end
  end

  describe '#wins_count' do
    let(:player) { create(:player) }
    let(:opponent) { create(:player) }

    it 'returns the number of wins' do
      create(:match, player_a: player, player_b: opponent, winner: player)
      create(:match, player_a: player, player_b: opponent, winner: player)
      expect(player.wins_count).to eq(2)
    end
  end

  describe '#losses_count' do
    let(:player) { create(:player) }
    let(:opponent) { create(:player) }

    it 'returns the number of losses' do
      create(:match, player_a: player, player_b: opponent, winner: opponent)
      create(:match, player_a: opponent, player_b: player, winner: opponent)
      expect(player.losses_count).to eq(2)
    end
  end

  describe '.rank_by_wins' do
    let(:player1) { create(:player) }
    let(:player2) { create(:player) }
    let(:opponent) { create(:player) }

    before do
      # Player 1 has 3 wins
      create(:match, player_a: player1, player_b: opponent, winner: player1)
      create(:match, player_a: player1, player_b: opponent, winner: player1)
      create(:match, player_a: player1, player_b: opponent, winner: player1)

      # Player 2 has 1 win
      create(:match, player_a: player2, player_b: opponent, winner: player2)
    end

    it 'returns players ordered by wins descending' do
      ranking = Player.rank_by_wins
      expect(ranking.first).to eq(player1)
      expect(ranking.second).to eq(player2)
    end
  end
end
