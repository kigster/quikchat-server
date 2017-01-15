class DropUpdatedAtFromMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :updated_at
  end

  def down
    add_column :messages, :updated_at, :datetime
  end
end
