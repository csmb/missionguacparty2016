require 'sinatra'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'dm-timestamps'
require 'dm-core'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")
class GuacamoleEnthusiasts
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :beer, Boolean
  property :guac, Boolean
  property :other, Boolean
  property :created_at, DateTime
  property :updated_at, DateTime
end
DataMapper.finalize.auto_upgrade!
