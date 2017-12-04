# app.rb
require "sinatra"
require "sinatra/activerecord"
require "prawn"
require "prawn/measurements"
require "prawn/measurement_extensions"
require "csv"
require "pg"

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

configure :production do
	db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')

	ActiveRecord::Base.establish_connection(
			:adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
			:host     => db.host,
			:username => db.user,
			:password => db.password,
			:database => db.path[1..-1],
			:encoding => 'utf8'
	)
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
  @new_card     = nil

  if session[:new_card]
    @new_card = session[:new_card]
    session[:new_card] = nil
  end

	if params[:page]
		@current_page = params[:page].to_i
		@cards = Card.joins(:user).order('id DESC').offset(@current_page * 10).limit(10)
  elsif params[:total]
     @cards = Card.joins(:user).all.order('id DESC')
  else
		@cards = Card.joins(:user).order('id DESC').limit(10)
  end
  @expiry_date = expiry_date.strftime('%Y/%m/%d')
	erb :index, :locals => {:name => @current_user, :new_card => @new_card}
end

get '/login' do
	if session[:current_user]
		redirect('/')
	end
  erb :login, :locals => {:name => @current_user}
end

get '/print/:id' do
  @card = Card.find(params[:id])
  generate_pdf(@card)
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
  @lastCardId = Card.last ? Card.last.id : 0
  @card.amount = params[:amount].to_i
  @card.booking_code = params[:booking_code].to_s
  @card.expiry_date = params[:expiry_date]
  @card.user_id = User.find_by_username(session[:current_user]).id
  @card.serial_number = generate_serial_number(@lastCardId).to_s
  @card.save
  session[:new_card] = Card.last.id
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

get '/export/cards' do
	data = Card.all.joins(:user)
	content_type 'application/csv; encoding=utf-8;'
	attachment "cards-export.csv"
	csv_string = ""
	csv_string = CSV.generate do |csv|
		csv << ["Id","Serial number","Booking code","Amount","Expiry date","Created at","User"]
		data.each do |card|
			csv << ["#{card.id}","#{card.serial_number}","#{card.booking_code}","#{card.amount}","#{card.expiry_date.to_s}","#{card.created_at.to_s}","#{card.user.username}"]
		end
	end
end

























