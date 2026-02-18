# frozen_string_literal: true

class Country < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :players, dependent: :nullify
  has_many :matches, foreign_key: 'venue_id', dependent: :nullify
end
