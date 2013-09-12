@Players = new Meteor.Collection 'players'

# ASCII code for !
CODE_START = 33

Meteor.methods
  register: ->
    game = Games.getGame()
    if Meteor.isServer
      if game.isStarted or game.numPlayers >= game.maxPlayers
        return
      playerIndex = game.numPlayers
      Games.update GAME_ID, $inc: numPlayers: 1
    Players.insert
      symbol: String.fromCharCode playerIndex + CODE_START
      column: playerIndex
      lives: 3
      isLeftPressed: false
      isRightPressed: false

