class Api::V1::UserAccountController < AppController
  before_action :authenticate_api_user!, except: [:social_login]
  require 'social_login'
  
  def profile
    respond_with current_api_user
  end
  
  def social_login
    if (params[:provider].present? && params[:token].present? && params[:device_id].present? && params[:device_type].present?)
      social_user = SocialLogin.get_social_user params
      if social_user[:error].nil? && social_user[:email].present? && social_user[:uuid] && social_user[:provider].present?
        user = User.find_by_email social_user[:email]
        if user.nil?
          user = UserSocialAccount.find_by_uuid_and_provider(social_user[:uuid],social_user[:provider]).try(:user)
        end
        is_new_user = false
        if user.nil?
          is_new_user = true
          user = User.create_social_user social_user
        else
          user.name = social_user[:name]
          user.save!
        end
        unless user.errors.empty?
          social_login_error(user.errors.full_messages, :unprocessable_entity)
        else
          social_account = UserSocialAccount.new(uuid: social_user[:uuid], provider: social_user[:provider])
          social_account.user = user
          social_account.save
          sign_in user
          user.devices.where(device_id: params[:device_id]).destroy_all
          user.devices.build({session_id: session.id, device_id: params[:device_id], device_type: params[:device_type]})
          user.save
          response_json = {}
          response_json[:is_new_user] = is_new_user
          response_json[:user] = user
          render json: response_json, status: :ok
        end
      else
        if social_user[:error].nil? && social_user[:email].blank?
          social_login_error format, I18n.t("social_login.email_not_found"), :not_acceptable
        else
          social_login_error
        end
      end
    else
      social_login_error I18n.t("errors.params_missing"), :bad_request
    end
  end
 
  private

  def social_login_error error = I18n.t("social_login.default_error"), status = :failed_dependency
    result_error = (error.is_a? String) ? [error] : error
    render json: {errors: result_error}, status: status
  end
end