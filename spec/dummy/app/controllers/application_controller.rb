#--
# Copyright (c) 2014 Michael Berkovich, tmlhub.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++


class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from StandardError do |e|
    pp e, e.backtrace
    raise e
  end

private 

  # For this demo we are just using a dummy user object
  def current_user
    @current_user ||= User.new('Michael', 'male')
  end
  helper_method :current_user

  # For this demo we are using the locale stored in the session
  #def current_locale
  #  @current_locale ||= begin
  #    session[:locale] = params[:locale] if params[:locale]
  #    session[:locale]
  #  end
  #end
  #helper_method :current_locale

end
