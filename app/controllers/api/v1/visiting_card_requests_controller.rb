class Api::V1::VisitingCardRequestsController < AppController
  before_action :authenticate_api_user!
  
  def index
    respond_with collection
  end

  def show
    respond_with member
  end

  def my_index
    respond_with my_collection
  end

  def my_show
    respond_with my_member
  end

  def create
    if params[:email].present?
      user = User.find_by_email params[:email]
      if user
        if user != current_api_user
          @visiting_card_request = collection.build(to_user: user, message: params[:message])
          if @visiting_card_request.save
            respond_with @visiting_card_request, status: :created, location: '/'
          else
            render json: @visiting_card.errors, status: :unprocessable_entity
          end
        else
          render json: {errors: ["Can't request for visiting card your self"]}, status: :method_not_allowed
        end
      else
        render nothing: true, status: :not_found
      end
    else
      render json: {errors: [I18n.t("errors.params_missing")]}, status: :bad_request
    end
  end

  def destroy
    respond_with collection.destroy member
  end

  def accept
    if params[:visiting_card_id].present?
      vc = current_api_user.visiting_cards.find params[:visiting_card_id]
      my_member.user.friends_visiting_cards << vc
      PushNotification.send(Device.device_ids(my_member.user), {title: "#{my_member.to_user.name} has shared visiting card with you", type: "vc_accept"})
      my_member.destroy
      render json: {message: "Visiting card successfully accepted"}
    else
      render json: {errors: [I18n.t("errors.params_missing")]}, status: :bad_request
    end
  end

  def decline
    PushNotification.send(Device.device_ids(my_member.user), {title: "#{my_member.to_user.name} has declined to share the visiting card", type: "vc_decline"})
    respond_with my_collection.destroy my_member
  end

  private
    def collection
      @visiting_card_requests ||= current_api_user.visiting_card_requests
    end

    def member
      @visiting_card_request ||= collection.find params[:id]
    end

    def my_collection
      @my_visiting_card_requests ||= current_api_user.my_visiting_card_requests
    end

    def my_member
      @my_visiting_card_request ||= my_collection.find params[:id]
    end
end