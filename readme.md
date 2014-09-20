
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

# Departure of style

There are a few scenarios where I've chosen a slightly different implementation
style to take advantage of some JS features. For example, where the C++ version
would have `getX()` or `getY()` containing a switch, I usually opt for dynamic
getter generation in the contructor, like this:

    Object.define-properties this, do
      x: get:
        switch ...
        ...

      y: get:
        switch ...
        ...

In C++ the compiler optimises having to resolve those switches every frame, but
in JS, this way we simplify the getters and provide JIT hints for efficiency.

