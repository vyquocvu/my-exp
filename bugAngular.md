Angular.js
```
  Error: $rootScope:infdig
  Infinite $digest Loop 
```
=> https://docs.angularjs.org/error/$rootScope/infdig
```
  $scope.vari
  not blind to html ng-blind="" or {{}}
```
=> $scope.object.vari and {{object.vari}}

Default image
<img ng-src="{{item.amzImg}}" src="/images/noimage.png" image-onload style="width: 100px;" class="none img-responsive">
