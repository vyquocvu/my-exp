
## Create Server, callback function.
```javascript
var http = require("http");
http.createServer(function(request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello World");
  response.end();
}).listen(process.env.PORT, process.env.IP);
console.log('Server is running ...');
```
Hàm (funtion) có sẵn của module http: createServer trả về object, object này có phương thức khác gọi là listen();

Listen() có tham số đầu vào là (PORT,<IP>), lắng nghe tại cổng chỉ lắng nghe nhưng không làm gì cả, trả về thông số request và response;

Function() bên trong createServer nhận 2 thông số request và response và chạy đoạn code bên trong;

Note: Trong javascript có hàm callback, truyền vào 1 đoạn mà của một hàm khác, hàm callback chạy tại 1 thời điểm nào đó hoặc 

chạy khi hàm cha chạy xong và trả giá trị tham số đầy đủ cho nó, khác với truyền hàm thông thường là truyền vào giá trị 

của hàm đó đã thực hiện.

Đoạn mã trên sẽ tương đương với đoạn mã sau

```javascript
var http = require("http");
function onRequest(request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello World");
  response.end();
}
http.createServer(onRequest).listen(8888);
```
## Query Database, Non-Blocking
```javascript
  var result = database.query("SELECT * FROM hugetable");
  console.log("Hello World");
```
Giả sử việc query dữ liệu diễn ra rất chậm vì lý do nào đó thì ``` console.log("Hello World"); ``` sẽ phải chờ rất lâu để được thực hiện.

Các ngôn ngữ khác sẽ tạo process( cơ chế multi process ) để chạy quá trình query và nó chỉ ảnh hưởng tới một request của người gửi nó, và không ảnh hưởng tới hệ thống. Tuy nhiên trong js không có multi process mọi request đều đế 1 process tất cả sẽ dùng lại, thay vào đó sẽ phải có cơ chế riêng, Non-Blocking "dựa theo sự kiện" (event-driven), gọi ngược không đồng bộ (asynchronous callback), bằng cách sử dụng một "vòng lặp sự kiện" (event loop).
```javascript
  database.query("SELECT * FROM hugetable", function(rows) {
    var result = rows;
  });
  console.log("Hello World");
```
Cụ thể

  - Thay vì chờ đợi database.query() trực tiếp trả về kết quả, chúng ta truyền nó như là một tham số, hay nói cách khác là một hàm vô danh. Node.js xử lý các truy vấn tới database một cách không đồng bộ, nó sẽ gửi truy vấn tới database. Nhưng, thay vì chờ kết quả khi truy vấn đó kết thúc, nó sẽ ghi nhớ rằng "Đến một thời điểm nào đó trong tương lai - khi truy vấn kết thúc, kết quả được trả về - nó sẽ phải thực hiện những gì được viết trong hàm vô danh (hàm được truyền như là tham số cho database.query())" kia.
  
  - Lúc đó nó sẽ ngay lập tức thực thi console.log(), và sau đó bắt đầu một vòng lặp vô tận, và cứ thế chờ đợi, không xử lý bất kỳ gì khác cho đến khi có một sự kiện nào đó đánh thức nó, ví dụ như truy vấn tới database đã có dữ liệu trả về.
  
  - Mô hình thực thi không đồng bộ, đơn luồng, và dựa trên sự kiện này không phải thứ gì đó hoàn hảo tuyệt đối. Nó chỉ là một trong nhiều mô hình đang tồn tại, nó cũng có những nhược điểm, một trong số đó chính là: nó chỉ có thể chạy trên một nhân của CPU mà thôi.

## Request và Response

```javascript
  var http = require("http");
  function onRequest(request, response) {
    console.log("Request received.");
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("Hello World");
    response.end();
  }
  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
```
Khi hàm gọi ngược onRequest() được gọi đến bởi một sự kiện nào đó, hai tham số: request và response sẽ được truyền vào cho nó, Chúng là các đối tượng (object), bạn có thể sử dụng các hàm của chúng để xử lý các chi tiết của HTTP request nhận được và phản hồi lại các request đó (ví dụ như, trả về dữ liệu gì đó cho trình duyệt).

##Lưu trữ module máy chủ
  Để có thể làm được điều này, chúng ta gộp tất cả code trong file server.js lại vào trong một hàm start, rồi sẽ export nó ra:
```javascript
var http = require("http");
function start() {
  function onRequest(request, response) {
    console.log("Request received.");
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("Hello World");
    response.end();
  }
  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}
exports.start = start;
```
Và bên index.js chỉ cần gọi
```javascript
var server = require("./server");

server.start();
```
Đối với những ứng dụng đơn giản, bạn có thể xử lý vấn đề này trực tiếp bên trong hàm gọi ngược onRequest(). Nhưng như tôi đã nói, chúng ta sẽ áp dụng nhiều sự trừu tượng hoá để làm cho ứng dụng này trở nên thú vị hơn. Các request khác nhau trỏ tới các phần khác nhau trong ứng dụng của chúng ta được gọi là "điều hướng" (routing) - vậy nên, hãy cùng tạo một module mới có tên router.

## Điều hướng các request
Cung cấp cho "router" địa chỉ của request nhận được và có thể các tham số bổ sung như GET hoặc POST, và dựa vào những thông tin này router cần có khả năng quyết định được xem phần code nào sẽ được thực thi ("code cần được thực thi" là phần thứ ba của ứng dụng: tập hợp các thành phần xử lý request mà thực sự làm những việc được yêu cầu).
Tất cả thông tin đều có trong đối tượng request, Nhưng để biên dịch được những thông tin này, chúng ta cần thêm một số module bổ sung của Node.js, cụ thể là url và querystring.
-  Module url cung cấp các phương thức cho phép chúng ta trích xuất các thành phần khác nhau của một địa chỉ URL
-  Module querystring được dùng để phân tích cú pháp của các địa chỉ yêu cầu để lấy các tham số:
```javascript 
  var http = require("http");
  var url = require("url");

  function start() {
    function onRequest(request, response) {
      var pathname = url.parse(request.url).pathname;
      console.log("Request for " + pathname + " received.");
      response.writeHead(200, {"Content-Type": "text/plain"});
      response.write("Hello World");
      response.end();
    }
  
    http.createServer(onRequest).listen(8888);
    console.log("Server has started.");
  }

exports.start = start;
```
Bây giờ đã có thể phân biệt được các yêu cầu (request) dựa trên đường dẫn được yêu cầu.

Tạo mới một file có tên router.js với nội dung sau:
```javascript
  function route(pathname) {
    console.log("About to route a request for " + pathname);
  }
  
  exports.route = route;
```
