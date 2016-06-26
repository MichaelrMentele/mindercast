require 'twilio-ruby'

def send_text(message)
  user = "2066184282"
  twilio_sid = "AC0016f4c55afaf79b77ec86e2bf32ec19"
  token = "36077868d84cb02d517eb5d02199c08b"

  client = Twilio::REST::Client.new(
    twilio_sid,
    token
  )

  # !!! This needs to be dynamic
  client.messages.create(
    to: user,
    from: "14255288374",
    body: message
  )

  # !!! FOR TESTING PURPOSES!!!
  client.messages.create(
    to: "2066184282",
    from: "14255288374",
    body: message
  )
end

send_text("Testing 1 2 3...")