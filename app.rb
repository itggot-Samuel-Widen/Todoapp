class App < Sinatra::Base

	enable:sessions 

	get '/' do
		slim(:index)
	end

	post '/login' do
		
	end

	get '/register' do
		slim(:register)
	end

	post '/create' do
		db = SQLite3::Database.new("todoapp.sqlite")
		enter_password = params[:password]
		enter_username = params[:username]
		db.execute("INSERT INTO Users (username, password) VALUES(?,?)", [enter_username, enter_password])
		redirect '/'
	end 
end           
