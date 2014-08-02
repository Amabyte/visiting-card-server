class AddActiveToVisitingCardTemplate < ActiveRecord::Migration
  def change
    add_column :visiting_card_templates, :active, :boolean, default: false, null: false
  end
end
