require 'socket'
require 'openssl'

module ApplePushNotification
  class Base
  	attr_accessor :paylod, :sound, :badge, :alert
  	attr_accessible :device_token
	
  	PORT = 2195
	
  	cattr_accessor :enviroment
  	self.enviroment = :development

  	validates_uniqueness_of :device_token

  	def send_notification
      raise "Missing cert: #{_path}" unless @@cert

  		ctx = OpenSSL::SSL::SSLContext.new
  		ctx.key = OpenSSL::PKey::RSA.new(@@cert)
  		ctx.cert = OpenSSL::X509::Certificate.new(@@cert)

  		s = TCPSocket.new(@@host, PORT)
  		ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
  		ssl.sync = true
  		ssl.connect

  		ssl.write(self.apn_message_for_sending)

  		ssl.close
  		s.close

  	rescue SocketError => error
  		raise "Error while sending notifications: #{error}"
  	end
	
  	def self.enviroment= enviroment
  	  @@enviroment = enviroment.to_sym
      @@host = self.production? ? "gateway.push.apple.com" : "gateway.sandbox.push.apple.com"
    	cert = self.production? ? "apn_production.pem" : "apn_development.pem"
    	path = File.join(File.expand_path(RAILS_ROOT), "config", "certs", cert)
      @@cert = File.exists?(path) ? File.read(path) : nil
    end
	
  	def self.development?
  	  @@enviroment != :production
    end
	
  	def self.production?
  	  @@enviroment == :production
    end

  	def self.send_notifications(notifications)	  
  		ctx = OpenSSL::SSL::SSLContext.new
  		ctx.key = OpenSSL::PKey::RSA.new(@@cert)
  		ctx.cert = OpenSSL::X509::Certificate.new(@@cert)

  		s = TCPSocket.new(@@host, PORT)
  		ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
  		ssl.sync = true
  		ssl.connect

  		for notif in notifications do
  			ssl.write(notif.apn_message_for_sending)
  		end

  		ssl.close
  		s.close
  	rescue SocketError => error
  		raise "Error while sending notifications: #{error}"
  	end

  	protected

  	def to_apple_json
  	  json = self.apple_array.to_json
  		logger.debug "Sending #{json}"
  		json
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
