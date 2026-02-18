class AddCountryToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :country, :string, null: false, default: ''
    change_column_default :players, :country, nil
  end
end
