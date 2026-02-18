# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Admin dashboard / landing after login
  end

  def leaderboard
    @players = Player.rank_by_wins.select('players.*, COUNT(matches.id) as wins_total')
  end

  def statistics
    # Matches per venue
    @matches_per_venue = Country.left_joins(:matches).group('countries.id').select('countries.*, COUNT(matches.id) AS matches_count').order('matches_count DESC')

    # Win/Loss per player country
    @country_stats = Country.order(:name).map do |c|
      player_ids = Player.where(country_id: c.id).pluck(:id)
      wins = player_ids.any? ? Match.where(winner_id: player_ids).count : 0
      losses = player_ids.any? ? Match.where(loser_id: player_ids).count : 0
      { country: c, wins: wins, losses: losses }
    end
  end
end
