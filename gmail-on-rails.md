### Outline

1. Gmail set https://www.google.com/settings/security/lesssecureapps, Turn it on.
2. Config rails
  ```ruby
  config.action_mailer.delivery_method = :smtp
  # SMTP settings for gmail
  config.action_mailer.smtp_settings = {
   :address              => "smtp.gmail.com",
   :port                 => 587,
   :user_name            => ENV['GMAIL_USERNAME'],
   :password             => ENV['GMAIL_PASSWORD'],
   :authentication       => "plain",
   :enable_starttls_auto => true
  }
  ```
  
  Append this code to `config/enviroments/production.rb|development.rb`
  
  `ENV['GMAIL_USERNAME']` and `ENV['GMAIL_PASSWORD']` can be string of username 
  and password, but it not safe. You should export it from ENV of server.
  
 3. Generate mailer
  It like controller 
  ```shell
    rails generate mailer user
  ```
  In file `app/mailers/user_mailer.rb`, create method what ever you want .
  
  ```ruby
    class UserMailer < ApplicationMailer
      default :from => 'vyquocvu@gmail.com'
      def checkout_email(user, order)
        @user = user
        @order = order
        mail(to: @user.email, subject: 'Checkout Email')
      end
    end
  ```
  Mail template in `views/mailer/checkout_email.html.erb`
  
  To send Email call ```ruby UserMailer.checkout_email(current_user || User.first, @order ).deliver_now ```
