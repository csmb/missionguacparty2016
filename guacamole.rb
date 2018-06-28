require 'sinatra'
require 'pg'
require 'rack-ssl-enforcer'

require_relative './email'
require_relative './models'

welcome_email = ERB.new(IO.read('./views/emails/welcome.html'))

configure :production do
  use Rack::SslEnforcer
end

helpers do
  include Rack::Utils
end

enable :sessions
set :public_folder, 'public'

AVOCADO_COUNT = 8

get '/' do
#   return redirect "https://docs.google.com/forms/d/1xz60adQHDE-uuIq4Qo_O6rswr0cryBmQ07FCMPcRsV0"
  @avocado_count = AVOCADO_COUNT
  erb :home
end

post '/' do
  enthusiast = GuacamoleEnthusiasts.new(params)
  if enthusiast.save
    Pony.mail to: enthusiast.email,
              from: "Guac Party <missionguacparty@gmail.com>",
              subject: "Congratulations, you hit guac bottom.",
              html_body: welcome_email.result(binding)
    redirect '/partyon'
  else
    redirect '/'
  end
end

get '/partyon' do
  erb :success
end

get '/definitelynotthestatspage' do
  @total_guest_count = GuacamoleEnthusiasts.count - 262
  @guacamole_count   = GuacamoleEnthusiasts.count(:guac => 't') - 87
  @beer_count        = GuacamoleEnthusiasts.count(:beer => 't') - 165
  @friend_count      = GuacamoleEnthusiasts.count(:other => 't') - 142
  erb :stats
end
