require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

require "./models/reminder"

configure do
  enable :sessions
  set :session_secret, "secret"
end

###########
# Methods #
###########

def find_user
  username = session[:username]
  User.first(:username => username)
end

def logged_in?
  !!session[:username]
end

def please_login
  session[:error] = "You are not logged in. Please login or register."
  redirect "/login"
end

########
# GETs #
########

# Render Splash
get "/splash" do
  if logged_in?
    erb :splash, layout: :layout_auth_other
  else
    erb :splash, layout: :layout_no_auth
  end
end  

# Render Login page
get "/login" do 
  erb :login, layout: :layout_no_auth
end

# Render Registration page
get "/register" do 
  erb :register, layout: :layout_no_auth
end 

#####################
### Requires User ###
#####################

# Render home page
get "/" do 
  if logged_in?
    user = find_user
    @reminders = user.reminders.all
    erb :home, layout: :layout
  else
    please_login
  end
end

# Render Setting page
get "/settings" do 
  if logged_in?
    erb :settings, layout: :layout_auth_other
  else
    please_login
  end
end

#########
# POSTs #
#########

# Register a new user
post "/register" do
  user = User.new 
  user.username = params[:username]
  user.password = params[:password]
  user.save

  session[:username] = user.username 
  session[:success] = "You are logged in #{user.username}!" 
  redirect "/" 
end

# Login a registered user
post "/login" do
  @users = User.all
  username_attempt = params[:username]
  password_attempt = params[:password]

  @users.each do |user|
    if user.username == username_attempt and user.password == password_attempt
      session[:username] = user.username
      session[:success] = "Welcome #{user.username}!"
      redirect "/"
    end
  end
  session[:error] = "Sorry, wrong info bro."
  redirect "/login"
end

# Add a reminder to the user's collection
post "/capsules" do 
  user = find_user

  # add reminder
  # !!! NEED PARSING AND EXCEPTION HANDLING
  name = params[:name]
  schedule = params[:schedule]
  phones = params[:phones].split(',')
  payload = params[:capsule_message]

  user.reminders.create(:payload => payload, :name => name, :time_to_send => schedule, :phones => phones)
  user.save

  session[:success] = "Reminder added successfully"
  redirect "/"
end


# Update user settings
post "/update_user_info/:property" do
  user = find_user

  # Update User info
  property = params[:property].to_sym

  if property == :lover
    user.lovers[0].update(:phone => params[:lover_phone],
                      :name  => params[:lover_name])
  else
    user.update(property => params[property])
  end

  redirect "/settings"
end

###########
# Helpers #
###########
helpers do 
  
end

###########
# TESTING #
###########

get "/debug" do
  username = session[:username]
  @user = User.first(:username => username)
  @reminders = @user.reminders.all
  erb :debug, layout: :layout
end

