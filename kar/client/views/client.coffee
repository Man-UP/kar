Template.client.helpers
  isActive: (name) ->
    key = Session.get 'key'
    if key == name
      return 'active'

  playerSymbol: ->
    currentPlayer = Players.findOne Session.get 'playerId'
    if currentPlayer?
      return currentPlayer.symbol

updateCurrentPlayer = (doc) ->
  playerId = Session.get 'playerId'
  if playerId?
    Players.update playerId,
      $set: doc

Template.client.events
  'touchstart .left': (e) ->
    Session.set 'key', 'left'
    updateCurrentPlayer(isLeftPressed: true)
    $(e.target).one('touchend', ->
      Session.set 'key', null
      updateCurrentPlayer(isLeftPressed: false)
    )

  'mousedown .left': (e) ->
    Session.set 'key', 'left'
    updateCurrentPlayer(isLeftPressed: true)

  'mouseup .left': ->
    Session.set 'key', null
    updateCurrentPlayer(isLeftPressed: false)

  'touchstart .right': (e) ->
    Session.set 'key', 'right'
    updateCurrentPlayer(isRightPressed: true)
    $(e.target).one('touchend', ->
      Session.set 'key', null
      updateCurrentPlayer(isRightPressed: false)
    )

  'mousedown .right': (e) ->
    Session.set 'key', 'right'
    updateCurrentPlayer(isRightPressed: true)

  'mouseup .right': ->
    Session.set 'key', null
    updateCurrentPlayer(isRightPressed: false)

