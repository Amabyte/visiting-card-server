class Api::V1::UserSessionController < Devise::SessionsController
   def create
    self.resource = User.find_by_email(params[:user][:email])
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end