class Api::V1::UserSessionController < Devise::SessionsController
  before_action :delete_device, only: [:destroy]

  def create
    self.resource = User.find_by_email(params[:user][:email])
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  private
    def delete_device
      current_api_user.devices.where(session_id: session.id).destroy_all if current_api_user
    end
end