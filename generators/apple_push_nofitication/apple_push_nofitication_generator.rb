class ApplePushNofiticationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory('db/migrate')
      m.file 'apple_push_notification.rb', "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_apple_push_notification.rb"
    end
  end
end
