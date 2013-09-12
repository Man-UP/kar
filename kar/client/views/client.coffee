Meteor.startup ->
  Session.set 'key', null

Template.client.created = ->
  Deps.autorun ->
    playerId = Session.get 'playerId'
    player = Players.findOne playerId
    unless player?
      if @handle?
        @handle.stop()
      Meteor.call 'register', (error, result) =>
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
      if key == 'left'
        backgroundContext.fillStyle = '#ff0000'
        backgroundContext.fillRect 0, 0, arrowWidth, CANVAS_HEIGHT
      else if key == 'right'
        backgroundContext.fillStyle = '#ff0000'
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
          context.font="#{SYMBOL_SIZE}px Arial"
          context.textAlign = 'center'
          context.fillText currentPlayer.symbol, x, arrowHeight

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

Template.client.events
  'touchstart .left': (e) ->
    console.log e
    Session.set 'key', 'left'
    updateCurrentPlayer(isLeftPressed: true)
    $(e.target).one('touchend', ->
      Session.set 'key', null
      updateCurrentPlayer(isLeftPressed: false)
    )

  'mousedown .left': (e) ->
    Session.set 'key', 'left'
    updateCurrentPlayer(isLeftPressed: true)

  'mouseup .left': ->
    Session.set 'key', null
    updateCurrentPlayer(isLeftPressed: false)

  'touchstart .right': (e) ->
    Session.set 'key', 'right'
    updateCurrentPlayer(isRightPressed: true)
    $(e.target).one('touchend', ->
      Session.set 'key', null
      updateCurrentPlayer(isRightPressed: false)
    )

  'mousedown .right': (e) ->
    Session.set 'key', 'right'
    updateCurrentPlayer(isRightPressed: true)

  'mouseup .right': ->
    Session.set 'key', null
    updateCurrentPlayer(isRightPressed: false)

