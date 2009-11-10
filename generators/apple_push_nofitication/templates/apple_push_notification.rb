class CreateApplePushNotifications < ActiveRecord::Migration
  def self.up
		# This is used to store the device UID informations
    create_table :apple_push_notifications do |t|
			t.string :device_token, :size => 71
			t.integer :errors_nb, :default => 0 # used for storing errors from apple feedbacks
			t.string :device_language, :size => 5 # if you don't want to send localized strings

      t.timestamps
    end
		
		add_index :apple_push_notifications, :device_token
  end

  def self.down
    drop_table :apple_push_notifications
  end
end
