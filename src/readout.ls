
# Readout
#
# Helper to output streams of information without clogging the console

require! \./config


# Helpers

elm = document~create-element
apply-styles = (el, styles) -> [ el.style[k] = v for k, v of styles ]


# Reader - a label for an updatable value - one row of the readout

class Reader

  (@name, @label-text, @value) ->
    @dom    = elm \tr
    @label  = elm \td
    @output = elm \td

    # Init
    @dom.append-child @label
    @dom.append-child @output
    @label.innerHTML = @label-text
    if @value then @output.innerHTML = that

  update: (@value) -> @output.innerHTML = @value
  hide: -> @dom.styles.display = \none
  show: -> @dom.styles.display = \block
  install: (host) -> host.append-child @dom
  delete: -> @dom.parentNode.remove-child @dom


#
# Singleton
#

# State

host    = elm \table
readers = {}


# Setup

apply-styles host, do
  font-family: \monospace
  width: \100%
  padding-left: \10px
  color: \lightgrey
  border-width: "3px 1px"


# Methods

export install = ->
  if config.show-readout
    document.body.append-child host

export add-reader = (name, label, value) ->
  readers[name] = new Reader name, label, value
  readers[name].install host

export update = (reader-name, value) ->
  readers[reader-name]?.update value

export remove-reader = (name) ->
  readers[name].delete!
  delete readers[name]


