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
                          proposed_time = deck.song.zeroBeat
                          deck.position.start_measure = $scope.stage.position.measure
                          deck.position.started = $scope.stage.position.time
                          if(!isNaN(proposed_time))
                              deck.song.audio_tag.currentTime = proposed_time
              $scope.stage.new_measure_part = () ->
                  for name, deck of $scope.stage.decks
                      if deck.playing
                          proposed_measure = $scope.stage.position.measure - deck.position?.start_measure + 1
                          proposed_time = deck.song.zeroBeat + startOfMeasure(proposed_measure,
                              $scope.stage.position.part, deck.song.bpm)
                          drift = proposed_time - deck.song.audio_tag.currentTime
                          normal_bpm = bpmRatio(deck.song.bpm, $scope.stage.tempo)
                          if(!isNaN(proposed_time) and Math.abs(drift) > .06)
                              if Math.abs(drift) > 0.2
                                  deck.song.audio_tag.currentTime = proposed_time
                              else
                                  deck.song.audio_tag.playbackRate = normal_bpm * (1+(drift/4))
                          else
                              deck.song.audio_tag.playbackRate = normal_bpm
              $scope.stage.new_measure()
              $scope.stage.position_timer = () ->
                  current_time = getTime() - $scope.stage.position.started
                  mf = measureAtTime(current_time, $scope.stage.tempo)
                  [m, p] = measureFloatToParts(mf)
                  old_measure = $scope.stage.position.measure
                  old_measure_part = $scope.stage.position.part
                  $scope.stage.position = {measure: m, part: p, time: current_time, started: $scope.stage.position.started}
                  if old_measure_part != p
                      $scope.stage.new_measure_part()
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
