
# SDL Mock - Event Queue
#
# Any events monitored by SDL Mock accumulate on the queue. They are
# popped from the queue by the poll-event function, which returns the
# oldest event in the queue, or undefined if it's empty.

# Require

require! \std


# Internal State

queue = []


# Export

export do
  push-event: (event) ->
    queue.push event

  poll-event: ->
    if queue.length
      queue.shift!

