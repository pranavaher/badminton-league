# frozen_string_literal: true

class Player < ApplicationRecord
  validates :first_name, :last_name, presence: true

  def name
    "#{first_name} #{last_name}".strip
  end
end

