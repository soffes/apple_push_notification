require 'socket'
require 'openssl'

module ApplePushNotification

  def self.extended(base)
    # Added device_token attribute if not included by acts_as_pushable
    unless base.respond_to?(:acts_as_push_options)
      base.class_eval do
        attr_accessor :device_token
      end
    end
  end

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
  
  def send_notification options
    raise "Missing apple push notification certificate" unless @@apn_cert

    ctx = OpenSSL::SSL::SSLContext.new
    ctx.key = OpenSSL::PKey::RSA.new(@@apn_cert)
    ctx.cert = OpenSSL::X509::Certificate.new(@@apn_cert)

    s = TCPSocket.new(@@apn_host, APN_PORT)
    ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
    ssl.sync = true
    ssl.connect

    ssl.write(self.apn_message_for_sending(options))
    ssl.close
    s.close
  rescue SocketError => error
    raise "Error while sending notifications: #{error}"
  end
  
  def self.send_notification token, options = {}
    d = Object.new
    d.extend ApplePushNotification
    d.device_token = token
    d.send_notification options
  end

  protected

  def apn_message_for_sending options
    json = ApplePushNotification::apple_json_array options
    message = "\0\0 #{self.device_token_hexa}\0#{json.length.chr}#{json}"
    raise "The maximum size allowed for a notification payload is 256 bytes." if message.size.to_i > 256
    message
  end

  def device_token_hexa
    # Use `device_token` as the method to get the token from
    # unless it is overridde from acts_as_pushable
    apn_token_field = "device_token"
    if respond_to?(:acts_as_push_options)
      apn_token_field = acts_as_push_options[:device_token_field]
    end
    token = send(apn_token_field.to_sym)
    raise "Cannot send push notification without device token" if !token || token.empty?
    [token.delete(' ')].pack('H*')
  end

  def self.apple_json_array options
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = options[:alert].to_s if options[:alert]
    result['aps']['badge'] = options[:badge].to_i if options[:badge]
    result['aps']['sound'] = options[:sound] if options[:sound] and options[:sound].is_a? String
    result['aps']['sound'] = 'default' if options[:sound] and options[:sound].is_a? TrueClass
    result.to_json
  end
    
end

require File.dirname(__FILE__) + "/apple_push_notification/acts_as_pushable"
