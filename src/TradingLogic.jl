if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

using Reactive, Match, FinancialSeries, MarketTechnicals

module TradingLogic

using Docile

if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

using Reactive, Match, FinancialSeries, MarketTechnicals

# doc-strings
@document

export runtrading!

# general components
include("sigutils.jl")
include("types.jl")
include("errorhandl.jl")
include("exchange.jl")
include("orderhandl.jl")
include("performance.jl")

# specific trading strategy examples
include("strategies/goldencross.jl")
include("strategies/luxor.jl")

"""
Event-driven backtesting / live trading.

Input:

- `blotter` (could be initially empty) to write transactions to,
as an associative collection DateTime => (Qty::Int64, FillPrice::Float64)`;
- `backtest` is `Bool`, live trading performed if `false`;
- `s_ohlc` is `TimeArray`-valued signal;
- `targetfun` is the trading strategy function generating
`(poschg::Int64, Vector[limitprice, stopprice]` signal;
- additional arguments `...` to be passed to `targetfun`: these would
most commonly be trading strategy parameters.

In-place modifies `blotter` (adds transactions to it).

Returns `Bool`-signal for the overall status of the trading system
(false if problems are detected).
"""
function runtrading!{M}(blotter::Dict{DateTime,(Int64,Float64)},
                        backtest::Bool,
                        s_ohlc::Input{FinancialTimeSeries{Float64,2,M}},
                        s_pnow::Signal{Float64},
                        position_initial::Int64,
                        targetfun::Function, strategy_args...)
  # set initial position in a mutable object
  # NOTE: using closures to deal with a cyclic part of the signal graph
  # (for the actual position and current order updates) since
  # concurrent reactive programming is outside the scope of Reactive.jl
  position_actual_mut = [position_initial]

  # target signal: strategy-specific
  s_target = apply(targetfun,
                   tuple(s_ohlc, position_actual_mut, strategy_args...))

  # current time signal
  if backtest
    s_tnow = Reactive.lift(s -> timestamp(s)[end], DateTime, s_ohlc)
  else
    # system time when instantaneous price updates
    s_tnow = Reactive.lift(s -> unix2datetime(time()), DateTime, s_pnow)
  end

  # general order handling part
  order_current = emptyorder()
  s_overallstatus = lift(
    (tgt, pnow, tnow) -> orderhandling!(tgt, pnow, tnow,
                                        position_actual_mut,
                                        order_current,
                                        blotter, backtest),
    Bool,
    s_target, s_pnow, s_tnow)
  # error notification
  lift(tradesyserror, Bool, s_overallstatus)

  return s_overallstatus
end

end # module
