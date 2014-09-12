
# SDL Mock - Screen


# Require

require! \std

Surface = require \./surface


# Reference constants

[ FULLSCREEN ] = std.enum


# Functions

create-new-screen = (w, h, is-fullscreen) ->
  screen = new Surface null, w, h
  document.body.append-child screen.canvas
  return screen

export set-video-mode = (width, height, flags) ->
  create-new-screen width, height, flags is FULLSCREEN

