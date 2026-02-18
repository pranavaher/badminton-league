class Match < ApplicationRecord
  belongs_to :player_a, class_name: 'Player'
  belongs_to :player_b, class_name: 'Player'

  belongs_to :winner, class_name: 'Player', optional: true
  belongs_to :loser, class_name: 'Player', optional: true

  validates :player_a, :player_b, presence: true
  validate :players_must_be_different

  # Assign a winner among the two players. Pass a Player id or :a/:b symbol.
  def decide_winner!(choice)
    win_id = case choice
             when :a, 'a' then player_a_id
             when :b, 'b' then player_b_id
             else
               choice.to_i
             end

    raise ArgumentError, 'Invalid winner' unless [player_a_id, player_b_id].include?(win_id)

    self.winner_id = win_id
    self.loser_id = (win_id == player_a_id) ? player_b_id : player_a_id
    save!
  end

  private

  def players_must_be_different
    return unless player_a_id.present? && player_b_id.present?

    errors.add(:player_b, 'must be different from player A') if player_a_id == player_b_id
  end
end
