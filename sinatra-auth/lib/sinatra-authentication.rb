require 'sinatra/base'
require File.expand_path("../models/abstract_user", __FILE__)

module Sinatra
  module SinatraAuthentication
    def self.registered(app)
      #INVESTIGATE
      #the possibility of sinatra having an array of view_paths to load from
      #PROBLEM
      #sinatra 9.1.1 doesn't have multiple view capability anywhere
      #so to get around I have to do it totally manually by
      #loading the view from this path into a string and rendering it
      app.set :sinatra_authentication_view_path, File.expand_path('../views/', __FILE__)
      unless defined?(settings.template_engine)
        app.set :template_engine, :haml
      end


      #convenience for ajax but maybe entirely stupid and unnecesary
      app.get '/logged_in' do
        if session[:user]
          "true"
        else
          "false"
        end
      end

      app.get '/login/?' do
        if session[:user]
          redirect '/'
        else
          send settings.template_engine, get_view_as_string("login.#{settings.template_engine}"), :layout => false #use_layout?
        end
      end

      app.post '/login/?' do
        if user = User.authenticate(params[:username], params[:password])
          session[:user] = user.id

          if Rack.const_defined?('Flash')
            flash[:notice] = "Login successful."
          end

          if session[:return_to]
            redirect_url = session[:return_to]
            session[:return_to] = false
            redirect redirect_url
          else
            redirect '/'
          end
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "The username or password you entered is incorrect."
          end
          redirect '/login'
        end
      end

      app.get '/logout/?' do
        session[:user] = nil
        if Rack.const_defined?('Flash')
          flash[:notice] = "Logout successful."
        end
        return_to = ( session[:return_to] ? session[:return_to] : '/' )
        redirect return_to
      end

      app.post '/add-user/?' do
        @user = User.set(params[:user])
        if @user.valid && @user.id && update_access(params[:selections], @user)
          if Rack.const_defined?('Flash')
            flash[:notice] = "Account created."
          end
          redirect '/user-management'
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "There were some problems creating your account: #{@user.errors}."
          end
          redirect '/user-management'
        end
      end

      app.get '/users/:id/edit/?' do
        login_required
        redirect "/" unless current_user.admin? 
        @user = User.get(:id => params[:id])
        @auto_selections = @user.auto_selections == 1 ? true : false
        @access_selections = []        
        DB[:selections_sequel_users].select(:selection_name).where(:id => params[:id].to_i).each{|sel| @access_selections.insert(-1, sel[:selection_name])}
        @selections = Selection.select(:selection_name).all
        send settings.template_engine, get_view_as_string("edit_user.#{settings.template_engine}"), :layout => use_layout?
      end

      app.post '/users/:id/edit/?' do
        login_required
        redirect "/" unless current_user.admin? 
        user = User.get(:id => params[:id])
        user_attributes = params[:user]
        unless params[:user][:auto_selections].nil?
          params[:user][:auto_selections] = 1
        else
          params[:user][:auto_selections] = 0
        end
        if params[:user][:password] == ""
            user_attributes.delete("password")
            user_attributes.delete("password_confirmation")
        end

        if user.update(user_attributes) && update_access(params[:selections], user)
          
          if Rack.const_defined?('Flash')
            flash[:notice] = 'Account updated.'
          end
          redirect '/user-management'
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "Error while updating: #{user.errors}."
          end
          redirect '/user-management'
        end
      end

      app.get '/users/:id/delete/?' do
        login_required
        redirect "/" unless current_user.admin? 

        if User.delete(params[:id])
          if Rack.const_defined?('Flash')
            flash[:notice] = "User deleted."
          end
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "Deletion failed."
          end
        end
        redirect '/user-management'
      end
    end
  end

  module Helpers
    def hash_to_query_string(hash)
      hash.collect {|k,v| "#{k}=#{v}"}.join('&')
    end

    def apply_auto_selections(selection)
      sequel_users = SequelUser.where(:auto_selections => 1).all
      sequel_users.each do |user|
        user.add_selection(selection) 
      end
    end

    def login_required
      #not as efficient as checking the session. but this inits the fb_user if they are logged in
      user = current_user
      if user && user.class != GuestUser
        return true
      else
        #TODO: correct redirect after auto logout?
        #session[:return_to] = request.fullpath
        session[:return_to] = '/' 
        redirect '/login'
        return false
      end
    end

    def current_user
      if session[:user]
        User.get(:id => session[:user])
      else
        GuestUser.new
      end
    end

    def logged_in?
      !!session[:user]
    end

    def use_layout?
      !request.xhr?
    end

    #BECAUSE sinatra 9.1.1 can't load views from different paths properly
    def get_view_as_string(filename)
      view = File.join(settings.sinatra_authentication_view_path, filename)
      data = ""
      f = File.open(view, "r")
      f.each_line do |line|
        data += line
      end
      return data
    end

    def render_login_logout(html_attributes = {:class => ""})
    css_classes = html_attributes.delete(:class)
    parameters = ''
    html_attributes.each_pair do |attribute, value|
      parameters += "#{attribute}=\"#{value}\" "
    end

      result = "<div id='sinatra-authentication-login-logout' >"
      if logged_in?
        logout_parameters = html_attributes
        # a tad janky?
        logout_parameters.delete(:rel)
        result += "<a href='/users/#{current_user.id}/edit' class='#{css_classes} sinatra-authentication-edit' #{parameters}>Edit account</a> "
        if Sinatra.const_defined?('FacebookObject')
          if fb[:user]
            result += "<a href='javascript:FB.Connect.logoutAndRedirect(\"/logout\");' class='#{css_classes} sinatra-authentication-logout' #{logout_parameters}>Logout</a>"
          else
            result += "<a href='/logout' class='#{css_classes} sinatra-authentication-logout' #{logout_parameters}>Logout</a>"
          end
        else
          result += "<a href='/logout' class='#{css_classes} sinatra-authentication-logout' #{logout_parameters}>Logout</a>"
        end
      else
        result += "<a href='/signup' class='#{css_classes} sinatra-authentication-signup' #{parameters}>Signup</a> "
        result += "<a href='/login' class='#{css_classes} sinatra-authentication-login' #{parameters}>Login</a>"
      end

      result += "</div>"
    end

    def can_access?(table, rows)
      user = current_user
      if user.admin?
        true
      else
        if rows.class != String
          qry = []
          rows.to_a.map{|ele| qry.insert(-1,ele.to_s)}
          qry_size = rows.size
        else
          qry = rows
          qry_size = 1
        end
        case table
        when :libraries
          requested_rows = DB[:libraries].where(:library_name => DB[:selections_sequel_users].select(:library_name).join(:selections, :selection_name => :selection_name).where(:id => user.id, :library_name => qry)).count
        when :selections
          requested_rows = DB[:selections_sequel_users].where(:id => user.id, :selection_name => qry).count
        when :sequencing_datasets
          #requested_rows = DB[:sequel_users_sequencing_datasets].where(:id => user.id, :dataset_name => qry).count
          requested_rows = DB[:sequencing_datasets].where(:dataset_name => DB[:selections_sequel_users].select(:dataset_name).join(:sequencing_datasets, :selection_name => :selection_name ).where(:id => user.id, :dataset_name => qry)).count
        end
        if requested_rows == qry_size
          true
        else
          false
        end
      end
    end

    def get_accessible_elements(table)
      user = current_user
      elements = []
      case table
      when :libraries
        query = Library.select(:library_name).where(:library_name => DB[:selections_sequel_users].select(:library_name).join(:selections, :selection_name => :selection_name).where(:id => user.id)).all.each{|lib| elements.push(lib[:library_name])}
      when :selections
        query = DB[:selections_sequel_users].select(:selection_name).where(:id => user.id).all.each{|sel| elements.push(sel[:selection_name])}
      when :sequencing_datasets
        query = SequencingDataset.select(:dataset_name).where(:selection_name => DB[:selections_sequel_users].select(:selection_name).where(:id => user.id)).all.each{|ds| elements.push(ds[:dataset_name])}
      end
      elements
    end

    #TODO false case
    def update_access(selections, user)
      sequel_user = SequelUser.where(:id => user.id).first
      sel = Selection.select(:selection_name).where(:selection_name => selections).all
      sequel_user.remove_all_selections
      sel.each do |row|
        sequel_user.add_selection(row)
      end    
  
      true
    end

    
  end

  register SinatraAuthentication
end

class GuestUser
  def guest?
    true
  end

  def permission_level
    0
  end

  # current_user.admin? returns false. current_user.has_a_baby? returns false.
  # (which is a bit of an assumption I suppose)
  def method_missing(m, *args)
    return false
  end
end
