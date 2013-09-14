CODE_CR = 13
CODE_R  = 114

NUM_COLUMNS = 48

FONT_SIZE = 30

CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

TITLE = 'GTA VI: Man-UP city'

MESSAGE_1 = 'Connect to WiFi "manup"'
MESSAGE_2 = 'Go to http://manup'
MESSAGE_3 = 'Avoid enemie "O"s'

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
  canvas.width = CANVAS_WIDTH
  canvas.height = CANVAS_HEIGHT

  ctx = canvas.getContext '2d'
  ctx.imageSmoothingEnabled = false

  explosionAudio = @find '#explosion'

  ctx.font = "#{FONT_SIZE}px monospace"

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
    ctx.fillStyle = '#000'

    if game.state != READY
      for row, rowIndex in world
        cellY = cellHeight * rowIndex
        for cell, colIndex in row
          cellX = cellWidth * colIndex
          switch cell
            when ROCK
              ctx.fillText 'O', cellX, cellY
    else
      ctx.textAlign = 'center'

      ctx.font = "#{Math.floor(FONT_SIZE * 1.5)}px monospace"
      ctx.fillText TITLE, width / 2, height / 2 - 6 * cellHeight
      ctx.font = "#{FONT_SIZE}px monospace"
      ctx.fillText MESSAGE_1, width / 2, height / 2 - 2 * cellHeight
      ctx.fillText MESSAGE_2, width / 2, height / 2
      ctx.fillText MESSAGE_3, width / 2, height / 2 + 2 * cellHeight
      ctx.textAlign = 'left'

    playerRow = world[PLAYER_ROW]
    Players.find().forEach (player) ->
      playerX = player.column * cellWidth
      symbol = if player.lives == 0
        ctx.fillStyle = '#900'
        'X'
      else if playerRow[player.column] == ROCK
        ctx.fillStyle = '#f00'
        explosionAudio.play()
        player.lives
      else
        ctx.fillStyle = '#00c'
        if game.state != READY
          player.symbol
        else
          if player.isLeftPressed
            'L'
          else if player.isRightPressed
            'R'
          else
            player.symbol

      ctx.fillText symbol, playerX, playerY

Template.view.destroyed = ->
  $('body').unbind 'keypress', onKeypress

