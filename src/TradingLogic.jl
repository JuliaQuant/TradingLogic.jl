if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

using Reactive, Match, TimeSeries

module TradingLogic

if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

using Reactive, Match, TimeSeries

export runtrading!, runbacktest, tradeperfcurr, tradeperf
export emptyblotter, printblotter, writeblotter

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
- `s_ohlc` is tuple-valued `(DateTime, Vector-ohlc)` signal;
- `ohlc_inds` provides index correspondence in Vector-ohlc;
- `s_pnow` is instantaneous price signal;
- `position_initial` corresponds to the first timestep;
- `targetfun` is the trading strategy function generating
`(poschg::Int64, Vector[limitprice, stopprice]` signal;
- additional arguments `...` to be passed to `targetfun`: these would
most commonly be trading strategy parameters.

In-place modifies `blotter` (adds transactions to it).

Returns tuple-signal with:

* the overall status of the trading system (false if problems are detected);
* current cumulative profit/loss since the signals were initiated (i.e. since
the beginning of the trading session).

See `orderhandling!` for the PnL details.
"""
function runtrading!(blotter::Dict{DateTime,(Int64,Float64)},
                     backtest::Bool,
                     s_ohlc::Input{(DateTime,Vector{Float64})},
                     ohlc_inds::Dict{Symbol,Int64},
                     s_pnow::Signal{Float64},
                     position_initial::Int64,
                     targetfun::Function, strategy_args...)
  # set initial position in a mutable object
  # NOTE: using closures to deal with a cyclic part of the signal graph
  # (for the actual position and current order updates) since
  # concurrent reactive programming is outside the scope of Reactive.jl
  position_actual_mut = [position_initial]

  # target signal: strategy-specific
  s_target = apply(targetfun, tuple(s_ohlc, ohlc_inds,
                                    position_actual_mut, strategy_args...))

  # current time signal from OHLC timestamp
  s_tnow = Reactive.lift(s -> s[1], s_ohlc, typ=DateTime)

  # general order handling part
  order_current = emptyorder()
  s_overallstatus = lift(
    (tgt, pnow, tnow) -> orderhandling!(tgt, pnow, tnow,
                                        position_actual_mut,
                                        order_current,
                                        blotter, backtest),
    s_target, s_pnow, s_tnow, typ=(Bool,Float64))
  # error notification
  lift(s -> tradesyserror(s[1]), s_overallstatus, typ=Bool)

  return s_overallstatus
end

"""
Backtesting run with OHLC timearray input.
Optionally writes output file with perfirmance metrics at each timestep.

Input:

- `ohlc_ta` timearray with OHLC data along with any other input values
provided at each timestep for the trading strategy use;
- `ohlc_inds` provides index correspondence for `ohlc_ta.colnames`;
**at least** the index of `:close` has to be specified.
- `fileout` filename with path or `nothing` to suppress output at each step;
- `dtformat_out` formats `DateTime` in `fileout`
(use e.g. `""` if not writing the output)
- `pfill` specifies price symbol in `ohlc_inds` to use for filling orders
at next-timestep after placement. Commonly set to open price.
**NOTE**: final performance metrics are using `:close` at the last timestep.
- `position_initial` corresponds to the first timestep;
- `targetfun` is the trading strategy function generating
`(poschg::Int64, Vector[limitprice, stopprice]` signal;
- additional arguments `...` to be passed to `targetfun`: these would
most commonly be trading strategy parameters.

Returns tuple with:

* `Float64` final cumulative profit/loss;
* `Float64` maximum return-based drawdown;
* transaction blotter as an associative collection.

Make sure to suppress output file when using within
optimization objective function to improve performance.
"""
function runbacktest{M}(ohlc_ta::TimeSeries.TimeArray{Float64,2,M},
                        ohlc_inds::Dict{Symbol,Int64},
                        fileout::Union(Nothing,String),
                        dtformat_out,
                        pfill::Symbol,
                        position_initial::Int64,
                        targetfun::Function, strategy_args...)
  # initialize signals
  s_ohlc = Input((Dates.DateTime(ohlc_ta.timestamp[1]),
                  vec(ohlc_ta.values[1,:])))
  nt = length(ohlc_ta)
  s_pnow = lift(s -> s[2][ohlc_inds[pfill]], s_ohlc, typ=Float64)
  blotter = emptyblotter()
  s_status = runtrading!(blotter, true, s_ohlc, ohlc_inds, s_pnow,
                         position_initial, targetfun, strategy_args...)
  s_perf = tradeperfcurr(s_status)

  # run the backtest
  if fileout == nothing
    writeout = false
  else
    # prepare file to write to at each timestep
    fout = open(fileout, "w")
    separator = ','; quotemark = '"'
    rescols = ["Timestamp", ohlc_ta.colnames, "CumPnL", "DDown"]
    printvecstring(fout, rescols, separator, quotemark)
    writeout = true
  end
  for i = 1:nt
    if i > 1
      # first timestep already initialized all the signals
      push!(s_ohlc, (Dates.DateTime(ohlc_ta.timestamp[i]),
                     vec(ohlc_ta.values[i,:])))
    end
    if writeout
      # print current step info: timestamp
      print(fout, quotemark)
      print(fout, Dates.format(s_ohlc.value[1], dtformat_out))
      print(fout, quotemark); print(fout, separator)
      # OHLC timearray columns
      print(fout, join(s_ohlc.value[2], separator))
      print(fout, separator)
      # trading performance
      pnlcum = s_status.value[2]
      ddownnow = pnlcum - s_perf.value[1]
      print(fout, pnlcum) #CumPnL
      print(fout, separator)
      print(fout, ddownnow) #DDown
      print(fout, '\n')
    end
  end
  if writeout
    close(fout)
  end

  # finalize perf. metrics at the last step close-price
  pfinal = s_ohlc.value[2][ohlc_inds[:close]]
  pnlfin = tradepnlfinal(blotter, pfinal)
  pnlmax = s_perf.value[1] > pnlfin ? s_perf.value[2] : pnlfin
  ddownfin = pnlfin - pnlmax
  ddownmax = s_perf.value[2] > ddownfin ? s_perf.value[2] : ddownfin

  # FinalPnL, MaxDDown, blotter
  return pnlfin, ddownmax, blotter
end

end # module
