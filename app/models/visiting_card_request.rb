class VisitingCardRequest < ActiveRecord::Base
  validates_presence_of :user_id, :to_user_id
  belongs_to :user
  belongs_to :to_user, class_name: "User"
end