require 'data_mapper'
require 'bcrypt'
require 'twilio-ruby'
require 'yaml'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/users.db")

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String, :required => true
  property :password, BCryptHash, :required => true
  property :phone, String
  property :email, String

  has n, :reminders

  def send_reminders
  	self.reminders.each do |reminder|
  		if reminder.remind?
  			reminder.remind
  		end
  	end
  end
end

class Reminder
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :phones, String, :required => true
	property :payload, String, :required => true
	property :time_to_send, DateTime, :required => true

	belongs_to :user, :required => true

	def remind?
		DateTime.now > @time_to_send
	end

	def remind
		@phones.split(",").each do |phone|
			send_text(phone)
		end 

		# !!! Not properly yet defined
		# timestamp
	end

	def send_text(phone)
	  	# !!! Hardcoded right now... not good will need to change
		# Load Twilio account auth info
		# !!! This kinda sucks, should be included on User or some admin object
		account_info = YAML.load_file("data/twilio_auth.yaml")
		twilio_sid = account_info[:account_sid]
		token = account_info[:auth_token]

		client = Twilio::REST::Client.new(
			twilio_sid,
			token
		)

		client.messages.create(
		to: phone,
		from: "14255288374",
		body: @payload
		)
	end

	# !!! To be added later
	# def timestamp
	# 	@timestamps.push([@phones, DateTime.now])
	# end
end

DataMapper.finalize.auto_upgrade!
