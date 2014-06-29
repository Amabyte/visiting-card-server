class CreateVisitingCards < ActiveRecord::Migration
  def change
    create_table :visiting_cards do |t|
      t.references  :user, null: false
      t.references  :visiting_card_template, null: false
      t.attachment  :image
      t.timestamps
    end
  end
end
