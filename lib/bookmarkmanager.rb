require 'sinatra/base'
require 'haml'
require 'data_mapper'

env = ENV["RACK_ENV"] || "development"
#we're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require_relative 'link' #this needs to be done after datamapper is initialised
require_relative 'tag'
#after declaring you models, you should finalise them
DataMapper.finalize

#however, how database tables don't exist yet. Let's tell datamapper to creat them.
DataMapper.auto_upgrade!

class Bookmarkmanager < Sinatra::Base
	set :views, File.join(File.dirname(__FILE__), '..', 'views')

  get '/' do
    @links = Link.all  
    haml :index
  end

  get '/tags/:text' do  
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    haml :index
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

  post '/links' do  
  	url = params["url"]
  	title = params["title"]
    tags = params["tags"].split(" ").map do |tag|
      # this will either find this tag or create
      # it if it doesn't exist already
      Tag.first_or_create(:text => tag)
    end
  	Link.create(:url => url, :title => title, :tags => tags)
  	redirect to('/')
  end
end
