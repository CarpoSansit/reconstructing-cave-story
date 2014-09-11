
# Standard Library Function
#
# This is mainly a thin wrapper around prelude, but we will also provide
# a bunch of other helper functions and stuff here as we accumulate them.


# Get the functions we want out of Prelude

{ id, map, filter, any } = require \prelude-ls


# Other helpers

log = -> console.log.apply console, &; &0

obj-map = (λ, o) --> [ λ k, v for k, v of o ]



# Export

export {
  id
  log
  any
  map
  obj-map
  filter

  # Enum helper - assign sequential integers using destructuring syntax
  enum: [ 0 to 20 ]
}

