class Api::V1::VisitingCardsController < AppController
  before_action :authenticate_api_user!
  
  def index
    respond_with collection
  end

  def show
    respond_with member
  end

  def destroy
    respond_with member.destroy
  end

  def create
    @visiting_card = collection.build visiting_card_params
    if @visiting_card.save
      respond_with @visiting_card, status: :created, location: '/'
    else
      render json: @visiting_card.errors, status: :unprocessable_entity
    end
  end

  def download_image
    @visiting_card = current_api_user.visiting_cards.find_by_id(params[:id]) || current_api_user.friends_visiting_cards.find_by_id(params[:id])
    send_file member.image.path(params[:style]), type: member.image.content_type
  end

  def share
    if params[:email].present?
      user = User.find_by_email params[:email]
      if user
        if user != current_api_user
          user.friends_visiting_cards << member
          PushNotification.send(Device.device_ids(user), {title: "#{current_api_user.name} has shared visiting card with you", type: "vc_shared"})
          render json: {message: "Visiting card successfully shared"}
        else
          render json: {errors: ["Can't share visiting card your self"]}, status: :method_not_allowed
        end
      else
        render nothing: true, status: :not_found
      end
    else
      render json: {errors: [I18n.t("errors.params_missing")]}, status: :bad_request
    end
  end

  private
    def collection
      @visiting_cards ||= current_api_user.visiting_cards
    end

    def member
      @visiting_card ||= collection.find params[:id]
    end

    def visiting_card_params
      params.require(:visiting_card).permit(:visiting_card_template_id, visiting_card_datas_attributes: [:key, :value, :image])
    end

end