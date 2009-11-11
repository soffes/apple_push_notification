module ApplePushNotification
  module ActsAsPushable
  end
end

ActiveRecord::Base.class_eval do
  def self.acts_as_pushable(device_token_field = :device_token)
    class_inheritable_reader :acts_as_push_options
    write_inheritable_attribute :acts_as_push_options, {
      :device_token_field => device_token_field
    }
    include ApplePushNotification
  end
end
