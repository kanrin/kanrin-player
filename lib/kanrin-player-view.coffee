{$, View} = require 'atom-space-pen-views'
playListView = require './kanrin-player-playlist-view'
path = require 'path'
module.exports =
class KanrinPlayerView extends View
  constructor: (serializedState) ->
    super()
    if serializedState?
      @isPlaying = serializedState.isPlaying
      @playList = serializedState.playList
      @playListCopy = serializedState.playListCopy
      @currentTrack = serializedState.currentTrack
      @shuffle = serializedState.shuffle
      @playTrackByItem @currentTrack
    else
      @isPlaying = false
      @playList = []
      @playListCopy = []
      @currentTrack = null
      @shuffle = false

  @content: ->
    @div class:'kanrin-player', =>
      @div class:'audio-controls-container', outlet:'container', =>
        @div class:'btn-group btn-group-sm', =>
          @button class:'btn icon icon-jump-left', click:'prevTrack'
          @button class:'btn icon playback-button icon-playback-play', click:'togglePlayback'
          @button class:'btn icon icon-jump-right', click:'nextTrack'
        @div class:'btn-group btn-group-sm pull-right', =>
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'button', click:'toggleShuffle'
            @span  class:'btn shuffle-button icon icon-sync', id:'order'
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'button', click:'showPlayList'
            @span  class:'btn icon icon-list-unordered',
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'button', click:'clearPlayList'
            @span class:'btn icon icon-trashcan',
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'file', multiple:true, accept:"audio/mp3", outlet:"musicFileSelectionInput"
            @span class:'btn icon icon-file-directory',
        @div class:'inline-block playing-now-container', =>
          @span '', class:'highlight', outlet:'stateTag'
          @span '', class:'highlight', outlet:'nowPlayingTitle'
      @div class:'kanrin-player-list-container'
      @tag 'audio', class:'audio-player', outlet:'audio_player', =>

  initialize: ->
    self = @
    @musicFileSelectionInput.on 'change', @filesBrowsed
    @audio_player.on 'play', ( ) =>
      @stateTag.html('＞ ')
      $('.playback-button').removeClass('icon-playback-play').addClass('icon-playback-pause')
    @audio_player.on 'pause', ( ) =>
      @stateTag.html('|| ')
      $('.playback-button').removeClass('icon-playback-pause').addClass('icon-playback-play')
    @audio_player.on 'ended', @songEnded

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)
    @panel.show()

  toggle:->
    if @panel?.isVisible()
      @hide()
    else
      @show()

  songEnded: ( e ) =>
    console.log "Changing track"
    @nextTrack()

  nextTrack: ->
    player = @audio_player[0]
    if @currentTrack?
      currentTrackIndex = @playList.indexOf @currentTrack
      if currentTrackIndex == (@playList.length - 1)
        @shuffleList() if @shuffle
        currentTrackIndex = 0
      else
        currentTrackIndex += 1
      @playTrack currentTrackIndex
    # player.pause()

  prevTrack: ->
    player = @audio_player[0]
    if @currentTrack?
      currentTrackIndex = @playList.indexOf @currentTrack
      if currentTrackIndex == 0
        currentTrackIndex = 0
      else
        currentTrackIndex -= 1
      @playTrack currentTrackIndex

  playTrackByItem: (item) ->
    @shuffleList() if @shuffle
    @playTrack @playList.indexOf(item)

  playTrack: ( trackNum ) ->
    track = @playList[trackNum]
    player = @audio_player[0]
    if track?
      @currentTrack = track
      @nowPlayingTitle.html (path.parse(track.path).name)
      player.pause()
      player.src = track.path
      player.load()
      player.play()

  stopTrack: ( trackNum ) ->
    track = @playList[trackNum]
    player = @audio_player[0]
    if track?
      @togglePlayback() if not player.paused
      @currentTrack = null
      @stateTag.html('')
      @nowPlayingTitle.html ('')
      player.src = null

  filesBrowsed: ( e ) =>
    files = $(e.target)[0].files
    if files? and files.length > 0
      @playListHash = {}
      for f in @playList
        @playListHash[f.name] = 1
      for f in files
        if !@playListHash[f.name]?
          @playList.unshift { name:f.name, path:f.path }
      @playListCopy = @playList[...]

      @playTrack 0

  togglePlayback: ->
    player = @audio_player[0]
    if @currentTrack?
      if player.paused or player.currentTime == 0
        player.play()
        @stateTag.html('＞ ')
        $('.playback-button').removeClass('icon-playback-play').addClass('icon-playback-pause')
      else
        player.pause()
        @stateTag.html('|| ')
        $('.playback-button').removeClass('icon-playback-pause').addClass('icon-playback-play')

  shuffleList: ->
    for i in [@playList.length..1]
      j = Math.floor Math.random() * i
      [@playList[i - 1], @playList[j]] = [@playList[j], @playList[i - 1]]

  toggleShuffle: ->
    @shuffle = !@shuffle
    if @shuffle
      $('.shuffle-button').removeClass('icon-sync')
      $('.shuffle-button').addClass('icon-issue-reopened')
      @shuffleList()
    else
      $('.shuffle-button').removeClass('icon-issue-reopened')
      $('.shuffle-button').addClass('icon-sync')
      @playList = @playListCopy[...]

  showPlayList: ->
    new playListView @, @playListCopy

  clearPlayList: ->
    @stopTrack 0
    @playList = []
    @playListCopy = []

  hide: ->
    @panel?.hide()

  serialize: ->
    isPlaying: @isPlaying
    playList: @playList
    playListCopy: @playListCopy
    currentTrack: @currentTrack
    shuffle: @shuffle
