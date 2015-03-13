'use strict'

###*
 # @ngdoc function
 # @name four4App.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the four4App
###
angular.module 'four4App'
  .controller 'MainCtrl', ['$scope', '$interval', '$timeout', ($scope, $interval, $timeout) ->
      $scope.stage = {
          library: {files: [], num_preload: 5},
          decks: {one: off, two: off},
          playing: off, tempo: 122,
          measure: 1, m_part: 1, m_frac: 1,
          pause: () ->
              for deck in $scope.stage.decks
                  if deck and deck.song and deck.song.tag
                      deck.song.tag.pause()
              $scope.stage.playing = off
              for name, deck of $scope.stage.decks
                  if deck.playing
                      deck.pause()
          play: () ->
              $scope.stage.playing = on
              $scope.stage.position ||= {measure: 1, part: 1}
              $scope.stage.position.started = getTime()
              $scope.stage.new_measure = () ->
                  for name, deck of $scope.stage.decks
                      if deck._playOnMeasure
                          deck.song.audio_tag.volume = 1
                          deck.song.audio_tag.play()
                          deck._playOnMeasure = off
              $scope.stage.new_measure()
              $scope.stage.position_timer = () ->
                  current_time = getTime() - $scope.stage.position.started
                  mf = measureAtTime(current_time, $scope.stage.tempo)
                  [m, p] = measureFloatToParts(mf)
                  old_measure = $scope.stage.position.measure
                  $scope.stage.position = {measure: m, part: p, time: current_time, started: $scope.stage.position.started}
                  if old_measure != m
                      $scope.stage.new_measure()
                  $timeout(() ->
                    $scope.$apply()
                  )
              $scope.stage.position_interval = $interval($scope.stage.position_timer, 100)
          stop: () ->
              $scope.stage.playing = off
              $scope.stage.position = {measure: 1, part: 1}
              for name, deck of $scope.stage.decks
                  if deck.playing
                      deck.stop()
      }
  ]
