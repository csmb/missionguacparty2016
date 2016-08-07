require File.expand_path '../test_helper.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

DatabaseCleaner.clean_with(:truncation)

describe 'Guac Party! homepage' do
  before(:each) do
    get '/'
  end

  it 'should welcome you with dreams of guacamole' do
    last_response.body.must_include 'Indian Summer Guac-Off'
  end

  it 'should always take place in San Francisco' do
    last_response.body.must_include 'San Francisco'
  end

  it 'should create a new user on sign up' do
    post '/', params={ name: 'Champ', email: 'GuacamoleChamp@avocado.net', guac: true, beer: false, other: false }
    Partier.count.must_be :==, +1
  end
end

describe 'Post registration success page' do
  before(:each) do
    get '/partyon'
  end

  it 'should have the location as a reminder' do
    last_response.body.must_include '3340 Folsom St. San Francisco, 94110'
  end

  it 'should be an inclusive invite' do
    last_response.body.must_include 'friends, lovers, pets'
  end
end

describe 'redirects' do
  it 'should send folks to \'partyon\'who bookmarked \'success\'' do
    get '/success'
    last_response.header['location'].must_include '/partyon'
  end
end
