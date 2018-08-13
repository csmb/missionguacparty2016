require 'sinatra'
require 'pg'
require 'rack-ssl-enforcer'
require 'gibbon'

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
  @total_guest_count = GuacamoleEnthusiasts.count - 262
  @guacamole_count   = GuacamoleEnthusiasts.count(:guac => 't') - 87
  @beer_count        = GuacamoleEnthusiasts.count(:beer => 't') - 165
  @friend_count      = GuacamoleEnthusiasts.count(:other => 't') - 142
  erb :stats
end
