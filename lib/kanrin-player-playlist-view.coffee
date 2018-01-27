{View,SelectListView} = require 'atom-space-pen-views'
$ = require 'jquery'
path = require 'path'

class PlayListView extends SelectListView
  initialize: (@player, @items) ->
    super
    @addClass 'overlay from-top'
    @setItems @items
    @panel ?= atom.workspace.addModalPanel item:@
    @panel.show()
    @focusFilterEditor()

  viewForItem: (track)->
      "<li>#{path.parse(track.path).name}</li>"

  confirmed: (track)->
      @player.playTrackByItem(track)
      @parent().remove()

  cancelled: ->
    @parent().remove()

  getFilterKey: ->
    "name"
module.exports = PlayListView
