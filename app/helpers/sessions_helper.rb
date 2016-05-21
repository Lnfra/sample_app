module SessionsHelper

  #Logs in the given user.
  def log_in(user)
    # put a temporary cookie on the browser
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session
  def remember(user)
    #Generate hash and save to user instance and to database
    user.remember
    #save to an encrypted cookie with expiry date of 20 years later
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the current logged_in user (if any).
  def current_user
    #Only query for current user from db if it is not already defined. (Memoization)
    #Get session from browser and search for that user id
    #below code summerised ver of @current_user = @current_user || User.find_by(id: session[:user_id])

    # Check if session userid exists if so assign to user_id var
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)

    # Check if cookie user_id exists if so assign to user_id var
    elsif (user_id = cookies.signed[:user_id])
      # If no session user id check for remember token
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # logs out the current user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

end
