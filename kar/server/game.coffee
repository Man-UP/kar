# Resets when server restarts

@MIN_COLUMN = 0
@MAX_COLUMN = 48

@GameState =
  isRunning: false
  intervalId: null
  numPlayers: 0

mainLoop = ->
  Players.find().forEach (player) ->
    if player.isLeftPressed and not player.isRightPressed and \
        player.column > MIN_COLUMN
      inc = -1
    else if not player.isLeftPressed and player.isRightPressed and \
        player.column < MAX_COLUMN
      inc = 1
    if inc?
      Players.update player._id, $inc: column: inc

Meteor.methods
  'start': ->
    GameState.isRunning = true
    GameState.intervalId = Meteor.setInterval mainLoop, 500

  'reset': ->
    if GameState.intervalId?
      Meteor.clearInterval GameState.intervalId
    GameState.isRunning = false
    GameState.intervalId = null
    GameState.numPlayers = 0
    Players.remove {}

