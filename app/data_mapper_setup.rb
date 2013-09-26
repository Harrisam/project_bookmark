env = ENV["RACK_ENV"] || "development"
#we're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

DataMapper.finalize
DataMapper.auto_upgrade!