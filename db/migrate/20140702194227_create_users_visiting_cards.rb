class CreateUsersVisitingCards < ActiveRecord::Migration
  def change
    create_table :users_visiting_cards, id: false do |t|
      t.references :user
      t.integer :fvc_id
    end
  end
end
