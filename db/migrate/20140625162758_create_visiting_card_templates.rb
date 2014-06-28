class CreateVisitingCardTemplates < ActiveRecord::Migration
  def change
    create_table :visiting_card_templates do |t|
      t.string :name, null: false
      t.text :design, null: false

      t.timestamps
    end
  end
end
