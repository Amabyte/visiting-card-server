
VisitingCardServer::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  api vendor_string: "visiting-card", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        devise_for :users, :skip => [:registration], controllers: { sessions: "api/v1/user_session" }
        devise_scope :user do
          resources :users, controller: "user_account", :only =>[] do
            collection do
              post :social_login
              get :profile
            end
          end
        end
      end
    end
  end
  root to: "admin/dashboard#index"
end
