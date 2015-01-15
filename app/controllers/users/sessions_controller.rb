class Users::SessionsController < Devise::SessionsController
  def create
    session['user_auth'] = params[:user]
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in(resource_name, resource)
    message = I18n.t 'devise.sessions.signed_in'
    if request.xhr?
      return render :json => {:success => true, :login => true, :data =>  {:message => message}, :email => resource.email}
    else
      respond_to do |format|
        format.html{redirect_to root_path}
      end
    end
  end

  def failure
    begin
      user = User.find(email: session['user_auth'][:email])
    rescue Mongoid::Errors::DocumentNotFound
      user = nil
    end
    message = I18n.t 'devise.failure.invalid'
    if user =! nil || user.active_for_authentication?
      flash[:error]= message unless request.xhr?
    else
      flash[:error]= user.inactive_message unless request.xhr?
      message = user.inactive_message
    end
    respond_to do |format|
      format.json {render :json => {:authentication => 'failure', :success => false, :data => {:message => message, :cause => 'invalid'} } }
      format.html {redirect_to new_user_session_path}
    end
  end


  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    message = I18n.t 'devise.sessions.signed_out'
    redirect_to(root_path)
    flash[:notice] = message
    # if request.xhr?
     # redirect_to root_path
     # return render :json => {:success => true, :data => {:message => message}, :content => render_to_string(:layout => false, :partial => 'sessions/manager')}
    # else
    respond_to do |format|
      format.html{}
      format.js { render :nothing => true }
          #end
    end
  end
end
