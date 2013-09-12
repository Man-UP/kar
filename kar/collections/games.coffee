@GAME_ID = 'game'

@READY = 0
@STARTED = 1
@FINISHED =  2
@VIEWED = 3

@MAX_PLAYERS = 48
@NUM_COLUMNS = 48
@NUM_ROWS = 20
@PLAYER_ROW = @NUM_ROWS - 5

@EMPTY = 0
@ROCK = 1

@TURN_DURATION_MS = 100

@Games = new Meteor.Collection 'games'

GameState =
  mainLoopHandle: null

Games.createGame = ->
  world = for _ in [0...NUM_ROWS]
    for _ in [0...NUM_COLUMNS]
      EMPTY

  # Create new game
  Games.insert
    _id: GAME_ID
    numPlayers: 0
    numTurns: 0
    rockProb: 0.005
    state: READY
    world: world

Games.tryGetGame = ->
  Games.findOne GAME_ID

Games.getGame = ->
  until game = Games.tryGetGame()
    Games.createGame()
  game

Meteor.methods
  'reset': ->
    ensureMainLoopStopped()
    Players.remove {}
    Games.remove GAME_ID

  'start': ->
    game = Games.getGame()
    unless game.state == READY
      return false
    if Meteor.isServer
      GameState.mainLoopHandle = Meteor.setInterval mainLoop, TURN_DURATION_MS
    Games.update GAME_ID, $set: state: STARTED
    true

mainLoop = ->
  game = Games.getGame()
  world = game.world

  # Move players
  Players.find(lives: $gt: 0).forEach (player) ->
    modifier = $inc: score: 1

    # Move player
    if player.isLeftPressed and not player.isRightPressed and \
        player.column > 0
      inc = -1
    else if not player.isLeftPressed and player.isRightPressed and \
        player.column < NUM_COLUMNS
      inc = 1
    if inc?
      modifier.$inc.column = inc
    Players.update player._id, modifier

  # Update world
  newRow = for _ in [0...NUM_COLUMNS]
    p = Math.random()
    switch
      when p < game.rockProb then ROCK
      else EMPTY

  world.unshift newRow
  world = world.slice 0, world.length - 1

  Games.update GAME_ID,
    $set:
      world: world
    $inc:
      numTurns: 1
      rockProb: 0.0001

  # Check for collisions
  playerRow = world[PLAYER_ROW]
  Players.find().forEach (player) ->
    if playerRow[player.column] == ROCK and player.lives > 0
      Players.update player._id, $inc: lives: -1

  if Players.find(lives: $gt: 0).count() == 0
    ensureMainLoopStopped()
    Games.update GAME_ID, $set: state: FINISHED

ensureMainLoopStopped = ->
  if Meteor.isServer and GameState.mainLoopHandle?
    Meteor.clearInterval GameState.mainLoopHandle
    GameState.mainLoopHandle = null

