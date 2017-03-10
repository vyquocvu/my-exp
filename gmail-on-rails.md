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
  ```erb
    <!DOCTYPE html>
      <html>
        <head>
          <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
        </head>
        <body>
          <h1>Xin chào <% @order.email %></h1>
          <h2>
            Bạn đã thanh toán thành công đơn hàng từ Venshop.
          </h2>
          <% @order.cart_items.each do |item| %>
            <p>
              <% product = Product.find_by(id: item.id)%>
              <%= product[:name] %>
              <strong style="color:red;"> Giá </strong> 
              <%= number_to_currency((item.price.to_i * item.quantity.to_i)/100.0) %>
            </p>
          <% end %>
          <strong> Tổng giá <%=number_to_currency(@order.total/100.0) %></strong>
          <p>
            Thời gian giao hàng từ 3 tới 5 ngày, kể từ ngày hoàn tất thanh toán. 
            <br>
            Mọi thắc mắc và phản hồi xin liên hệ 1900......
          </p>
        </body>
      </html>
  ```
  
  To send Email call ```UserMailer.checkout_email(current_user).deliver_now ```
  
