
# Reconstructing Cave Story

I try to follow along with Reconstructing Cave Story, except I try to do it in
Livescript with Canvas instead of SDL. I have no idea whether the browser is up
to it using C++-oriented game design techniques, but let's see.

# Tools used

- [livescript](http://livescript.net)
- browserify
- gulp.js
- connect
- livereload

# SDL Mock

I've had to recreate most of the SDL boundary encountered by C++ version of the
code with HTML5-appropriate versions with the API kept as close as is feasible
to C++ SDL. SDL interfaces emulated include:

- Init
- Input
- Rect
- Surface
- setVideoMode
- getTicks
- blitSurface
- loadBMP
- pollEvent
- delay (secretly requestAnimationFrame)

# Usage

To run it, go to project directory and run `gulp`. This will start a server on
`localhost:8080` (unless you change stuff). Visit this in your browser to play
the game. Changes to the source files will be reflected immediately in the
browser.

