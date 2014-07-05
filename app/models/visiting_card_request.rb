class VisitingCardRequest < ActiveRecord::Base
  validates_presence_of :user_id, :to_user_id
  belongs_to :user
  belongs_to :to_user, class_name: "User"
  after_create :notify_to_user

  private
    def notify_to_user
      push = {title: "#{user.name} is requesting your visiting card", type: "vc_request", id: id}
      push[:message] = message if message.present?
      PushNotification.send Device.device_ids(to_user), push
    end
end