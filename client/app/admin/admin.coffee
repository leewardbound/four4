'use strict'

angular.module 'socket4App'
.config ($routeProvider) ->
  $routeProvider
  .when '/admin',
    templateUrl: 'app/admin/admin.html'
    controller: 'AdminCtrl'
