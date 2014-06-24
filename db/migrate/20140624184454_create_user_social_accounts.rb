class CreateUserSocialAccounts < ActiveRecord::Migration
  def change
    create_table :user_social_accounts do |t|
      t.references  :user, null: false
      t.string      :uuid, null: false
      t.string      :provider, null: false

      t.timestamps
    end
    add_index :user_social_accounts, [:uuid, :provider], unique: true
  end
end
