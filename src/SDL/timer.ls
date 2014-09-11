
# SDL Mock - Timer
#
# Provides functions like SDL_GetTicks, although at less accuracy


# Internal state

start-time = 0


# Export

export do
  init: ->
    start-time := Date.now!

  get-ticks: ->
    Date.now! - start-time

