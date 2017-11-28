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

	get '/login_error' do
		slim(:login_error)
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
		if password.length < 1
			redirect('/password_error')
		end
		# if password.length < 1
		# 	flash[:error_message] = "You can't register without a password"
		# 	redirect('/')
		# end
		password_digest = BCrypt::Password.create( password )
		# p password_digest					#Felsökte databasens "BLOB" issue, bcrypt funkar som förväntat trots det.
		# if password_digest == "cool"
		# 	p "Cool password"
		# else
		# 	p "uncool password bruh"
		# end
		username = params[:username]
		if username.length < 1
			redirect('/username_error')
		end
		db.execute("INSERT INTO Users (username, password) VALUES(?,?)", [username, password_digest])
		redirect '/registered'
	end

	get '/password_error' do
		slim(:password_error)
	end

	get '/username_error' do
		slim(:username_error)
	end

	get '/notes' do
		if session[:logged_in] == true
			slim(:notes)
			#user_id = session[:user_id]
		else
			slim(:not_logged_in)
		end
	end

	get '/logout' do
		session[:logged_in] = false
		session[:user_id] = nil
		redirect '/'
	end

	post '/create_note' do
		user_id = session[:user_id]
		note_content = params[:note_content]
		db = SQLite3::Database.new("todoapp.sqlite")
		db.execute("INSERT INTO Notes (content, user_id) VALUES(?,?)", [note_content, user_id])
		redirect '/notes'
	end
end
