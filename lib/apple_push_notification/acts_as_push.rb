module ApplePushNotification
  module ActsAsPush
  end
end

ActiveRecord::Base.class_eval do
  def self.acts_as_push(unsupported_options = nil, &block)
    include ApplePushNotification
  end
end
