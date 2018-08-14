require 'sinatra'
require 'pg'
require 'rack-ssl-enforcer'
require 'gibbon'

require_relative './models'

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
  @avocado_count = AVOCADO_COUNT
  erb :home
end

post '/' do
  enthusiast = GuacamoleEnthusiasts.new(params)
  if enthusiast.save
    gibbon = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
    merge_fields = { GUAC: (params[:guac].nil? ? "" : "true"),
                     BEER: (params[:beer].nil? ? "" : "true"),
                     FRIENDS: (params[:other].nil? ? "" : "true")
                   }.reject { |_,v| v.empty? }

    gibbon.lists(ENV['WELCOME_LIST_ID']).members.create(body:
      { email_address: params[:email],
        status: "subscribed",
        merge_fields: merge_fields
      }
    )
    redirect '/partyon'
  else
    redirect '/'
  end
rescue Gibbon::MailChimpError => e
  print "Oh no, an error occured: #{e}."
  redirect '/partyon'
end

get '/partyon' do
  erb :success
end

get '/definitelynotthestatspage' do
  registration_start = DateTime.new(2018, 8, 1)
  now = DateTime.now

  @total_guest_count = GuacamoleEnthusiasts.all(created_at: registration_start..now).count
  @guacamole_count   = GuacamoleEnthusiasts.all(created_at: registration_start..now, guac: 't').count
  @beer_count        = GuacamoleEnthusiasts.all(created_at: registration_start..now, beer: 't').count
  @friend_count      = GuacamoleEnthusiasts.all(created_at: registration_start..now, other: 't').count
  erb :stats
end
