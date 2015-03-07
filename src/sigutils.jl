## utilities for working with Reactive.jl signals
## NOTE: foldl and foldr in Reactive.jl are as in e.g. Haskell
##  https://wiki.haskell.org/Fold

"""
Signal value change function to be used with foldl;
use with (Bool, signal_t=0) tuple as initial fold value
"""
function fsigchange(prev, x)
  prev_val = prev[2]
  # x becomes previous value in the next call
  return (x != prev_val, x)
end

"Bool change signal, true when input signal changes"
function schange{T}(s_inp::Signal{T})
  return lift(s -> s[1], Bool,
              foldl(fsigchange, (false, s_inp.value), s_inp))
end
