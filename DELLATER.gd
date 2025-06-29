extends Sprite2D





const DAMPING_RATE := 1.5          # the a part in e^{-a t}
const FREQUENCY := 10.0            # the w part in sin(w t)
const BOUNCE_AMPLITUDE := 200.0    # the A part 
const MIN_AMPLITUDE := 0.0         # stop bouncing if smaller than this



			# start bouncing from floor position other wise known as Y
