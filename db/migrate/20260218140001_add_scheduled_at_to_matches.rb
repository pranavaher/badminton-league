class AddScheduledAtToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :scheduled_at, :datetime
  end
end
