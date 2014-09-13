
# Graphics Class

require! \std
require! \SDL

Game = require \./game


# Reference constants

kScreenWidth  = 640
kScreenHeight = 480


# Internal state

screen = SDL.set-video-mode kScreenWidth, kScreenHeight, SDL.FULLSCREEN
spritesheets = {}


# Functions

export load-image = (path) ->
  if not spritesheets[path]?
    std.log 'Graphics::loadImage - no surface for', path, '- creating new surface'
    spritesheets[path] = new SDL.Surface path

    if Game.kDebugMode
      document.body.append-child spritesheets[path].canvas

  else
    std.log 'Graphics::loadImage - reusing available surface for', path
  return spritesheets[path]

export blit-surface = (source, src-rect, dest-rect) ->
  SDL.blit-surface source, src-rect, screen, dest-rect

export clear = ->
  screen.clear!

