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
        resources :visiting_card_templates, only: [:index, :show]
        resources :visiting_cards do
          member do
            post :share
          end
        end
        resources :friends_visiting_cards, only: [:index, :show, :destroy]
        resources :visiting_card_requests, only: [:index, :show, :create, :destroy] do
          collection do
            scope :my do
              get "/", to: :my_index
              scope ":id" do
                get "/", to: :my_show
                post "/accept", to: :accept
                delete "/ignore", to: :ignore
              end
            end
          end
        end
      end
    end
  end
  get "/downloads/vc/:id/:style/:attachment.:extension", to: "api/v1/visiting_cards#download_image"
  root to: "admin/dashboard#index"
end
