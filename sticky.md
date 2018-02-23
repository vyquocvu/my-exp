```javascript
    function _formatString(str) {
      str = str.toLowerCase();
      str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
      str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e");
      str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
      str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o");
      str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
      str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
      str = str.replace(/đ/g, "d");
      return str;
    }
```
   
   Js
``` javascript
    null == false          // returns false
    null == 0              // returns false
    null == ''             // returns false
    // But,
    !null == !false       // returns true
    !null == !0           // returns true
    !false == !undefined  // returns true
    // And,
    null == undefined     // returns true
    false == 0            // returns true
```

autoComplete="new-password"

HTML

```
✕  '&#x2715'; ✓  '&#x2713';
✖  '&#x2716'; ✔  '&#x2714';
✗  '&#x2717';
✘  '&#x2718';
×  '&#xd7';  '&times';
```

```js
    products = (products || []).sort((l, r) => {
      const ln = l.isdeal ? 0 : 1;
      const rn = r.isdeal ? 0 : 1;
      return ln - rn;
    });
    // sort isdeal first
```

The simplest way would be to use the native `Number` function:

``` javascript
// parseInt:
    var x = parseInt("1000", 10);

// unary plus if your string is already in the form of an integer:
    var x = +"1000";

// if your string is or might be a float and you want an integer:
    var x = Math.floor("1000.01"); //floor automatically converts string to number

// or, if you're going to be using Math.floor several times:
    var floor = Math.floor;
    var x = floor("1000.01");

// If you're the type who forgets to put the radix in when you call parseInt,
// you can use parseFloat and round it however you like. Here I use floor.
    var floor = Math.floor;
    var x = floor(parseFloat("1000.01"));

// Interestingly, Math.round (like Math.floor) will do a string to number conversion,
// so if you want the number rounded (or if you have an integer in the string),
// this is a great way, maybe my favorite:
    var round = Math.round;
    var x = round("1000"); //equivalent to round("1000",0)
```

