Template.client.helpers
  isActive: (name) ->
    key = Session.get 'key'
    if key == name
      return 'active'

Template.client.events
  'touchstart .left': (e) ->
    Session.set 'key', 'left'
    $(e.target).one('touchend', ->
      Session.set 'key', null
    )

  'mousedown .left': (e) ->
    Session.set 'key', 'left'

  'mouseup .left': ->
    Session.set 'key', null

  'touchstart .right': (e) ->
    Session.set 'key', 'right'
    $(e.target).one('touchend', ->
      Session.set 'key', null
    )

  'mousedown .right': (e) ->
    Session.set 'key', 'right'

  'mouseup .right': ->
    Session.set 'key', null

