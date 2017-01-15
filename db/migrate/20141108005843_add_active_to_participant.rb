class AddActiveToParticipant < ActiveRecord::Migration
  def change
    #For storing active conversation
    add_column :participants, :active, :boolean, default: false
  end
end
