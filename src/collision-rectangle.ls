
#
# Collision Rectangle
#
# Abstracts any collision rules we need
#

require! \std
require! \./units

{ Rectangle: Rect }    = require \./rectangle


# Collision Rectangle

export class CollisionRectangle

  (@top, @bottom, @left, @right) ->

  left-collision: (x, y, Δ) -> # Δ <= 0
    new Rect x + @left.left + Δ, y + @left.top, @left.w - Δ, @left.h

  right-collision: (x, y, Δ) -> # Δ >= 0
    new Rect x + @right.left, y + @right.top, @right.w + Δ, @right.h

  top-collision: (x, y, Δ) -> # Δ <= 0
    new Rect x + @top.left, y + @top.top + Δ, @top.w, @top.h - Δ

  bottom-collision: (x, y, Δ) -> # Δ >= 0
    new Rect x + @bottom.left, y + @bottom.top, @bottom.w, @bottom.h + Δ

  bounding-box:~ ->
    new Rect @left.left, @top.top, @left.w + @right.w, @top.h + @bottom.h

