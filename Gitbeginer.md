Làm quen với git
==============

# Giới thiệu 

Git là hệ thống quản lý phiên bản phân tán, nó quản lý các version trong quá trình phát triển phần mền, nó cho phép lập trình viên dễ dàng quản lý những thay đổi và phát sinh trong quá trình phát triễn phần mềm, cũng như thuận tiện cho việc làm việc cùng nhau trong một nhóm phát triển. Khi sử dụng git tức là bạn đang viết phần mềm trong kho lưu trữ, các bản version được cập nhật sau mỗi lần commit.Git giúp lập trình viên quản lý sự thay đổi của code mà họ viết , bạn không lo bị mất hay hỏng code, bởi vì mọi sự thay đổi sau mỗi lần bạn commit sẽ được lưu lại chi tiết trong file log. Ngoài ra bạn có thể lưu trữ code online trực tiếp trên github.com, và tất nhiên là miễn phí, bạn muốn lưu riêng tư không ai nhìn thấy thì mới phải trả phí.

# Cài đặt git. 

 Ở đây mình hướng dẫn các bạn cài và sử dụng git trên windown và linux ,

*Trên môi trường linux* 

    Debian như Ubuntu
    $ apt-get update
    $ apt-get install git
    Fedora, 
    $ yum install git-core
    
*Cài đặt Git trên Windows rất đơn giản*

 Tải về tập tin cài đặt định dạng exe từ Github, và chạy: http://msysgit.github.com/
# Lệnh cơ bản 
### + Tạo 1 kho git để lưu trữ 

 Di chuyển tới thư mục chứa dư án bạn đang thực hiện, mở terminal on linux hoặc trên win click chuột phải
 chọn "Git bash here"
``` 
  $ git init           # bạn đã tạo 1 kho lưu trữ, lưu ý trong 1 thư mục chỉ có 1 kho git
```
  
  *Thêm các file vào kho*
```
  $ git status         # Kiểm tra những thay đổi trong kho git của bạn 
  $ git diff           # Để thấy sự thay đổi của từng file
  $ git add .          # Thêm mọi file có trong thư mục 
  hoặc 
  $ git add tenfile    # Thêm 1 file nào đó
```
### + Lệnh commit (xác nhận sự thay đổi của version)
```
  $ git commit -m 'tencommit'
```
### + Lưu trữ online
Trong trường hợp bạn muốn lưu trữ online phục vụ công việc làm nhóm hay chỉ để leader kiểm tra
  Lệnh khai báo kho lưu trữ online trên gitub, bạn cần tạo 1 tài khoản trên github và tạo 1 kho ( new Repository)
  [GitHub.com.](http://github.com)
```
  $ git remote add origin url         # Điểu chỉ remote tới kho của bạn, bạn chỉ cần làm 1 lần
                                      => $ git remote add origin https://github.com/vyquocvu/Day2.git    
  $ git push -u origin master         # Upload kho local của bạn lên remote vừa thiết lập 
                                      -u để ghi nhớ thông số, 
                                      origin là tên của remote, 
                                      master là tên nhánh bạn đang làm việc. 
   Với lần up tiếp theo chỉ đơn giản là  $ git push 
 Note: url của ản là https: thì mỗi lần push bạn phải nhập usename và pass một lần, 
 để tiện cho làm việc hãy dùng SSH key để xác minh.
```
 Nếu bạn muốn tải một dự án về để làm việc, của ai đó cũng được không cần phải là của bạn
```
  $ git clone url                    # url là link 1 kho trên github
                                     => $ git clone https://github.com/vyquocvu/Day2.git
```
### + Cùng làm việc

Khi bạn có một nhóm cùng tham gia một dự án, mỗi người sẽ đảm nhận việc phát triển các chức năng khác nhau, git cho phép ta quản lý một cách trật tự quá trình phát triển mà không gây rối loạn, với các thức phân chia công việc thành các nhánh khác nhau. Hãy tưởng tượng bạn copy một phiên bản cho mình làm gì đó với nó, anh hàng xóm cũng lấy một bản và làm theo cách của anh ta, ở cuối công đoạn hai bản copy sẽ sẽ được kết hợp lại và đưa vào bản gốc (và tất nhiên hai bản copy không được phép xung đột, nghĩa là bạn không được làm những phần người còn lại làm )

**Phân nhánh**
```
 $ git branch                 # Kiểm tra những branch đang tồn tại trong kho git
 $ git branch tennhanh        # Tạo branch mới để làm việc
 $ git checkout tennhanh      # Bạn đã chuyển qua làm việc trên branch này mọi thay đổi chỉ được gi nhận  
                              trên branch này, các branch khác sẽ ko liên quan
 $ git checkout -b tennhanh   # Tạo và chuyển qua branch mới ngay lập tức
```
Sau khi đã hoàn thành xong công việc, chức năng nào đó và bạn muốn tổng hợp chúng vào version hiện tại bạn commit chúng lại
và checkout về base branch (thường thì sẽ là master)
```
 $ git merge tennhanh         # tennhanh là nhánh sẽ được merge vào nhánh bạn đang làm việc
```
Đây chỉ là một số lệnh cơ bản cho những bạn mới bắt đầu làm việc với git, hi vọng sẽ giúp được các bạn làm việc dễ dàng hơn.

Xin cảm ơn đã đọc!
