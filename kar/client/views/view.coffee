CODE_CR = 13
CODE_R  = 114

NUM_COLUMNS = 48

onKeypress = (event) ->
  logError = (error) ->
    if error?
      console.log error
  switch event.which
    when CODE_CR
      console.log 'Starting game'
      Meteor.call 'start', logError
    when CODE_R
      console.log 'Resetting'
      Meteor.call 'reset', logError

Template.view.created = ->
  $('body').on 'keypress', onKeypress

Template.view.rendered = ->
  if @handle?
    return

  canvas = @find '.world'
  ctx = canvas.getContext '2d'

  @handle = Deps.autorun ->
    game = Games.getGame()
    if game.state == FINISHED
      Games.update GAME_ID, $set: state: VIEWED
      Router.go 'scoreboard'
    world = game.world

    width = canvas.width
    height = canvas.height

    cellWidth = width / NUM_COLUMNS
    cellHeight = height / NUM_ROWS
    playerY = PLAYER_ROW * cellHeight

    ctx.clearRect 0, 0, width, height

    for row, rowIndex in world
      cellY = cellHeight * rowIndex
      for cell, colIndex in row
        cellX = cellWidth * colIndex
        switch cell
          when ROCK
            ctx.fillText 'O', cellX, cellY

    playerRow = world[PLAYER_ROW]
    Players.find().forEach (player) ->
      playerX = player.column * cellWidth
      symbol = if player.lives == 0
        'D'
      else if playerRow[player.column] == ROCK
        'C'
      else
        player.symbol
      ctx.fillText symbol, playerX, playerY

Template.view.destroyed = ->
  $('body').unbind 'keypress', onKeypress

