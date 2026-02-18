class Match < ApplicationRecord
  belongs_to :player_a, class_name: 'Player'
  belongs_to :player_b, class_name: 'Player'
  belongs_to :venue, class_name: 'Country', optional: false

  belongs_to :winner, class_name: 'Player', optional: true
  belongs_to :loser, class_name: 'Player', optional: true

  validates :player_a, :player_b, presence: true
  validate :players_must_be_different
  validate :scheduled_at_must_be_future

  # Check if the match has been scheduled for a past date/time
  def scheduled_in_past?
    scheduled_at.present? && scheduled_at < Time.current
  end

  # Check if the match can have a winner decided
  def can_decide_winner?
    scheduled_in_past?
  end

  # Assign a winner among the two players. Pass a Player id or :a/:b symbol.
  def decide_winner!(choice)
    raise 'Match must be scheduled in the past to decide a winner.' unless can_decide_winner?

    win_id = case choice
             when :a, 'a' then player_a_id
             when :b, 'b' then player_b_id
             else
               choice.to_i
             end

    raise ArgumentError, 'Invalid winner' unless [player_a_id, player_b_id].include?(win_id)

    self.winner_id = win_id
    self.loser_id = (win_id == player_a_id) ? player_b_id : player_a_id
    # Persist winner/loser without running regular model validations
    # (scheduled_at_must_be_future is intended for create/update of matches)
    update_columns(winner_id: winner_id, loser_id: loser_id, updated_at: Time.current)
  end

  private

  def players_must_be_different
    return unless player_a_id.present? && player_b_id.present?

    errors.add(:player_b, 'must be different from player A') if player_a_id == player_b_id
  end

  def scheduled_at_must_be_future
    return unless scheduled_at.present?

    errors.add(:scheduled_at, 'must be in the future') if scheduled_at <= Time.current
  end
end
