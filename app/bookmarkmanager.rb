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

    # flash.now[:notice] = "Reset password link sent" 
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

  post '/reset_password' do
    email = params[:reset_email]
    user = User.first(:email => email)

    if !user
      flash[:error] = "Email address not found!"
      redirect to('/')
    end

    user.reset_password_token = Array.new(64) {(65 +rand(58)).chr}.join
    user.reset_password_token_timestamp = Time.now
    user.save

    # send email + token
    flash[:notice] = 'Reset password link sent'
    redirect to('/sessions/new')
  end

  get '/reset_password/:token' do
    user = User.first(:reset_password_token => params[:token])

    if !user
      flash[:errors] = ["Token Not found"]
      redirect to('/')
    end

    time_limit = (Time.now - 60*60).to_datetime
    timestamp = user.reset_password_token_timestamp 

    if (time_limit) < timestamp
      @token = params[:token]
      haml :reset_password
    else
      flash[:errors] = ["Token to old, try again..."]
    end
  end

  post '/reset_password/:token' do 
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    user = User.first(:reset_password_token => params[:token])    
    user.password = password
    user.password_confirmation = password_confirmation
    flash[:notice] = "Password successfully changed"
    redirect to("/")
  end


  delete '/sessions' do
    session[:user_id] = nil
    flash[:notice] = "Good bye!"
    redirect to('/')
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
