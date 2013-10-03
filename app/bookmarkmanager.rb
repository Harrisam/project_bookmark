require 'sinatra/base'
require 'haml'
require 'data_mapper'
require 'rack-flash'
require './lib/link' #this needs to be done after datamapper is initialised
require './lib/tag'
require './lib/user'

require_relative 'data_mapper_setup'
require_relative 'helpers/application'

class Bookmarkmanager < Sinatra::Base
	enable :sessions
  set :session_secret, 'super secret'

  use Rack::Flash
  use Rack::MethodOverride

  helpers ApplicationHelpers
  # set :views, File.join(File.dirname(__FILE__), '..', 'views')

  get '/' do
    @links = Link.all  
    haml :index
  end

  get '/tags/:text' do  
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    haml :index
  end

  get '/users/new' do  
    # note the view is in views/users/new.erb
    # we need the quotes because otherwise
    # ruby would divide the symbol :users by the
    # variable new (which makes no sense)
    @user = User.new
    haml :"/users/new"
  end

  get '/sessions/new' do  
    haml :"sessions/new"
  end

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

  post '/users' do
    #we just initialize the object
    #without saving it. It may be invalid
    @user = User.new(:email => params[:email],
                :password => params[:password],
                :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id 
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      haml :"users/new"
    end
  end

  post '/sessions' do 
    email, password = params[:email], params[:password]
    user = User.authentificate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ["The Email or password are incorrect"]
      redirect to('/sessions/new')
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash[:notice] = ["Good bye!"]
    redirect to('/')
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
