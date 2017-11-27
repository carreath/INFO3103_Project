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
      .state('post', {
        url : '/post',
        templateUrl : 'post.html',
        controller : 'PostController'
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

  app.controller('PostController', function($scope, $rootScope, $stateParams, $state, PostService) {
    $rootScope.title = "AngularJS Post Sample";
    
    $scope.getRecent = function() {
      PostService.getRecentPosts().success(function(data) {
        $scope.posts = data.posts;
      });
    }
    $scope.getImage = function(image_id) {
      $http.get('http://info3103.cs.unb.ca:14637/img?image_id=' + image_id).then(function(data) {
        return data;
      });
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
      	//Get POST of id == id
        return isAuthenticated;
      },
      getStarredPosts : function() {
      	//Get POST of id == id
        return isAuthenticated;
      },
      getFollowingPosts : function() {
      	//Get POST of id == id
        return isAuthenticated;
      },
      getPopularPosts : function() {
      	//Get POST of id == id
        return isAuthenticated;
      }
    };
    
  });
  
})();