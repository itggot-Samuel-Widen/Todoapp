class App < Sinatra::Base

	enable :sessions 

	get '/' do
		slim(:index)
	end

	post '/login' do
		db = SQLite3::Database.new("todoapp.sqlite")
		user_name = params[:username]
		password_digest = db.execute("SELECT password FROM Users WHERE username IS ?", user_name) #Errors out, what
		password_digest = password_digest[0][0]
		p password_digest
		password_digest = BCrypt::Password.new(password_digest)
		password = params[:password]
		if password_digest == password
			user_id = db.execute("SELECT id FROM Users WHERE username IS ?", user_name)
			session[:logged_in] = true
			session[:user_id] = user_id
			redirect '/notes'
		else
			redirect '/login_error'
		end
	end

	get '/register' do
		slim(:register)
	end

	get('/registered') do
		slim(:registered)
	end

	post '/create' do
		db = SQLite3::Database.new("todoapp.sqlite")
		password = params[:password]
		password_digest = BCrypt::Password.create( password )
		# p password_digest					#Felsökte databasens "BLOB" issue, bcrypt funkar som förväntat trots det. 
		# if password_digest == "cool"
		# 	p "Cool password"
		# else
		# 	p "uncool password bruh"
		# end
		username = params[:username]
		db.execute("INSERT INTO Users (username, password) VALUES(?,?)", [username, password_digest])
		redirect '/registered'
	end 
end           
