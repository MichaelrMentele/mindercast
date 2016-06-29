require 'date'
require 'twilio-ruby'
require_relative "./models/reminder"

User.each do |user|
	user.reminders.all.each do |reminder| 
		if reminder.remind?
			reminder.remind
		end
	end
end
