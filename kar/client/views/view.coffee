Template.view.helpers
  players: ->
    Players.find()

CODE_CR = 13
CODE_R = 114

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

Template.view.destroyed = ->
  $('body').unbind onKeypress

