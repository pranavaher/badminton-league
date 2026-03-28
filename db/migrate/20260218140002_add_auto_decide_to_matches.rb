class AddAutoDecideToMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :auto_decide, :boolean, default: false, null: false
    add_column :matches, :job_id, :string
  end
end
