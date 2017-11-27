(function() {
  var app = angular.module('myApp', ['ui.router']);
  
  //Main run function
  app.run(function($rootScope, $location, $state, LoginService) {
    $rootScope.$on('$stateChangeStart', 
      function(event, toState, toParams, fromState, fromParams){ 
          console.log('Changed state to: ' + toState);
      });
    
      if(!LoginService.isAuthenticated()) {
        $state.transitionTo('login');
      }
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
      });
  }]);

  app.controller('LoginController', function($scope, $rootScope, $stateParams, $state, LoginService) {
    $rootScope.title = "AngularJS Login Sample";
    
    $scope.formSubmit = function() {
      if(LoginService.login($scope.username, $scope.password)) {
        $scope.error = '';
        $scope.username = '';
        $scope.password = '';
        $state.transitionTo('profile');
      } else {
        $scope.error = "Incorrect username/password !";
      }   
    };
    
  });
  
  app.controller('ProfileController', function($scope, $rootScope, $stateParams, $state, LoginService) {
    $rootScope.title = "AngularJS Login Sample";
    
    $scope.logout = function() {
      	//LOGOUT CODE GOES HERE
    	LoginService.isAuthenticated = false;
    	$state.transitionTo('login');
    }
  });
  
  app.factory('LoginService', function() {
    var admin = 'admin';
    var pass = 'pass';
    var isAuthenticated = false;
    
    return {
      login : function(username, password) {
      	//AUTHENTICATION CODE HERE
        isAuthenticated = username === admin && password === pass;
        return isAuthenticated;
      },
      logout : function() {
      	//DE-AUTHENTICATION CODE HERE
        isAuthenticated = false;
      },
      isAuthenticated : function() {
      	//CHECK IF CURRENTLY AUTHENTICATED
        return isAuthenticated;
      }
    };
    
  });

  app.factory('PostService', function() {    
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
      	//Get POST of id == id
        return isAuthenticated;
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