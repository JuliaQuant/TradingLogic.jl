"Market state in goldencross strategy"
function goldencrossmktstate(mafast::Float64, maslow::Float64)
  if mafast > maslow
    return :trendup
  end
  if mafast < maslow
    return :trenddown
  end
  # this would be rare
  return :crosspoint
end

"""
Target position for goldencross strategy.
This simplest form involves only market orders, long-side enter.
...
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.
"""
function goldencrossposlogic(mktstate::Symbol,
                             targetqty::Int64,
                             position_actual_mut::Vector{Int64})
  posact = position_actual_mut[1]
  if posact < 0
    # should not happen: long-only strategy
    return (-posact, Array(Float64, 0))
  end
  if posact > targetqty && mktstate == :trendup
    # should not happen if only this strategy is active
    # sell excess (TODO do we need this? keeping for completeness only)
    return (-(posact-targetqty), Array(Float64, 0))
  end

  @match (posact < targetqty, mktstate) begin
    # enter long position: market buy
    (true, :trendup) => (targetqty - posact, Array(Float64, 0))
    # exit from long position: market sell
    (_, :trenddown), if posact > 0 end => (-posact, Array(Float64, 0))
    # position larger than target (should not normally happen)
    (false, :trenddown), if posact > 0 end => (-posact, Array(Float64, 0))
    # no match among action-triggering contidions above
    othercase => (0, Array(Float64, 0))
  end
end

"Target signal for goldencross strategy."
function goldencrosstarget{M}(s_ohlc::Input{TimeArray{Float64,2,M}},
                              position_actual_mut::Vector{Int64},
                              targetqty::Int64,
                              nsma_fast::Int64 = 50,
                              nsma_slow::Int64 = 200)
  posact = position_actual_mut[1]
  targetqty > 0 || error("target quantity must be positive")

  # signals updating at each timestep (aka OHLC bar)
  s_close = lift(s -> values(s["Close"])[end], Float64, s_ohlc)
  s_sma_fast = lift(s -> values(sma(s["Close"], nsma_fast))[end], Float64, s_ohlc)
  s_sma_slow = lift(s -> values(sma(s["Close"], nsma_slow))[end], Float64, s_ohlc)

  # market state signal
  s_mktstate = lift(goldencrossmktstate, Symbol, s_sma_fast, s_sma_slow)

  # target position updates only when market state input changes
  s_target = lift(mks -> goldencrossposlogic(mks,
                                             targetqty,
                                             position_actual_mut),
                  s_mktstate)
  # targeting tuple to pass to the order processing function
  return s_target
end
