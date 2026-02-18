class AutoDecideWinnerJob
  include Sidekiq::Job

  def perform(match_id)
    match = Match.find_by(id: match_id)
    return unless match

    # If match already has a winner or isn't in auto_decide mode, skip
    return if match.winner.present? || !match.auto_decide

    # Randomly pick a winner from the two players
    winner_choice = [match.player_a_id, match.player_b_id].sample

    match.decide_winner!(winner_choice)
  end
end
