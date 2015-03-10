'use strict'

angular.module 'four4App'
.config ($routeProvider) ->
  $routeProvider
  .when '/admin',
    templateUrl: 'app/admin/admin.html'
    controller: 'AdminCtrl'
