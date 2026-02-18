class ChangePlayerCountryToCountryId < ActiveRecord::Migration[7.0]
  def change
    add_reference :players, :country, null: true, foreign_key: true

    # Drop the old country string column
    remove_column :players, :country, :string
  end
end
