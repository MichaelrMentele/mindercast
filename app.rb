require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, "secret"
end

before do
end

get "/" do
  erb :home, layout: :layout
end  

post "/task" do 

end

