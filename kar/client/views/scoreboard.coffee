Template.scoreboard.helpers
  players: ->
    Players.find {}, sort: score: -1

