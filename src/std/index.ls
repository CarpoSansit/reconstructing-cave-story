
# Standard Library Function
#
# This is mainly a thin wrapper around prelude, but we will also provide
# a bunch of other helper functions and stuff here as we accumulate them.


# Get the functions we want out of Prelude

{ id, map, filter, reject, any, div } = require \prelude-ls


# Custom helpers

export log  = -> console.log.apply  console, &; &0
export info = -> console.info.apply console, &; &0

export obj-map = (λ, o) --> [ λ k, v for k, v of o ]

export mash = -> { [ k, v ] for [ k, v ] in it }

export flip  = (λ) -> (a, b) --> λ b, a

export delay = flip set-timeout

export round = Math.round
export floor = Math.floor
export abs   = Math.abs
export max   = Math.max
export min   = Math.min
export sin   = Math.sin
export cos   = Math.cos

export pi  = Math.PI
export tau = Math.PI * 2

export rand = (min, max) -> min + Math.random! * (max - min)


# Custom Exceptions

export class InterfaceError extends Error
  (@message) ->
    @name = \InterfaceError


# Export

export {
  # Specified Prelude functions only
  id, any, map, filter, reject, div,

  # Enum helper - assign sequential integers using destructuring syntax
  enum: [ 0 to 20 ]

  # Bitmask helper - assign sequential binary multiple for mapping
  bitmask: [ 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 ]

}

