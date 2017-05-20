## utilities for working with Reactive.jl signals
## NOTE: foldp and foldr in Reactive.jl are as in e.g. Haskell
##  https://wiki.haskell.org/Fold

"""
Signal value change function to be used with foldp;
use with (Bool, signal_t=0) tuple as initial fold value
"""
function fsigchange(prev, x)
  prev_val = prev[2]
  # x becomes previous value in the next call
  return (x != prev_val, x)
end

"Bool change signal, true when input signal changes"
function schange{T}(s_inp::Signal{T})
  return map(s -> s[1],
             foldp(fsigchange, (false, s_inp.value), s_inp),
             typ = Bool)
end

"""
Buffer for storing previous signal values to be used with foldp when
indicators are calculated based on signal history.

**IMPORTANT**: Initial value supplied to `foldp` determines buffer window
size, i.e. how many past signal values are retained (rolling window
size). In the case of e.g. SMA that would be moving average window.
Specifying initial value may be tricky: see `test/signals.jl`.

In-place modifies `buffer` argument and returns updated one.
"""
function sighistbuffer!(buffer, valnew)
  push!(buffer, valnew) # add new value to the end of buffer
  shift!(buffer) # remove the earliest element
  return buffer
end

"""
Initialization of `nbuff`-size float-elements buffer
with NaNs and last element `xinit`.
"""
initbuff(nbuff::Int64, xinit::Float64) = [fill(NaN, nbuff-1); xinit]
