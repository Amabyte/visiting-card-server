class VisitingCardData < ActiveRecord::Base
  validates_presence_of :visiting_card, :key, :value
  has_attached_file :image, :path => ":rails_root/data/images/vc/:visiting_card_id/vcd/:key.:extension"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  belongs_to :visiting_card

  def as_json(options = {})
    super({only: [:key, :value]}.merge(options))
  end
end
