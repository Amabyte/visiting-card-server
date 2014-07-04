class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.belongs_to :user, null: false
      t.string :session_id, null: false
      t.string :device_id, null: false
      t.string :device_type, null: false

      t.timestamps
    end
  end
end
