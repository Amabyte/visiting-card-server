ActiveAdmin.register VisitingCardTemplate do
  permit_params :name, :design, :sample, :bg_image

  form do |f|
    f.inputs do
      f.input :name
      f.input :design
      f.input :bg_image, :required => false, :as => :file
      f.input :sample, :required => true, :as => :file
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
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :sample do |offer|
      image_tag(offer.sample.url(:thumb))
    end
    column :created_at
    column :updated_at
    actions
  end

end