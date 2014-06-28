class AddAttachmentSampleToVisitingCardTemplates < ActiveRecord::Migration
  def self.up
    change_table :visiting_card_templates do |t|
      t.attachment :sample
      t.attachment :bg_image
    end
  end

  def self.down
    drop_attached_file :visiting_card_templates, :sample
    drop_attached_file :visiting_card_templates, :bg_image
  end
end
