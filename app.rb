# app.rb
require "sinatra"
require "sinatra/activerecord"

set :database, "sqlite3:myblogdb.sqlite3"

require "./models"
require "./helpers"
require "./functions"

use Rack::Logger

helpers do
	def logger
		request.logger
	end
end

configure do
	enable :sessions
end

before do
    @current_user = session[:current_user] ? session[:current_user] : "not logged in"
end
# index cards
get '/' do
  if !session[:current_user]
    redirect('/login')
  end
	@total_pages 	= Card.all.size/10.to_f.ceil
  @current_page = 0

	if params[:page]
		@current_page = params[:page].to_i
		@cards = Card.joins(:user).offset(@current_page * 10).limit(10)
  else
		@cards = Card.joins(:user).limit(10)
  end
	erb :index, :locals => {:name => @current_user}
end

get '/login' do
	if session[:current_user]
		redirect('/')
	end
  erb :login, :locals => {:name => @current_user}
end

post '/login' do
	@user = User.find_by_username(params[:username])
  if @user && @user.password == params[:password]
    session[:current_user] = @user.username
    redirect('/')
  end
end

get '/logout' do
  session.clear
  redirect('/login')
end

# create card
post '/card' do
	@card = Card.new
  @card.amount = params[:amount].to_i
  @card.booking_code = params[:booking_code].to_s
  @card.expiry_date = expiry_date
  @card.user_id = User.find_by_username(session[:current_user]).id
  @card.serial_number = generate_serial_number(Card.last.id).to_s
  @card.save
	redirect '/'
end

# show post
get '/card/:id' do
	@card = Card.find(params[:id])
	erb :card_page
end

# update post
put '/card/:id' do
	@card = Card.find(params[:id])
	@card.update(title: params[:title], body: params[:body])
	@card.save
	redirect '/card/'+params[:id]
end

# delete post
delete '/card/:id' do
	@card = Card.find(params[:id])
	@card.destroy
	redirect '/'
end

























