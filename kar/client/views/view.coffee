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
  @handle = Deps.autorun =>
    width = canvas.width
    height = canvas.height
    ctx.clearRect 0, 0, width, height
    colWidth = width / NUM_COLUMNS
    Players.find().forEach (player) ->
      x = player.column * colWidth
      ctx.fillText player.symbol, x, 100

Template.view.destroyed = ->
  $('body').unbind onKeypress

