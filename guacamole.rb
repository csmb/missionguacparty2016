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
    erb :success
  else
    erb :home
  end
rescue Gibbon::MailChimpError => e
  print "Oh no, an error occured: #{e}."
  erb :success
end

get '/partyon' do
  erb :success
end

get '/definitelynotthestatspage' do
  now = DateTime.now
  registration_open_2018 = DateTime.new(2018, 8, 1)
  registration_open_2017 = DateTime.new(2017, 8, 1)
  registration_closed_2017 = now - 365

  @guest_count_2018 = GuacamoleEnthusiasts.all(created_at: registration_open_2018..now).count.to_i
  @guest_trending = @guest_count_2018 - GuacamoleEnthusiasts.all(created_at: registration_open_2017..registration_closed_2017).count.to_i

  @guacamole_count_2018 = GuacamoleEnthusiasts.all(created_at: registration_open_2018..now, guac: 't').count.to_i
  @guacamole_trending = @guest_count_2018 - GuacamoleEnthusiasts.all(created_at: registration_open_2017..registration_closed_2017, guac: 't').count.to_i

  @beer_count_2018 = GuacamoleEnthusiasts.all(created_at: registration_open_2018..now, beer: 't').count.to_i
  @beer_trending = @guest_count_2018 - GuacamoleEnthusiasts.all(created_at: registration_open_2017..registration_closed_2017, beer: 't').count.to_i

  @friends_count_2018 = GuacamoleEnthusiasts.all(created_at: registration_open_2018..now, other: 't').count.to_i
  @friends_trending = @guest_count_2018 - GuacamoleEnthusiasts.all(created_at: registration_open_2017..registration_closed_2017, other: 't').count.to_i

  erb :stats
end
