'use strict'

###*
# @ngdoc function
# @name four4App.controller:LibraryCtrl
# @description
# # LibraryCtrl
# Controller of the four4App
###

angular.module('four4App').directive 'fourLibrary', ->
  {
    templateUrl: 'components/decks/library.html'
    scope: stage: '='
    link: ($scope, element, attr) ->

      $scope.row_color = (_) ->
        if _.ready
          return 'success'
        if _.loading
          return 'info'
        else
          return 'primary'
        return

      $scope.stage.library = library = $scope.stage.library || files: []

      $scope.stage.addFile = (title, fn, bpm, zeroBeat) ->
        song = 
          title: title
          path: fn
          bpm: bpm
          zeroBeat: zeroBeat
          loading: false
          ready: false
        library.files.push(song)
        library.preload_song(song)
        return

      library.preload_song = (song) =>
        console.log('Preloading',song.path)
        window.URL = window.URL || window.webkitURL
        xhr = new XMLHttpRequest()
        xhr.open('GET', song.path, true)
        xhr.responseType = 'arraybuffer'
        xhr.onload = (e) ->
          if (this.status == 200)
            array = new Uint8Array(this.response)
            tag = song.audio_tag = document.createElement('audio')
            elem = song.element = angular.element(tag)
            song.arraybuffer = array
            song.context =new AudioContext
            song.analyze = (buff) =>
                console.log('Analyzing', song.title)
                song.analyzed = []
                SR = song.context.sampleRate
                LC = buff.getChannelData(0)
                # Float32Array describing left channel
                L = LC.length
                op = W / L
                song.analyze_scale = song.duration * 2
                song.analyze_width = W = L / song.analyze_scale | 0
                H=128
                i = 0
                while i < L
                  x = W * i / L | 0
                  y = LC[i] * H / 2
                  if song.analyzed[x]
                    song.analyzed[x].push y
                  else
                    !song.analyzed[x - 1] or (song.analyzed[x - 1] = aMax(song.analyzed[x - 1]))
                    song.analyzed[x] = [ y ]
                  i++
                console.log('Analyzed!',song.title)
            song.context.decodeAudioData(this.response,song.analyze)
            tag.onload = (e) ->
              window.URL.revokeObjectURL(tag.src)
            tag.src = window.URL.createObjectURL(new Blob([array.buffer]))
            elem = song._element = angular.element(tag)
            tag.preload = 'auto'
            song.nudgeTimer = setInterval( () =>
                tag.volume = 0
                try
                  tag.currentTime = Math.max(0, (tag.duration * (tag.percent)/100.0))
                catch
                  # pass
                elem.trigger('play')
                $scope.$apply()
            , 500)
            loadEvent = (e) =>
                for i in [0..tag.buffered.length-1]
                    loaded = tag.buffered.end(i) - tag.buffered.start(i)
                song.loading = tag.percent = pct = Math.floor(((loaded/tag.duration)||0)*100)
                song.duration = e.target.duration
                if pct == 100
                    song.ready = on
                    elem.trigger('pause')
                    elem.off('loaded').off('canplay').off('progress')
                    elem.trigger('ready')
                    clearInterval(song.nudgeTimer)
                    for name, deck of $scope.stage.decks
                        if !deck.song.title
                            deck.loadSong(song)
                            break
                $scope.$apply()
            elem.on('loaded', loadEvent).on('canplay', loadEvent).on('progress', loadEvent)
        xhr.send()

      $scope.stage.addFile 'Watch What', 'MP3/watchwhat.mp3', 122, .030
      $scope.stage.addFile 'Staring Into One Eye', 'MP3/oneeye.mp3', 126, .032
      return

  }
