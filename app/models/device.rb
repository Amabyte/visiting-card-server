class Device < ActiveRecord::Base
  validates_presence_of :user_id, :session_id, :device_id, :device_type
  belongs_to :user

  ANDROID = "android"
  IOS = "ios"

  def self.device_types
    [ANDROID, IOS]
  end

  def self.device_ids user
    user.devices.map(&:device_id)
  end

  validates_inclusion_of :device_type, :in => device_types, :message => "should be either '#{ANDROID}' or '#{IOS}'"
end
