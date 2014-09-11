
# Graphics Class

require! \std
require! \SDL


# Reference constants

kScreenWidth  = 640
kScreenHeight = 480


# Internal state

screen = SDL.set-video-mode(kScreenWidth, kScreenHeight, SDL.FULLSCREEN)


# Functions

export blit-surface = (source, src-rect, dest-rect) ->
  SDL.blit-surface source, src-rect, screen, dest-rect

export clear = ->
  screen.clear!

