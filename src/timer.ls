
#
# Timers
#

require! \std
require! \./units


# Timer class

export class Timer

  all-timers = []

  (@expiration-time, start-active = no) ->
    @current-time = if start-active then 0 else @expiration-time
    all-timers.push this

  update: (elapsed-time) ->
    @current-time += elapsed-time

  reset: ->
    @current-time = 0

  is-active:~ ->
    @current-time < @expiration-time

  is-expired:~ ->
    not @is-active

  active: -> @current-time < @expiration-time
  expired: -> not (@current-time < @expiration-time)

  @update-all = (elapsed-time) ->
    all-timers.map (.update elapsed-time)

