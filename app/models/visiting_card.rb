class VisitingCard < ActiveRecord::Base
  validates_presence_of :user_id, :visiting_card_template_id, :visiting_card_template
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :path => ":rails_root/data/images/vc/:id/:style/:attachment.:extension",:url => "/downloads/vc/:id/:style/:attachment.:extension"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  belongs_to :user
  has_many :visiting_card_datas, dependent: :destroy, inverse_of: :visiting_card
  has_and_belongs_to_many :users, -> { uniq }, foreign_key: "fvc_id"
  accepts_nested_attributes_for :visiting_card_datas
  belongs_to :visiting_card_template
  before_create :prepare
  after_create :prepare_update
  before_update :prepare_update

  validate :must_have_at_least_one_vcd

  def prepare is_image = false
    begin
      hash = {}
      visiting_card_datas.each do |vcd|
        if vcd.value == "vcimagevc"
          hash[vcd.key] = vcd.image.path if vcd.image.present? and is_image
        else
          hash[vcd.key] = vcd.value
        end
      end
      raise "visiting card template not found." unless visiting_card_template
      visiting_card_template.prepare hash
      self.image = File.open(visiting_card_template.image_file_path)
    rescue => e
      errors[:image] << e.message
      return false
    end
  end

  def prepare_update
    prepare true
  end

  def image_url
    {original: image.url, thumb: image.url(:thumb), medium: image.url(:medium)}
  end

  def as_json(options = {})
    super({except: [:image_file_name, :image_content_type, :image_file_size, :image_updated_at], :methods => [:image_url, :visiting_card_datas]}.merge(options))
  end

  private
    def must_have_at_least_one_vcd
      errors.add(:visiting_card_datas, 'must have at least one visiting card data') if visiting_card_datas.empty?
    end
end