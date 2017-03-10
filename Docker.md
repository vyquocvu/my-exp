Docker-basic
===========================================

![alt tag](https://www.docker.com/sites/all/themes/docker/assets/images/logo.png)

https://www.docker.com

# Giới thiệu

 Docker là một phần mềm quản lý cơ sở hạ tầng. Nếu lấu ví dụ hệ điều hành như một công ty thì docker hoạt động giống như bạn chia công ty thành công ty con và hoạt động với tài nguyên cung câp bởi công ty mẹ. Về phần làm việc với người dùng docker khá giống với một máy ảo, tuy nhiên nguyên lý hoạt động căn bản là khác nhau. Docker sử dụng chung kernel cùng với máy tính của bạn, thay vì phải chạy thêm guest OS như máy ảo, vì thế các thao tác tắt bật, chạy rất nhanh.
 
 ![alt tag](http://regmedia.co.uk/2015/01/07/docker_vs_vmware.jpg)
 http://www.theregister.co.uk/2015/01/07/asigra_dockerises_cloud_backup/
 
 Điểm nổi bật thứ hai là docker có nguyên một kho lưu trữ, chia sẻ khổng lồ, bạn có thể tạo docker của mình và chia sẻ cho mọi người và khi bạn cần chỉ cần search là có một đống.

 Thế dùng docker để làm gì? Như bạn là một lập trình viên thường xuyên thay đổi các version của framwork đặc biệt là mấy bạn viết PHP chẳng hạn sự khác nhau giữa các dự án là một nỗi khổ kinh điển. Thay vì mỗi lần làm dự án lại gỡ rồi cài, thì bạn có vài docker cài sẵn các version, thích thì bật lên chạy lâu ko dùng thì xóa đi. Một ứng dụng hưũ ích nữa của docker là tận dụng tài nguyên của server, run nhiều docker tối đa hoạt động server giúp tiết kiệm đỡ mất nhiều tiền thuê nhiều server. Như mình làm là 1 docker chạy Database rối ứng dụng bên ngoài ser truy xuất đến.
 
 Docker siêu nhanh, miễn phí, vừa tiết kiệm bộ nhớ và CPU, lại còn một kho đồ sộ trên mạng, tội gì mà lại không dùng docker!

##Các thành phần của docker!

  **Dockerhub:** nơi chia sẻ lưu trữ docker
  
  **Dockerengine:** là nơi bạn sử dụng cài đặt trên máy.
####  Khái niệm
  Trước khi tìm hiểu các sử dụng chúng ta cần biết về các khái niệm cơ bản về docker. Trong docker có nhiều phần tuy nhiên để   dễ hiểu và sử dụng mình chỉ xin giới thiệu vài cái, bạn nào muốn chuyên sâu hơn có thể tìm hiểu trên trang chủ.
  
  **Image**: gọi đơn giản đúng nghĩa là ảnh, ví dụ bạn có một cái máy tính đang chạy chụp ảnh nó lại thành Image mang đi đâu cũng được khi cần mang ra chạy( nghe giống phim viễn tưởng tuy nhiên đây là cách hiểu đơn giản nhất về Image)
  
  **Container**: cứ gọi là Container, vâng là một máy docker đang hoạt động,
  Mối quan hệ của Image và Container là mối quan hệ qua lại, gắn bó.
  
  Container =====commit ====>Image
  
  Image ====Run =======> Container
  
  Theo như sơ đồ thì container là image đang trong trạng thái run còn image là một container được commit.
  Dockerfile: là một file dùng để build một image, nó chứa các dòng lệnh để có thể build một image nhanh chóng, 
  một Dockerfile và kb có thể build ra một image chạy ubuntu, cenos có cài sẵn các thứ bạn cần để làm việc nhanh chóng. 
  
# Cài đặt  docker 
  Lưu ý docker chỉ dùng cho linux, nếu bạn muốn chạy trên win hay mac thì bạn phải cài http://boot2docker.io/
  
  Trên môi trường linux thực hiện lại các lệnh sau
``` 
  $ sudo apt-get update
  $ sudo apt-get install wget
  $ wget -qO- https://get.docker.com/ | sh
  Or 
  $ wget -qO- https://get.docker.com/gpg | sudo apt-key add -
```
Vậy là bạn đã cài xong Docker engine, Đôi khi docker không chậy được và báo lỗi này 

```
Warning: failed to get default registry endpoint from daemon (Cannot connect to the Docker daemon. Is the docker daemon running on this host?). Using system default: https://index.docker.io/v1/
```
cách giải quyết là dùng `sudo docker` thay vì dùng `docker`.
#Làm việc với docker
```
  $ docker images             # xem tất cả image trong máy
  $ docker search ubuntu      # tìm kiếm trên Dockerhub image ubuntu 
  $ docker pull ubuntu:14.04  # tải docker Ubuntu:14.4
  $ docker images             # khi bạn xem lại bạn sẽ thấy xuât hiện image mới
  Trong phần thông tin image cần chú ý là "image id", định danh cho một Image có trong kho
```
Khi đã có Image để làm việc bạn cần run nó lên 
```
$ docker run -i -t <image id>  /bin/bash  # run một image đơn giản chưa tùy chỉnh, 
                                          # Terminal của bạn sẻ chuyển sang 
                                          # Container mới vừa được tạo .  
```
Lưu ý docker ko có giao diện chỉ có command line các bạn cần biết các lệnh linux cơ bản
```
$ docker ps -a                            # Xem các image đang hoạt động 
```
##Tùy chỉnh thông số.
 Docker cho phép tùy chỉnh thông số làm việc như ram, cpu và Ip sao cho thuận lợi nhất cho lập trình viên
 ```
 $ docker run [OPTIONS] IMAGE[:TAG|@DIGEST] [COMMAND] [ARG...]
 ```
 Tham khảo trên https://www.docker.com
 
 Bình thường thì mỗi lần docker chạy theo IP mặc định của nó 127.x.x.x, tuy nhiên làm vậy hơi khó cho việc kêt nối với máy chính bên ngoài. Bạn có thể config lại static IP hoặc cài cho nó dùng IP của localhost
```
$ docker run  --net = host-i -t <image id>  /bin/bash # set local IP 
```
**Bạn muốn mở nhiều terminal trong docker:**  
```
$ sudo docker exec -it <containerIdOrName> bash
```
##Commit, save and export

Khi làm việc với Container mà chưa xong việc và bạn muốn lưu lại hoạt động, thì phải commit container ấy lại.
Lưu ý nếu ko commit mà thoát ngay ra thì container của bạn trở về Image trước khi run vậy là công cốc.
Cách tốt nhất là mở một Terminal khác và commit lại trước khi bạn gõ exit khỏi docker

```
$ docker commit <container_id> <image name>
vd:
$ docker commit 3a09b2588478 ubuntu:14.04 
Muốn dùng tiếp thì run image !
```
Còn khi bạn muốn chia sẻ container hay Image thi dùng export và save để lưu lại
```
$ docker export <container id> > yourfile.tar
$ docker save <image id> > yourimage.tar
```
Khi có một bản save hay export để chúng có thể chạy được bạn phải load chúng thì docker mới có thể nhận biết được.
```
$ docker load < yourfile.tar.gz
or
$ docker load --input yourfile.tar
```
Tài liệu và hướng dẫn chi tiết tại https://docs.docker.com

Bài viết chia sẻ có những chỗ chưa chuẩn xác mong mọi người góp ý!
