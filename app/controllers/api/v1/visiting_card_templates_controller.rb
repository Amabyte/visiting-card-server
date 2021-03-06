class Api::V1::VisitingCardTemplatesController < AppController
  before_action :authenticate_api_user!
  
  def index
    respond_with paginate(VisitingCardTemplate)
  end

  def show
    respond_with VisitingCardTemplate.find params[:id]
  end

end