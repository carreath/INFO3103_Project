(function() {
  var app = angular.module('myApp', ['ui.router']);
  
  //Main run function
  app.run(function($rootScope, $location, $state, LoginService) {
    $rootScope.$on('$stateChangeStart', 
      function(event, toState, toParams, fromState, fromParams){ 
          console.log('Changed state to: ' + toState);
    
        LoginService.isAuthenticated().then(
          function(data) {
            if($state.current['url'] == '/' || $state.current['url'] == '/login') {
              $state.transitionTo('profile');
            }
          }, function(data) {
            $state.transitionTo('login');
          });
      });
  });
  
  app.config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/profile');
    
    $stateProvider
      .state('login', {
        url : '/login',
        templateUrl : 'login.html',
        controller : 'LoginController'
      })
      .state('profile', {
        url : '/profile',
        templateUrl : 'profile.html',
        controller : 'ProfileController'
      })
      .state('posts', {
        url : '/post',
        templateUrl : 'posts.html',
        controller : 'PostController'
      })
      .state('post', {
        url : '/post',
        templateUrl : 'post.html',
        controller : 'NewPostController'
      })
      .state('newPost', {
        url : '/post/new',
        templateUrl : 'new-post.html',
        controller : 'NewPostController'
      });
  }]);

  app.controller('LoginController', function($scope, $http, $rootScope, $stateParams, $state, LoginService) {
    $rootScope.title = "Meme Machine";
    
    $scope.formSubmit = function() {
      $http.post('http://info3103.cs.unb.ca:14637/login', {'username': $scope.username, 'password': $scope.password}).success(function(data) {
        $scope.error = '';
        $scope.username = '';
        $scope.password = '';
        $state.transitionTo('profile'); 
      }).error(function(data) {
        $scope.error = "Incorrect username/password!";
      });  
    };   
  });

  app.controller('NewPostController', function($scope, $http, $rootScope, $stateParams, $state, LoginService) {
    $rootScope.title = "Meme Machine";

    $scope.uploadFile = function(files) {
        var fd = new FormData();
        //Take the first selected file
        fd.append("image", files[0]);

        $http.post('http://info3103.cs.unb.ca:14637/img', fd, {
            withCredentials: true,
            headers: {'Content-Type': undefined },
            transformRequest: angular.identity
        }).success(function(data) {
          $scope.image_id = data.image_id['LAST_INSERT_ID()'];
        });

    };

    $scope.formSubmit = function() {
      console.log( {'image_id': $scope.image_id, 'title': $scope.title, 'description': $scope.description, 'tags': [$scope.tags]});
      $http.post('http://info3103.cs.unb.ca:14637/post', {'image_id': $scope.image_id, 'title': $scope.title, 'description': $scope.description, 'tags': [$scope.tags]}).success(function(data) {        
        $scope.image_id = '';
        $scope.title = '';
        $scope.description = '';
        $state.transitionTo('post'); 
      }).error(function(data) {
        console.log(data);
        $scope.error = "Incorrect username/password!";
      });
    };   
  });
  
  app.controller('ProfileController', function($scope, $rootScope, $stateParams, $state, LoginService) {
    $rootScope.title = "AngularJS Profile Sample";
    
    $scope.logout = function() {
        //LOGOUT CODE GOES HERE
      LoginService.logout();
      $state.transitionTo('login');
    };

    $scope.post = function() {
      $state.transitionTo('post');
    };
  });
  
  app.factory('LoginService', function($http) {
    var admin = 'admin';
    var pass = 'pass';
    var isAuthenticated = false;
    
    return {
      logout : function() {
        $http.delete('http://info3103.cs.unb.ca:14637/login');
      },
      isAuthenticated : function() {
        return $http.get('http://info3103.cs.unb.ca:14637/login');
      }
    };
    
  });

  app.controller('PostController', function($scope, $rootScope, $stateParams, $state, PostService, $http) {
    $rootScope.title = "AngularJS Post Sample";
    $scope.posts = [];

    var formatPosts = function(arr, size) {
      var newArr = [];
      for (var i=0; i<arr.length; i+=size) {
        newArr.push(arr.slice(i, i+size));
      }
      return newArr;
    }

    $scope.getRecent = function() {
      PostService.getRecentPosts().success(function(data) {
        $scope.posts = data.posts;
        $scope.chunkedData = formatPosts($scope.posts, 4);
      });
    }

    $scope.getRandom = function() {
      PostService.getRandomPosts().success(function(data) {
        console.log(data);
        $scope.posts = data.posts;
        $scope.chunkedData = formatPosts($scope.posts, 4);
      });
    }

    $scope.getPopular = function() {
      PostService.getPopularPosts().success(function(data) {
        $scope.posts = data.posts;
        $scope.chunkedData = formatPosts($scope.posts, 4);
      });
    }

    $scope.createPost = function() {
      $state.transitionTo('newPost');
    }
  });


  app.factory('PostService', function($http) {    
    return {
      newPost : function(post) {
      	//Post CODE HERE
        //$post the new post
        return isAuthenticated;
      },
      updatePost : function() {
      	//DE-AUTHENTICATION CODE HERE
        isAuthenticated = false;
      },
      getPost : function(id) {
      	//Get POST of id == id
        return isAuthenticated;
      },
      getRecentPosts : function() {
        return $http.get('http://info3103.cs.unb.ca:14637/post/recent');
      },
      getRandomPosts : function() {
        return $http.get('http://info3103.cs.unb.ca:14637/post/random');
      },
      getStarredPosts : function() {
        return $http.get('http://info3103.cs.unb.ca:14637/post/recent');
      },
      getFollowingPosts : function() {
        return $http.get('http://info3103.cs.unb.ca:14637/post/recent');
      },
      getPopularPosts : function() {
        return $http.get('http://info3103.cs.unb.ca:14637/post/popular');
      }
    };
    
  });
  
})();