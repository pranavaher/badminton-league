class AddPlayersAndNameToMatches < ActiveRecord::Migration[7.0]
  def change
    add_reference :matches, :player_a, foreign_key: { to_table: :players }
    add_reference :matches, :player_b, foreign_key: { to_table: :players }
    add_column :matches, :name, :string

    change_column_null :matches, :winner_id, true
    change_column_null :matches, :loser_id, true
  end
end
