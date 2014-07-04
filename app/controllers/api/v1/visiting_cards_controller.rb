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
    send_file member.image.path(params[:style]), type: member.image.content_type
  end

  private
    def collection
      @visiting_cards ||= current_api_user.visiting_cards
    end

    def member
      @visiting_card ||= collection.find params[:id]
    end

    def visiting_card_params
      params.permit(:visiting_card_template_id, visiting_card_datas_attributes: [:key, :value, :image])
    end

end