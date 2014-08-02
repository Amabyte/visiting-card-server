ActiveAdmin.register VisitingCardTemplate do
  permit_params :name, :design, :sample, :bg_image, :active

  form do |f|
    f.inputs do
      f.input :name
      f.input :design
      f.input :bg_image, :required => false, :as => :file
      f.input :sample, :required => true, :as => :file
      f.input :active
    end
    f.actions
  end

  show do |vct|
    attributes_table do
      row :name
      row :design
      row :bg_image do
        image_tag(vct.bg_image.url) if vct.bg_image.present?
      end
      row :sample do
        image_tag(vct.sample.url)
      end
      row :active
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :sample do |offer|
      image_tag(offer.sample.url(:thumb))
    end
    column :active
    column :created_at
    column :updated_at
    actions
  end

  scope_to do
    Class.new do
      def self.visiting_card_templates
        VisitingCardTemplate.unscoped
      end
    end
  end

  member_action :try_vc do
    @vct = VisitingCardTemplate.unscoped.find params[:id]
    @data = params[:data].present? ? params[:data] : []
    @kts = @vct.keys_and_types
    hash = {}
    @data.each_with_index do |v, i|
      if @kts[i][:type] == VisitingCardTemplate::TYPE_TEXT || @kts[i][:type] == VisitingCardTemplate::TYPE_TEXT_AREA
        hash[@kts[i][:key]] = @data[i] if @data[i].present?
      end
    end
    @vct.prepare hash
    @vct.write_to_sample
  end

  action_item :only => :show do
    link_to('Try VC', try_vc_admin_visiting_card_template_path)
  end


end