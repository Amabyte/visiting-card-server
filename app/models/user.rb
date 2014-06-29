class User < ActiveRecord::Base
  validates_presence_of :name, :email
  validates :email, :uniqueness => true, format: {with: Settings.regx_email }
  has_many :user_social_accounts, dependent: :destroy
  has_many :visiting_cards, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.create_social_user social_user
    user = User.new(name: social_user[:name], email: social_user[:email], password: Devise.friendly_token.first(8))
    user.save
    user
  end
end
