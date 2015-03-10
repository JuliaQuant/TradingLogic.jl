"Market state in luxor strategy"
function luxormktstate(mafast::Float64, maslow::Float64)
  # @match is overkill here but keeping it as a template
  @match (mafast >= maslow) begin
    true => :trendup
    false => :trenddown
    # reminds to always provide an unmatched option (no Nothing)
    _ => :undefined
  end
end

"""
Target position and stop, limit prices (if any) for luxor strategy.
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.
"""
function luxorposlogic(mktstate::Symbol,
                       mktchgh::Float64, mktchgl::Float64, pthresh::Float64,
                       targetqty::Int64,
                       position_actual_mut::Vector{Int64})
  posact = position_actual_mut[1]

  ### TODO: accommodate partial orders, include in tests
  ### e.g. if position > 0 but less than targetqty

  @match (posact == 0, mktstate) begin
    # enter long position
    (true, :trendup) => (targetqty, [mktchgh + pthresh, mktchgh])
    # exit from long position
    (false, :trenddown), if posact > 0 end => (-posact, Array(Float64, 0))
    # enter short position
    (true, :trenddown) => (-targetqty, [mktchgl - pthresh, mktchgl])
    # exit from short position
    (false, :trendup), if posact < 0 end => (-posact, Array(Float64, 0))
    # no match among action-triggering contidions above
    othercase => (0, Array(Float64, 0))
  end
end

"Target signal with `luxorposlogic` value for luxor strategy."
function luxortarget{M}(s_ohlc::Input{FinancialTimeSeries{Float64,2,M}},
                        position_actual_mut::Vector{Int64},
                        nsma_fast::Int64, nsma_slow::Int64,
                        pthreshold::Float64, targetqty::Int64)
  posact = position_actual_mut[1]

  # signals updating at each timestep (aka OHLC bar)
  s_close = lift(s -> values(s["Close"])[end], Float64, s_ohlc)
  s_high = lift(s -> values(s["High"])[end], Float64, s_ohlc)
  s_low = lift(s -> values(s["Low"])[end], Float64, s_ohlc)
  s_sma_fast = lift(s -> values(sma(s["Close"], nsma_fast))[end], Float64, s_ohlc)
  s_sma_slow = lift(s -> values(sma(s["Close"], nsma_slow))[end], Float64, s_ohlc)

  # market state signal
  s_mktstate = lift(luxormktstate, Symbol, s_sma_fast, s_sma_slow)

  # market state change Bool-signal
  s_mktchg = schange(s_mktstate)

  # signals updating only when market state changes
  s_mktchg_high = keepwhen(s_mktchg, s_high.value, s_high)
  s_mktchg_low = keepwhen(s_mktchg, s_low.value, s_low)

  # target position updates only when market state input changes
  s_target = lift((mks, h, l) -> luxorposlogic(mks, h, l,
                                               pthreshold, targetqty,
                                               position_actual_mut),
                  s_mktstate, s_mktchg_high, s_mktchg_low)
  # signal tuple to pass to the order processing function
  return s_target
end
