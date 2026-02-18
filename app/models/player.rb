# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :country, optional: false

  validates :first_name, :last_name, presence: true

  def name
    "#{first_name} #{last_name}".strip
  end

  has_many :wins,
           class_name: 'Match',
           foreign_key: 'winner_id',
           dependent: :nullify

  has_many :losses,
           class_name: 'Match',
           foreign_key: 'loser_id',
           dependent: :nullify

  def wins_count
    wins.count
  end

  def losses_count
    losses.count
  end

  def self.rank_by_wins
    left_joins(:wins).group('players.id').order('COUNT(matches.id) DESC, players.last_name ASC')
  end
end

