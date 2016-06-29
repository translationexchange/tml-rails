class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    message = mail(to: @user.email, subject: 'Welcome to My Awesome Site'.trl)

    server_info = {
        :user_name => '1779389065d5952e8',
        :password => 'e0daf7e0d8ef71',
        :address => 'mailtrap.io',
        :domain => 'mailtrap.io',
        :port => '2525',
        :authentication => :cram_md5
    }

    message.delivery_method.settings.merge!(server_info)
    # message.deliver
  end

end