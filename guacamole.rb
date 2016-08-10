require 'sinatra'
require 'pg'

require_relative './email'
require_relative './models'

welcome_email = ERB.new(IO.read('./views/emails/welcome.html'))


helpers do
  include Rack::Utils
end

enable :sessions
set :public_folder, 'public'

AVOCADO_COUNT = 7

get '/' do
  @avocado_count = AVOCADO_COUNT
  erb :home
end

post '/' do
  enthusiast = GuacamoleEnthusiasts.new(params)
  if enthusiast.save
    Pony.mail to: enthusiast.email,
            from: "Mission Guac Party <missionguacparty@gmail.com>",
            subject: "Guacamole!",
            html_body: welcome_email.result(binding)
    redirect '/partyon'
  else
    redirect '/'
  end
end

get '/partyon' do
  erb :success
end
