"Market state in luxor strategy"
function luxormktstate(mafast::Float64, maslow::Float64)
  if isnan(mafast) || isnan(maslow)
    return :undefined
  end
  if mafast > maslow
    return :trendup
  end
  if mafast < maslow
    return :trenddown
  end
  # this would be rare
  return :undefined
end
# function luxormktstate(mafast::Float64, maslow::Float64)
#   # @match is overkill here but keeping it as a template
#   @match (mafast >= maslow) begin
#     true => :trendup
#     false => :trenddown
#     # reminds to always provide an unmatched option (no Nothing)
#     _ => :undefined
#   end
# end

"""
Target position and stop, limit prices (if any) for luxor strategy.
...
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.
"""
function luxorposlogic(mktstate::Symbol,
                       mktchgh::Float64, mktchgl::Float64, pthresh::Float64,
                       targetqty::Int64,
                       position_actual_mut::Vector{Int64})
  posact = position_actual_mut[1]

  @match (posact == 0, mktstate) begin
    # enter long position
    (true, :trendup) => (targetqty, [mktchgh + pthresh, mktchgh])
    # exit from long position
    (false, :trenddown), if posact > 0 end => (-posact, Array(Float64, 0))
    # enter short position
    (true, :trenddown) => (-targetqty, [mktchgl - pthresh, mktchgl])
    # exit from short position
    (false, :trendup), if posact < 0 end => (-posact, Array(Float64, 0))

    # partial order fill: continue advancing position (buy/sell more)
    (false, :trendup), if 0 < posact < targetqty end => (targetqty-posact, [mktchgh + pthresh, mktchgh])
    (false, :trenddown), if 0 > posact > -targetqty end => (-abs(targetqty-posact), [mktchgl - pthresh, mktchgl])

    # position over target: move back to targetqty
    (false, :trendup), if posact > targetqty end => (-(posact-targetqty), Array(Float64, 0))
    (false, :trenddown), if posact < -targetqty end => (abs(posact-targetqty), Array(Float64, 0))

    # no match among action-triggering contidions above
    othercase => (0, Array(Float64, 0))
  end
end

"Target signal for luxor strategy."
function luxortarget(s_ohlc::Input{(DateTime,Vector{Float64})},
                     ohlc_inds::Dict{Symbol,Int64},
                     position_actual_mut::Vector{Int64},
                     nsma_fast::Int64, nsma_slow::Int64,
                     pthreshold::Float64, targetqty::Int64)
  posact = position_actual_mut[1]
  targetqty > 0 || error("target quantity must be positive")

  # signals updating at each timestep (aka OHLC bar)
  buffpclose!(buff::Vector{Float64}, tohlc::(DateTime,Vector{Float64})) =
    sighistbuffer!(buff, tohlc[2][ohlc_inds[:close]])
  pcloseinit = s_ohlc.value[2][ohlc_inds[:close]]
  s_sma_fast = lift(mean,
                    foldl(buffpclose!, initbuff(nsma_fast, pcloseinit), s_ohlc),
                    typ=Float64)
  s_sma_slow = lift(mean,
                    foldl(buffpclose!, initbuff(nsma_slow, pcloseinit), s_ohlc),
                    typ=Float64)
  s_high = lift(s -> s[2][ohlc_inds[:high]], s_ohlc, typ=Float64)
  s_low = lift(s -> s[2][ohlc_inds[:low]], s_ohlc, typ=Float64)

  # market state signal
  s_mktstate = lift(luxormktstate, s_sma_fast, s_sma_slow, typ=Symbol)

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
  # targeting tuple to pass to the order processing function
  return s_target
end
