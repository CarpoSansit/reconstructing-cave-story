
# SDL delay
#
# Obviously if we implement it exactly the same way with sleep-timing, it will
# lock the browser so we need to break from interface parity with SDL here and
# make some allowance with requestAnimationFrame.


# Functions

raf = requestAnimationFrame



# Export

export do
  delay : (time, λ) ->
    raf λ



