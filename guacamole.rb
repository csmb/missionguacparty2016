require 'sinatra'
require 'pg'

require_relative './email'
require_relative './models'

welcome_email = ERB.new(IO.read('./views/emails/welcome.erb'))

helpers do
  include Rack::Utils
end

set :public_folder, 'public'

AVOCADO_COUNT = 7

get '/' do
  @avocados = AVOCADO_COUNT
  erb :home, layout: :application
end

post '/' do
  enthusiast = GuacamoleEnthusiasts.new(params)
  if enthusiast.save
    Pony.mail to: enthusiast.email,
            from: "Mission Guac Party <missionguacparty@gmail.com>",
            subject: "Guacamole!",
            body: welcome_email.result(binding)
    redirect '/partyon'
  else
    redirect '/'
  end
end

get '/partyon' do
  erb :success, layout: :application
end

get '/success' do
  redirect '/partyon', 301
end
