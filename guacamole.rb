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

AVOCADO_COUNT = 9

get '/' do
  @avocado_count = AVOCADO_COUNT
  erb :home
end

post '/' do
  enthusiast = GuacamoleEnthusiasts.new(params)
  # Check error on save, required field.
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
  registration_open_2019 = DateTime.new(2019, 8, 1)
  registration_open_2018 = DateTime.new(2018, 8, 1)
  registration_closed_2018 = now - 365

  @guest_count_2019 = GuacamoleEnthusiasts.all(created_at: registration_open_2019..now).count
  @guest_trending = (@guest_count_2019 - GuacamoleEnthusiasts.all(created_at: registration_open_2018..registration_closed_2018).count)

  @guacamole_count_2019 = GuacamoleEnthusiasts.all(created_at: registration_open_2019..now, guac: 't').count
  @guacamole_trending = (@guacamole_count_2019 - GuacamoleEnthusiasts.all(created_at: registration_open_2018..registration_closed_2018, guac: 't').count)

  @beer_count_2019 = GuacamoleEnthusiasts.all(created_at: registration_open_2019..now, beer: 't').count
  @beer_trending = (@beer_count_2019 - GuacamoleEnthusiasts.all(created_at: registration_open_2018..registration_closed_2018, beer: 't').count)

  @friends_count_2019 = GuacamoleEnthusiasts.all(created_at: registration_open_2019..now, other: 't').count
  @friends_trending = (@friends_count_2019 - GuacamoleEnthusiasts.all(created_at: registration_open_2018..registration_closed_2018, other: 't').count)

  erb :stats
end
