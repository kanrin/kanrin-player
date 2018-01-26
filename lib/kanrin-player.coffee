KanrinPlayerView = require './kanrin-player-view'
{CompositeDisposable} = require 'atom'

module.exports = KanrinPlayer =
  kanrinPlayerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @kanrinPlayerView = new KanrinPlayerView(state.kanrinPlayerViewState)
    # Register command that toggles this view
    atom.commands.add 'atom-workspace', 'kanrin-player:toggle': => @kanrinPlayerView.toggle()

  deactivate: ->
    @kanrinPlayerView.destroy()

  serialize: ->
    kanrinPlayerViewState: @kanrinPlayerView.serialize()
