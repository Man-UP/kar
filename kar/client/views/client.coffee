Meteor.startup ->
  Session.set 'key', null

Template.client.created = ->
  # XXX: can't catch global keypresses using the event mapping in templates
  # so do it here instead.
  $(document).on 'keydown', (e) ->
    if e.keyCode == 37
      leftKeyPress()
    # right key
    else if e.keyCode == 39
      rightKeyPress()
  $(document).on 'keyup', (e) ->
    if e.keyCode = 37
      leftKeyUp()
    else if e.keyCode == 39
      rightKeyUp()

  Deps.autorun ->
    playerId = Session.get 'playerId'
    player = Players.findOne playerId
    unless player? or @calling
      if @handle?
        @handle.stop()
      @calling = true
      Meteor.call 'register', (error, result) =>
        # XXX: calling hack to stop repeated registering
        @calling = false
        if error?
          alert error.reason
        else
          Session.set 'playerId', result
          players = Players.find(result)
          @handle = players.observeChanges
            removed: ->
              Session.set 'playerId', null

CANVAS_WIDTH = 320
CANVAS_HEIGHT = 240
SYMBOL_SIZE = CANVAS_WIDTH / 4
LIVES_SIZE = CANVAS_WIDTH / 16
INFO_SIZE = CANVAS_WIDTH / 16

BUTTON_PRESS_BG_COLOR = "c6ffc8"

Template.client.rendered = ->
  arrowWidth = CANVAS_WIDTH / 2
  arrowHeight = CANVAS_HEIGHT / 2

  backgroundCanvas = @find '#controller-background'
  backgroundCanvas.width = CANVAS_WIDTH
  backgroundCanvas.height = CANVAS_HEIGHT
  backgroundContext = backgroundCanvas.getContext '2d'
  if not @backgroundHandler?
    @backgroundHandler = Deps.autorun ->
      key = Session.get 'key'
      backgroundContext.clearRect 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT
      backgroundContext.fillStyle = BUTTON_PRESS_BG_COLOR
      if key == 'left'
        backgroundContext.fillRect 0, 0, arrowWidth, CANVAS_HEIGHT
      else if key == 'right'
        backgroundContext.fillRect arrowWidth, 0, arrowWidth, CANVAS_HEIGHT

  canvas = @find '#controller'
  canvas.width = CANVAS_WIDTH
  canvas.height = CANVAS_HEIGHT
  context = canvas.getContext '2d'
  context.imageSmoothingEnabled = false

  counter = 2
  updateCounter = ->
    counter -= 1
    if counter <= 0
      setHandler()

  setHandler = ->
    if not @canvasHandler?
      @canvasHandler = Deps.autorun ->
        currentPlayer = Players.findOne Session.get 'playerId'
        context.clearRect 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT
        context.drawImage rightArrow, arrowWidth, 0, arrowWidth, CANVAS_HEIGHT
        context.drawImage leftArrow, 0, 0, arrowWidth,  CANVAS_HEIGHT
        if currentPlayer?
          x = arrowWidth
          context.fillStyle = '#cccc78'
          context.textAlign = 'center'
          context.font = "#{INFO_SIZE}px monospace"
          context.fillText "YOUR SYMBOL IS", x, arrowHeight - SYMBOL_SIZE
          context.strokeStyle = '#0cc'
          context.strokeText "YOUR SYMBOL IS", x, arrowHeight - SYMBOL_SIZE
          context.font = "#{SYMBOL_SIZE}px monospace"
          context.fillStyle = '#45ff78'
          context.fillText currentPlayer.symbol, x, arrowHeight
          context.strokeStyle = '#000000'
          context.strokeText currentPlayer.symbol, x, arrowHeight
          context.font  = "#{LIVES_SIZE}px monospace"
          context.textAlign = 'left'
          context.fillStyle = '#cccc78'
          context.fillText "LIVES: #{currentPlayer.lives}", 0, LIVES_SIZE
          context.strokeText "LIVES: #{currentPlayer.lives}", 0, LIVES_SIZE

  randomString = "#{Math.random()}"
  leftArrow = new Image()
  leftArrow.src = "arrow-left.png?cachebust=#{randomString}"
  leftArrow.onload = ->
    updateCounter()
  rightArrow = new Image()
  rightArrow.src = "arrow-right.png?cachebust=#{randomString}"
  rightArrow.onload = ->
    updateCounter()



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

leftKeyPress = ->
  Session.set 'key', 'left'
  updateCurrentPlayer(isLeftPressed: true)

rightKeyPress = ->
  Session.set 'key', 'right'
  updateCurrentPlayer(isRightPressed: true)

leftKeyUp = ->
  Session.set 'key', null
  updateCurrentPlayer
    isLeftPressed: false
    isRightPressed: false

rightKeyUp = ->
  Session.set 'key', null
  updateCurrentPlayer(isRightPressed: false)


Template.client.events
  'touchstart .left': (e) ->
    console.log e
    Session.set 'key', 'left'
    updateCurrentPlayer(isLeftPressed: true)
    $(e.target).one('touchend', ->
      Session.set 'key', null
      updateCurrentPlayer
        isLeftPressed: false
        isRightPressed: false
    )

  'mousedown .left': leftKeyPress

  'mouseup .left': leftKeyUp

  'touchstart .right': (e) ->
    Session.set 'key', 'right'
    updateCurrentPlayer(isRightPressed: true)
    $(e.target).one('touchend', ->
      Session.set 'key', null
      updateCurrentPlayer
        isLeftPressed: false
        isRightPressed: false
    )

  'mousedown .right': rightKeyPress

  'mouseup .right': rightKeyUp

