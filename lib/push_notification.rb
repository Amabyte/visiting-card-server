class PushNotification
  require 'gcm'

  def self.send ids, data
    if ids.length > 0
      gcm = GCM.new(Settings.gcm_api_key)
      response = gcm.send_notification(ids, data)
    end
  end
end