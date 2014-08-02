class VisitingCardTemplate < ActiveRecord::Base
  require 'RMagick'
  require 'rvg/misc'
  include Magick
  default_scope where(active: true)
  validates_presence_of :name, :design
  validate :key_uniqueness
  has_attached_file :sample, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :path => ":rails_root/public/system/vct/:id/:style/:attachment.:extension",:url => "/system/vct/:id/:style/:attachment.:extension"
  validates_attachment_content_type :sample, :content_type => /\Aimage\/.*\Z/
  validates_attachment_presence :sample
  has_attached_file :bg_image, :path => ":rails_root/public/system/vct/:id/:attachment.:extension",:url => "/system/vct/:id/:attachment.:extension"
  validates_attachment_content_type :bg_image, :content_type => /\Aimage\/.*\Z/
  has_many :visiting_cards

  GRAVITY_NAMES = {northwest: NorthWestGravity, north: NorthGravity, northeast: NorthEastGravity, west: WestGravity, center: CenterGravity, east: EastGravity, southwest: SouthWestGravity, south: SouthGravity, southeast: SouthEastGravity}.freeze

  TYPE_BG = "background"
  TYPE_TEXT = "text"
  TYPE_TEXT_AREA = "text_area"
  TYPE_IMAGE = "image"

  WIDTH = 512
  HEIGHT = 307

  def prepare options
    raise("At least background should be defined.") unless configs.length > 0
    raise("First config item should be background.") unless configs[0]["type"] == TYPE_BG
    @options = options
    configs.each do |item|
      case item["type"]
      when TYPE_BG
        prepare_background item
      when TYPE_TEXT, TYPE_TEXT_AREA
        prepare_text item
      when TYPE_IMAGE
        prepare_image item
      end
    end
    @image = @t_image
  end

  def image
    raise("VisitingCardTemplate not prepared yet. Call 'prepare' before calling this method.") if @image.nil?
    @image
  end

  def image_file_path
    file = File.join(Rails.root, "public", "generated.jpg")
    image.write file
    file
  end

  def write_to_sample
    file = File.open(image_file_path)
    self.sample = file
    file.close
    save
  end

  def keys_and_types
    results = []
    configs.each_with_index do |item, i|
      next if i == 0
      results << {type: item["type"], key: item["key"]}
    end
    results
  end

  def sample_urls
    {original: sample.url, thumb: sample.url(:thumb), medium: sample.url(:medium)}
  end

  def as_json(options = {})
    super({only: [:id, :name], :methods => [:sample_urls, :keys_and_types]}.merge(options))
  end

  def configs
    @configs ||= JSON.parse(design)
  end

  private
    def prepare_background bg_config
      background_found = false
      @t_image = nil
      unless bg_config.nil?
        if bg_image
          background_found = true
          @t_image = ImageList.new(bg_image.path).first
        elsif bg_config["color"]
          background_found = true
          color = bg_config["color"]
          @t_image = Image.new(WIDTH, HEIGHT) { self.background_color = color}
        end
      end
      raise("Background not defined.") unless background_found
      @t_image
    end

    def prepare_text text_config
      if @options[text_config["key"]]
        if text_config["width"] && text_config["height"] && text_config["x"] && text_config["y"]
          Draw.new.annotate(@t_image, text_config["width"], text_config["height"], text_config["x"], text_config["y"], @options[text_config["key"]]) do
              font_config = text_config["font"]
              if font_config
                self.font_family = font_config["family"] if font_config["family"]
                self.font = font_config["name"] if font_config["name"]
                self.fill = font_config["color"] if font_config["color"]
                self.pointsize = font_config["size"] if font_config["size"]
                self.interline_spacing = font_config["line_spacing"] if font_config["line_spacing"]
                self.interword_spacing = font_config["word_spacing"] if font_config["word_spacing"]
                self.kerning = font_config["kerning"] if font_config["kerning"]
                self.rotation = font_config["rotation"] if font_config["rotation"]
                self.stroke = font_config["stroke"] if font_config["stroke"]
                self.stroke_width = font_config["stroke_width"] if font_config["stroke_width"]
                self.undercolor = font_config["undercolor"] if font_config["undercolor"]
                self.text_antialias = font_config["antialias"] if font_config["antialias"]
                self.gravity = VisitingCardTemplate::GRAVITY_NAMES[font_config["gravity"].to_sym] if font_config["gravity"]
                self.font_weight = RVG::Utility::GraphicContext::FONT_WEIGHT[font_config["weight"]] if font_config["weight"]
                self.font_style = RVG::Utility::GraphicContext::FONT_STYLE[font_config["style"].to_sym] if font_config["style"]
                self.font_stretch = RVG::Utility::GraphicContext::FONT_STRETCH[font_config["stretch"].to_sym] if font_config["stretch"]
                self.align = RVG::Utility::GraphicContext::ANCHOR_TO_ALIGN[font_config["align"].to_sym] if font_config["align"]
                self.decorate = RVG::Utility::GraphicContext::TEXT_DECORATION[font_config["decorate"].to_sym] if font_config["decorate"]
              end
          end
        else
          raise(ArgumentError, "'width', 'height', 'x' and 'y' required for #{text}")
        end
      end
    end

    def prepare_image image_config
      if @options[image_config["key"]]
        if (image_config["x"] && image_config["y"]) || image_config["gravity"]
          c_image = Image.read(@options[image_config["key"]]).first
          if image_config["resize"]
            c_image = c_image.resize_to_fit(image_config["resize"]["width"], image_config["resize"]["height"])
          end
          if image_config["x"] && image_config["y"] && image_config["gravity"]
            @t_image = @t_image.composite(c_image, VisitingCardTemplate::GRAVITY_NAMES[image_config["gravity"].to_sym], image_config["x"], image_config["y"], AtopCompositeOp)
          elsif image_config["gravity"]
            @t_image = @t_image.composite(c_image, VisitingCardTemplate::GRAVITY_NAMES[image_config["gravity"].to_sym], AtopCompositeOp)
          else
             @t_image = @t_image.composite(c_image, image_config["x"], image_config["y"], AtopCompositeOp)
          end
        else
          raise(ArgumentError, "'x' and 'y' or 'gravity' required for #{image_config["key"]}")
        end
      end
    end

    def key_uniqueness
      if configs.uniq{|x| x["key"]}.length != configs.length
        errors[:design] << 'duplicate keys are not allowed'
      end
    end
end