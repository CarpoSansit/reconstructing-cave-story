
# SDL Mock - Screen
#
# This module basically exists to house SDL.set-video-mode, however I've used
# a slighty different interface here. Normal SDL_setVideoMode takes a flag as
# it's last argument, which RCS uses with SDL_FULLSCREEN. Instead, we'll use
# this to pass a scaling factor to the output canvas, with the default being
# 1. If zero is passed, we'll do some CSS trickery to make the canvas pseudo-
# fullscreen inside the browser window, and maybe attempt to use the Fullscreen
# API is we can be bothered. Scaling the canvas is a good way to better see
# what you're doing without impacting the performance by quadrupling the number
# of pixels.
#
# Note that while most of the scaling implementation reaches inside the Surface
# and messes with it's canvas element, I think this logic still belongs here
# because a Surface shouldn't have any notion of whether it's being used as an
# 'output' (appended to the dom) or just a data structure.

require! \std

Surface = require \./surface


# Functions

# SDL::Screen::apply-scale-styles (CanvasElement, Number)
apply-scale-styles = (canvas, scale-factor) ->
  unless scale-factor is 0
    canvas.style.width = (canvas.width * scale-factor) + \px

# SDL::Screen::create-new-screen (Pixel, Pixel, Number)
create-new-screen = (w, h, scale-factor) ->
  screen = new Surface null, w, h
  document.body.append-child screen.canvas
  apply-scale-styles screen.canvas, scale-factor
  return screen

# Static wrapper to Screen::create-new-screen
export set-video-mode = (width, height, scale-factor = 1) ->
  create-new-screen width, height, scale-factor

