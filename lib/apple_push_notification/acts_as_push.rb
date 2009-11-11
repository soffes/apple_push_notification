require 'socket'
require 'openssl'

module ApplePushNotification
  module ActsAsPush
    
    APN_PORT = 2195
    @@apn_cert = nil
    @@apn_host = nil
    
    def self.apn_enviroment
      @@apn_enviroment
    end
    
    def self.apn_development?
      @@apn_enviroment != :production
    end

    def self.apn_production?
      @@apn_enviroment == :production
    end
    
    def self.apn_enviroment= enviroment
      @@apn_enviroment = enviroment.to_sym
      @@apn_host = self.apn_production? ? "gateway.push.apple.com" : "gateway.sandbox.push.apple.com"
      cert = self.apn_production? ? "apn_production.pem" : "apn_development.pem"
      path = File.join(File.expand_path(RAILS_ROOT), "config", "certs", cert)
      @@apn_cert = File.exists?(path) ? File.read(path) : nil
      raise "Missing apple push notification certificate in #{path}" unless @@apn_cert
    end
    
    self.apn_enviroment = :development

    attr_accessor :sound, :badge, :alert, :device_token

    def send_notification
      raise "Missing apple push notification certificate" unless @@apn_cert

      ctx = OpenSSL::SSL::SSLContext.new
      ctx.key = OpenSSL::PKey::RSA.new(@@apn_cert)
      ctx.cert = OpenSSL::X509::Certificate.new(@@apn_cert)

      s = TCPSocket.new(@@apn_host, APN_PORT)
      ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
      ssl.sync = true
      ssl.connect

      ssl.write(self.apn_message_for_sending)
      ssl.close
      s.close
    rescue SocketError => error
      raise "Error while sending notifications: #{error}"
    end
    
    def self.send_notification device_token, options = {}
      d = Object.new
      d.extend ApplePushNotification::ActsAsPush
      d.device_token = device_token
      d.alert = options[:alert] if options[:alert]
      d.badge = options[:badge] if options[:badge]
      d.sound = options[:sound] if options[:sound]
      d.send_notification
    end

    protected

    def to_apple_json
      json = self.apple_array.to_json
    end

    def apn_message_for_sending
      json = self.to_apple_json
      message = "\0\0 #{self.device_token_hexa}\0#{json.length.chr}#{json}"
      raise "The maximum size allowed for a notification payload is 256 bytes." if message.size.to_i > 256
      message
    end

    def device_token_hexa
      [self.device_token.delete(' ')].pack('H*')
    end

    def apple_array
      result = {}
      result['aps'] = {}
      result['aps']['alert'] = alert if alert
      result['aps']['badge'] = badge.to_i if badge
      result['aps']['sound'] = sound if sound and sound.is_a? String
      result['aps']['sound'] = 'default' if sound and sound.is_a? TrueClass
      result
    end
    
  end
end

ActiveRecord::Base.class_eval do
  
  def self.acts_as_push(unsupported_options = nil, &block)
    puts "** APN - acts_as_push"
    include ApplePushNotification::ActsAsPush
  end
end
