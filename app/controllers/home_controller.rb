# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Admin dashboard / landing after login
  end

  def leaderboard
    @players = Player.rank_by_wins.select('players.*, COUNT(matches.id) as wins_total')
  end
end
