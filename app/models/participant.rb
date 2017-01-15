class Participant < ActiveRecord::Base
  belongs_to :conversation
end
