class UserSocialAccount < ActiveRecord::Base
  validates_presence_of :user_id, :uuid, :provider
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => :user_id
end
