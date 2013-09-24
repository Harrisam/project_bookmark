require 'data_mapper'
require 'sinatra'

env = ENV["RACK_ENV"] || "development"
#we're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link' #this needs to be done after datamapper is initialised

#after declaring you models, you should finalise them
DataMapper.finalize

#however, how database tables don't exist yet. Let's tell datamapper to creat them.
DataMapper.auto_upgrade!