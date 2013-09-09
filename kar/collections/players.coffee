@Players = new Meteor.Collection 'players'

# ASCII code for !
CODE_START = 33
CODE_END = 127
MAX_OFFSET = CODE_END - CODE_START

# Resets when server restarts
nextOffset = 0

getNextChar = ->
  char = String.fromCharCode CODE_START + nextOffset
  nextOffset = (nextOffset + 1) % (MAX_OFFSET + 1)
  char

Meteor.methods
  register: ->
    Players.insert
      symbol: getNextChar()
      lives: 3
      isLeftPressed: false
      isRightPressed: false

