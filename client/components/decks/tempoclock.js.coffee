'use strict'

###*
# @ngdoc function
# @name four4App.directive:MediaDeckDirective
# @description
# # MediaDeckDirective
###

angular.module('four4App').directive 'fourTempoClock', ->
  {
    replace: true
    templateUrl: 'components/decks/tempoclock.html'
    scope:
      stage: '='
    link: (scope, element, attr) ->
        on
  }
