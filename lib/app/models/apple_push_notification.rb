require 'socket'
require 'openssl'

class ApplePushNotification < ActiveRecord::Base

	HOST = Rails.env.production? ? "gateway.push.apple.com" : "gateway.sandbox.push.apple.com"
	PATH = '/'
	PORT = 2195
	_cert = Rails.env.production? ? "apn_production.pem" : "apn_development.pem"
	_path = File.join(File.expand_path(RAILS_ROOT), "config", "certs", _cert)
  CERT = File.read(_path) if File.exists?(_path)

	attr_accessor :paylod, :sound, :badge, :alert
	attr_accessible :device_token

	validates_uniqueness_of :device_token

	def send_notification

		ctx = OpenSSL::SSL::SSLContext.new
		ctx.key = OpenSSL::PKey::RSA.new(CERT, PASSPHRASE)
		ctx.cert = OpenSSL::X509::Certificate.new(CERT)

		s = TCPSocket.new(HOST, PORT)
		ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
		ssl.sync = true
		ssl.connect

		ssl.write(self.apn_message_for_sending)

		ssl.close
		s.close

	rescue SocketError => error
		raise "Error while sending notifications: #{error}"
	end

	def self.send_notifications(notifications)
		ctx = OpenSSL::SSL::SSLContext.new
		ctx.key = OpenSSL::PKey::RSA.new(CERT)
		ctx.cert = OpenSSL::X509::Certificate.new(CERT)

		s = TCPSocket.new(HOST, PORT)
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
		result['aps']['sound'] = '1.aiff' if sound and sound.is_a? TrueClass
		result
	end
end
