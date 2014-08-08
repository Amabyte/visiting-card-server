class VisitingCardData < ActiveRecord::Base
  validates_presence_of :visiting_card, :key, :value
  has_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  belongs_to :visiting_card

  def as_json(options = {})
    super({only: [:key, :value]}.merge(options))
  end
end
