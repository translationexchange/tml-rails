#--
# Copyright (c) 2010-2013 Michael Berkovich, tmlhub.com
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

class EmailsController < ApplicationController

  def index
    emails
  end

  def deliver
    if params[:email] == 'welcome_email'
      UserMailer.welcome_email(User.first).deliver_later
    end

    trfn('Email has been sent')
    redirect_to(:action => :index)
  end

  # def postoffice
  #   begin
  #     @template_options = tml_application.postoffice.templates.collect{|t| t['keyword']}
  #   rescue Exception => ex
  #     @template_options = ['None found']
  #   end
  #
  #   begin
  #     @channel_options = tml_application.postoffice.channels.collect{|t| t['keyword']}
  #   rescue Exception => ex
  #     @channel_options = ['None found']
  #   end
  #
  #   if request.post?
  #     tokens = params[:tokens].blank? ? {} : JSON.parse(params[:tokens])
  #     params[:to].split(',').each do |to|
  #       tml_application.postoffice.deliver(params[:template], to, tokens, {
  #           locale: params[:message_locale],
  #           via: params[:channel]
  #       })
  #     end
  #     trfn('The email has been delivered')
  #   end
  # end

  def emails
    @emails ||= [{title: 'Welcome', key: 'welcome_email'}]
  end

end
