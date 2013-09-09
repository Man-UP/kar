$(->
  FastClick.attach(document.body)
)

Meteor.startup ->
  Meteor.call 'register', (error, result) ->
    if error?
      alert error.reason
    else
      Session.set 'playerId', result

Router.configure
  layout: 'layout'
  loadingTemplate: 'loading'

