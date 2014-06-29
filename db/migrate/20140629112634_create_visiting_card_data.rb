class CreateVisitingCardData < ActiveRecord::Migration
  def change
    create_table :visiting_card_data do |t|
      t.references  :visiting_card, null: false
      t.string  :key, null: false
      t.string  :value, null: false
      t.attachment  :image

      t.timestamps
    end
  end
end
