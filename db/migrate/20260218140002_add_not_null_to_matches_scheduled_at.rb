class AddNotNullToMatchesScheduledAt < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE matches
      SET scheduled_at = created_at
      WHERE scheduled_at IS NULL
    SQL

    change_column_null :matches, :scheduled_at, false
  end

  def down
    change_column_null :matches, :scheduled_at, true
  end
end
