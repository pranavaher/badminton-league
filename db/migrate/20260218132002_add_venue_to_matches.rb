class AddVenueToMatches < ActiveRecord::Migration[7.0]
  def change
    add_reference :matches, :venue, null: true, foreign_key: { to_table: :countries }
  end
end
