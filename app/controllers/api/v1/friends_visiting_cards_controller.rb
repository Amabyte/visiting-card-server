class Api::V1::FriendsVisitingCardsController < AppController
  before_action :authenticate_api_user!
  
  def index
    respond_with paginate(collection)
  end

  def show
    respond_with member
  end

  def destroy
    respond_with collection.destroy member
  end

  private
    def collection
      @friends_visiting_cards ||= current_api_user.friends_visiting_cards
    end

    def member
      @friends_visiting_card ||= collection.find params[:id]
    end
end