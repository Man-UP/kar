@GAME_ID = 'game'

@Games = new Meteor.Collection 'games'
Games.getGame = ->
  until game = Games.findOne GAME_ID
    Meteor.call 'reset'
  game

Meteor.methods
  'reset': ->
    Players.remove {}
    Games.remove GAME_ID

    # Create new game
    Games.insert
      _id: GAME_ID
      intervalId: null
      isStarted: false
      maxPlayers: 48
      numColumns: 48
      numPlayers: 0

  'start': ->
    intervalId = if Meteor.isServer
      Meteor.setInterval mainLoop, 500

    Games.update GAME_ID,
      $set:
        intervalId: intervalId
        isStarted: true

mainLoop = ->
  game = Games.getGame()
  Players.find().forEach (player) ->
    if player.isLeftPressed and not player.isRightPressed and \
        player.column > 0
      inc = -1
    else if not player.isLeftPressed and player.isRightPressed and \
        player.column < game.numColumns
      inc = 1
    if inc?
      Players.update player._id, $inc: column: inc

