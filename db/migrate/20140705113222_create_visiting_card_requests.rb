class CreateVisitingCardRequests < ActiveRecord::Migration
  def change
    create_table :visiting_card_requests do |t|
      t.belongs_to :user, null: false
      t.integer :to_user_id, null: false
      t.text :message

      t.timestamps
    end
  end
end
