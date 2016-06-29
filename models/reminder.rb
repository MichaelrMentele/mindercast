require 'data_mapper'
require 'bcrypt'
require 'twilio-ruby'

# class Reminder
	
# 	attr_accessor :phones, :message, :time_to_send

# 	def initialize(phones, message, time_to_send)
# 		@phones = phones
# 		@time_to_send = time_to_send
# 		@payload = message
# 		@timestamps = []
# 	end

# 	def remind?
# 		DateTime.now > @time_to_send
# 	end

# 	def remind
# 		@phones.each do |phone|
# 			send_text(phone)
# 		end
# 		timestamp
# 	end

# 	def send_text(phone)
# 	  	# Hardcoded right now... not good will need to change
# 		twilio_sid = "AC0016f4c55afaf79b77ec86e2bf32ec19"
# 		token = "36077868d84cb02d517eb5d02199c08b"

# 		client = Twilio::REST::Client.new(
# 			twilio_sid,
# 			token
# 		)

# 		client.messages.create(
# 		to: phone,
# 		from: "14255288374",
# 		body: @payload
# 		)
# 	end

# 	def timestamp
# 		@timestamps.push([@phones, DateTime.now])
# 	end
# end

#########



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
		twilio_sid = "AC0016f4c55afaf79b77ec86e2bf32ec19"
		token = "36077868d84cb02d517eb5d02199c08b"

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
