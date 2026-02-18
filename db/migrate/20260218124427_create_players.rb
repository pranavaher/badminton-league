# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.timestamps
    end

    add_index :players, %i[last_name first_name]
  end
end

