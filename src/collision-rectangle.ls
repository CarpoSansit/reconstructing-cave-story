
#
# Collision Rectangle
#
# Abstracts any collision rules we need
#

require! \std
require! \./units

{ Rectangle: Rect }    = require \./rectangle


# Collision Rectangle Abstract Class

class CollisionRectangle

  bounding-box:~ ->
  top-collision: (x, y, Δ) -> # Δ <= 0
  left-collision: (x, y, Δ) -> # Δ <= 0
  right-collision: (x, y, Δ) -> # Δ >= 0
  bottom-collision: (x, y, Δ) -> # Δ >= 0


# Simple Version

export class SimpleCollisionRectangle extends CollisionRectangle

  kExtraOffset = 0.001   # Game units

  (@rect) ->

  collides-with: (rect) -> @rect.collides-with rect

  left-collision: (x, y, Δ) -> # Δ <= 0
    new Rect x + @rect.left + Δ, y + @rect.top, @rect.w - Δ, @rect.h

  right-collision: (x, y, Δ) -> # Δ >= 0
    new Rect x + @rect.left, y + @rect.top, @rect.w + Δ, @rect.h

  top-collision: (x, y, Δ) -> # Δ <= 0
    new Rect x + @rect.left, y + @rect.top + Δ, @rect.w, @rect.h - Δ

  bottom-collision: (x, y, Δ) -> # Δ >= 0
    new Rect x + @rect.left, y + @rect.top, @rect.w, @rect.h + Δ

  bounding-box:~ ->
    new Rect @rect.left - kExtraOffset, @rect.top - kExtraOffset,
      @rect.w + 2 * kExtraOffset, @rect.h + 2 * kExtraOffset


# Composite Version - seperate directional boxes

export class CompositeCollisionRectangle extends CollisionRectangle

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


