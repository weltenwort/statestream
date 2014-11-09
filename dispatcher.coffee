Bacon = require 'baconjs'


class Dispatcher
  constructor: (options={}) ->
    options.debug ?= false
    options.initialState ?= {}

    @events = new Bacon.Bus()
    @modifications = new Bacon.Bus()

    @state = @modifications.scan options.initialState, @modifyState
    @stateChanges = @state.changes()

    if options.debug
      @modifications.log 'modification'
      @state
        .map (state) -> state?.toJS?()
        .log 'state'

  addActors: (actors) =>
    for actor in actors ? []
      @addActor actor

    this

  addActor: (actor) =>
    result = actor events: @events, state: @stateChanges
    if result?
      @modifications.plug result

    this

  initialize: => @dispatch 'Initialized'

  modifyState: (state, modifier) -> modifier state

  dispatch: (name, payload) =>
    @events.push
      event: name
      payload: payload ? null


module.exports = Dispatcher
