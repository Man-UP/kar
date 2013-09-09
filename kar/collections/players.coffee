@Players = new Meteor.Collection 'players'

# ASCII code for !
CODE_START = 33

Meteor.methods
  register: ->
    if Meteor.isServer
      if GameState.isRunning or GameState.numPlayers >= MAX_COLUMN
        return
      playerIndex = GameState.numPlayers++
    Players.insert
      symbol: String.fromCharCode playerIndex + CODE_START
      column: playerIndex
      lives: 3
      isLeftPressed: false
      isRightPressed: false

