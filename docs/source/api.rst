TradingLogic
============

Exported
--------

--------------

 #### perf\_prom `¶ <#function__perf_prom.1>`__

Pessimistic return on margin ``marg``.

For ``pror = true`` returns pessimistic rate of return (can be thought
of as a more realistic profit factor).

Optional ``nbest_remove`` argument specifies how many best wins are
dropped (to increase PROM strictness).

**CAUTION** ``-Inf`` returned if ``nbest_remove`` exceeds the total
number of trades.

*source:*
`TradingLogic/src/performance.jl:292 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L292>`__

--------------

 #### runtrading! `¶ <#function__runtrading.1>`__ Event-driven
backtesting / live trading.

*source:*
`TradingLogic/src/TradingLogic.jl:36 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/TradingLogic.jl#L36>`__

--------------

 #### tradepnlfinal `¶ <#function__tradepnlfinal.1>`__

Final profit/loss for ``blotter`` provided as
``DateTime => (Qty::Int64, FillPrice::Float64)`` assoc. collection.
Faster verision (minimizing memory allocation) to be used in e.g.
parameter optimization workflow.

Returns: final profit/loss ``Float64`` scalar.

*source:*
`TradingLogic/src/performance.jl:171 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L171>`__

--------------

 #### emptyblotter() `¶ <#method__emptyblotter.1>`__

Initialize empty blotter as an associative collection
``DateTime => (Qty::Int64, FillPrice::Float64)``

*source:*
`TradingLogic/src/types.jl:59 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/types.jl#L59>`__

--------------

 #### perf\_prom(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__perf_prom.1>`__ From blotter using completed trades.

*source:*
`TradingLogic/src/performance.jl:305 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L305>`__

--------------

 #### perf\_prom(vtrpnl::Array{Float64, 1}) `¶ <#method__perf_prom.2>`__
From profit/loss vector of completed trades.

*source:*
`TradingLogic/src/performance.jl:325 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L325>`__

--------------

 #### printblotter(io::IO, blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__printblotter.1>`__ Print blotter transactions. Resembles
DataFrames.printtable.

*source:*
`TradingLogic/src/performance.jl:42 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L42>`__

--------------

 #### runbacktest{M}(ohlc\_ta::TimeArray{Float64, 2, M},
ohlc\_inds::Dict{Symbol, Int64}, fileout::Union(String, Nothing),
dtformat\_out, pfill::Symbol, position\_initial::Int64,
targetfun::Function, strategy\_args...) `¶ <#method__runbacktest.1>`__

Backtesting run with OHLC timearray input. Selected performance metrics
and equity curve in the output.

Input:

-  ``ohlc_ta`` timearray with OHLC data along with any other input
   values provided at each timestep for the trading strategy use;
-  ``ohlc_inds`` provides index correspondence for ``ohlc_ta.colnames``;
   **at least** the index of ``:close`` has to be specified.
-  ``fileout`` filename with path or ``nothing`` to suppress output at
   each step;
-  ``dtformat_out`` formats ``DateTime`` in ``fileout`` (use e.g. ``""``
   if not writing the output)
-  ``pfill`` specifies price symbol in ``ohlc_inds`` to use for filling
   orders at next-timestep after placement. Commonly set to open price.
   **NOTE**: final performance metrics are using ``:close`` at the last
   timestep.
-  ``position_initial`` corresponds to the first timestep;
-  ``targetfun`` is the trading strategy function generating
   ``(poschg::Int64, Vector[limitprice, stopprice]`` signal;
-  additional arguments ``...`` to be passed to ``targetfun``: these
   would most commonly be trading strategy parameters.

Returns tuple with:

-  ``Float64`` final cumulative profit/loss;
-  ``Float64`` maximum return-based drawdown;
-  transaction blotter as an associative collection;
-  ``Vector{Float64}`` equity curve (values for each timestep of
   ``ohlc_ta``).

Make sure to suppress output file when using within optimization
objective function to improve performance.

*source:*
`TradingLogic/src/TradingLogic.jl:175 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/TradingLogic.jl#L175>`__

--------------

 #### runtrading!(blotter::Dict{DateTime, (Int64, Float64)},
backtest::Bool, s\_ohlc::Input{(DateTime, Array{Float64, 1})},
ohlc\_inds::Dict{Symbol, Int64}, s\_pnow::Signal{Float64},
position\_initial::Int64, targetfun::Function, strategy\_args...)
`¶ <#method__runtrading.1>`__

Backtesting or real-time order submission with status output.

Input:

-  ``blotter`` (could be initially empty) to write transactions to, as
   an associative collection DateTime => (Qty::Int64,
   FillPrice::Float64)\`;
-  ``backtest`` is ``Bool``, live trading performed if ``false``;
-  ``s_ohlc`` is tuple-valued ``(DateTime, Vector-ohlc)`` signal;
-  ``ohlc_inds`` provides index correspondence in Vector-ohlc;
-  ``s_pnow`` is instantaneous price signal;
-  ``position_initial`` corresponds to the first timestep;
-  ``targetfun`` is the trading strategy function generating
   ``(poschg::Int64, Vector[limitprice, stopprice]`` signal;
-  additional arguments ``...`` to be passed to ``targetfun``: these
   would most commonly be trading strategy parameters.

In-place modifies ``blotter`` (adds transactions to it).

Returns tuple-signal with:

-  the overall status of the trading system (false if problems are
   detected);
-  current cumulative profit/loss since the signals were initiated (i.e.
   since the beginning of the trading session).

See ``orderhandling!`` for the PnL details.

*source:*
`TradingLogic/src/TradingLogic.jl:65 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/TradingLogic.jl#L65>`__

--------------

 #### runtrading!(blotter::Dict{DateTime, (Int64, Float64)},
s\_ohlc::Input{(DateTime, Array{Float64, 1})}, ohlc\_inds::Dict{Symbol,
Int64}, s\_pnow::Signal{Float64}, position\_initial::Int64,
targetfun::Function, strategy\_args...) `¶ <#method__runtrading.2>`__

Backtesting as far as order submission, final position and targets are
included in the output.

Input: ``backtest = true`` enforced. Error notification function is not
called (check the status-output signal tuple).

Return tuple components:

-  ``s_overallstatus`` tuple-signal;
-  current position single-element mutable array with ``Int64`` value;
-  current target signal per targeting function output.

This method is useful for feeding current step's targets to some
external code.

*source:*
`TradingLogic/src/TradingLogic.jl:115 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/TradingLogic.jl#L115>`__

--------------

 #### tradeperf(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__tradeperf.1>`__

Trade analysis for ``blotter`` provided as
``DateTime => (Qty::Int64, FillPrice::Float64)`` assoc. collection.
Input ``metrics`` specifies what to calculate (PnL included already -
others). Returns: tuple ( DateTime (ordered) array , assoc. collection
of perf metrics ). Basic transaction info is also included (quantity,
fill price).

**CAUTION**: PnL and drawdown are calculated here based on the
transaction blotter only, not the price history. Hence, price swing
effects while holding an open position are not showing up in the
results. Use ``orderhandling!`` output if performance metrics over the
whole price history are needed (as typically done when analyzing PnL and
drawdown).

*source:*
`TradingLogic/src/performance.jl:95 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L95>`__

--------------

 #### tradeperf(blotter::Dict{DateTime, (Int64, Float64)},
metrics::Array{Symbol, 1}) `¶ <#method__tradeperf.2>`__

Trade analysis for ``blotter`` provided as
``DateTime => (Qty::Int64, FillPrice::Float64)`` assoc. collection.
Input ``metrics`` specifies what to calculate (PnL included already -
others). Returns: tuple ( DateTime (ordered) array , assoc. collection
of perf metrics ). Basic transaction info is also included (quantity,
fill price).

**CAUTION**: PnL and drawdown are calculated here based on the
transaction blotter only, not the price history. Hence, price swing
effects while holding an open position are not showing up in the
results. Use ``orderhandling!`` output if performance metrics over the
whole price history are needed (as typically done when analyzing PnL and
drawdown).

*source:*
`TradingLogic/src/performance.jl:95 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L95>`__

--------------

 #### tradeperfcurr(s\_status::Signal{(Bool, Float64)})
`¶ <#method__tradeperfcurr.1>`__

Selected performance metrics from ``runtrading!`` signal output.

Output tuple-signal components:

-  ``Float64`` cumulative maximum PnL;
-  ``Float64`` maximum drawdown over the entire trading session hisotry.

NOTE: Use this function only if needed, otherwise save resources; it is
not required for running the trading session.

*source:*
`TradingLogic/src/performance.jl:213 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L213>`__

--------------

 #### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__tradepnlfinal.1>`__ Based on blotter only, ending at the
last transaction timestamp.

*source:*
`TradingLogic/src/performance.jl:174 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L174>`__

--------------

 #### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)},
pnow::Float64) `¶ <#method__tradepnlfinal.2>`__ Adding current price as
the last timestamp.

*source:*
`TradingLogic/src/performance.jl:177 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L177>`__

--------------

 #### vtradespnl(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__vtradespnl.1>`__

Selected metrics for completed trades out of transactions blotter.

Return tuple contains:

-  ``Vector{Float64}`` profit/loss for each completed trade;
-  ``Int64`` number of winning trades;
-  ``Float64`` average winning trade profit;
-  ``Int64`` number of loosing trades;
-  ``Float64`` average loosing trade loss.

*source:*
`TradingLogic/src/performance.jl:226 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L226>`__

--------------

 #### writeblotter(filename::String, blotter::Dict{DateTime, (Int64,
Float64)}) `¶ <#method__writeblotter.1>`__ Write blotter transactions to
file.

*source:*
`TradingLogic/src/performance.jl:72 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L72>`__

Internal
--------

--------------

 #### query\_orderstatus `¶ <#function__query_orderstatus.1>`__

Get order status by order ID string. Returns ``Symbol`` in line with
``Order``-type options for status-slot.

*source:*
`TradingLogic/src/exchange.jl:26 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L26>`__

--------------

 #### submit\_ordercancel `¶ <#function__submit_ordercancel.1>`__ Cancel
order request. Returns ``Bool`` request result.

*source:*
`TradingLogic/src/exchange.jl:66 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L66>`__

--------------

 #### submit\_ordernew `¶ <#function__submit_ordernew.1>`__ Submit new
order. Returns order ID string or ``FAIL``-string

*source:*
`TradingLogic/src/exchange.jl:47 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L47>`__

--------------

 #### apnlcum(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__apnlcum.1>`__ Cumulative position, profit/loss, last fill
price for blotter.

*source:*
`TradingLogic/src/performance.jl:139 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L139>`__

--------------

 #### emptyorder() `¶ <#method__emptyorder.1>`__ Empty order: no
quantity

*source:*
`TradingLogic/src/types.jl:27 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/types.jl#L27>`__

--------------

 #### fsigchange(prev, x) `¶ <#method__fsigchange.1>`__

Signal value change function to be used with foldl; use with (Bool,
signal\_t=0) tuple as initial fold value

*source:*
`TradingLogic/src/sigutils.jl:9 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/sigutils.jl#L9>`__

--------------

 #### getorderposchg(orde::Order) `¶ <#method__getorderposchg.1>`__
Signed position change in the Order object

*source:*
`TradingLogic/src/types.jl:39 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/types.jl#L39>`__

--------------

 #### goldencrossmktstate(mafast::Float64, maslow::Float64)
`¶ <#method__goldencrossmktstate.1>`__ Market state in goldencross
strategy.

*source:*
`TradingLogic/src/strategies/goldencross.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/goldencross.jl#L2>`__

--------------

 #### goldencrossposlogic(mktstate::Symbol, targetqty::Int64,
position\_actual\_mut::Array{Int64, 1})
`¶ <#method__goldencrossposlogic.1>`__

Target position for goldencross strategy. This simplest form involves
only market orders, long-side enter. ... Returns
``(poschg::Int64, Vector[limitprice, stopprice]``.

*source:*
`TradingLogic/src/strategies/goldencross.jl:22 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/goldencross.jl#L22>`__

--------------

 #### goldencrosstarget(s\_ohlc::Input{(DateTime, Array{Float64, 1})},
ohlc\_inds::Dict{Symbol, Int64}, position\_actual\_mut::Array{Int64, 1},
targetqty::Int64) `¶ <#method__goldencrosstarget.1>`__ Target signal for
goldencross strategy.

*source:*
`TradingLogic/src/strategies/goldencross.jl:49 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/goldencross.jl#L49>`__

--------------

 #### goldencrosstarget(s\_ohlc::Input{(DateTime, Array{Float64, 1})},
ohlc\_inds::Dict{Symbol, Int64}, position\_actual\_mut::Array{Int64, 1},
targetqty::Int64, nsma\_fast::Int64)
`¶ <#method__goldencrosstarget.2>`__ Target signal for goldencross
strategy.

*source:*
`TradingLogic/src/strategies/goldencross.jl:49 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/goldencross.jl#L49>`__

--------------

 #### goldencrosstarget(s\_ohlc::Input{(DateTime, Array{Float64, 1})},
ohlc\_inds::Dict{Symbol, Int64}, position\_actual\_mut::Array{Int64, 1},
targetqty::Int64, nsma\_fast::Int64, nsma\_slow::Int64)
`¶ <#method__goldencrosstarget.3>`__ Target signal for goldencross
strategy.

*source:*
`TradingLogic/src/strategies/goldencross.jl:49 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/goldencross.jl#L49>`__

--------------

 #### initbuff(nbuff::Int64, xinit::Float64) `¶ <#method__initbuff.1>`__

Initialization of ``nbuff``-size float-elements buffer with NaNs and
last element ``xinit``.

*source:*
`TradingLogic/src/sigutils.jl:43 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/sigutils.jl#L43>`__

--------------

 #### ispending(orde::Order) `¶ <#method__ispending.1>`__ Check if order
status is ``:pending``

*source:*
`TradingLogic/src/types.jl:30 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/types.jl#L30>`__

--------------

 #### luxormktstate(mafast::Float64, maslow::Float64)
`¶ <#method__luxormktstate.1>`__ Market state in luxor strategy

*source:*
`TradingLogic/src/strategies/luxor.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/luxor.jl#L2>`__

--------------

 #### luxorposlogic(mktstate::Symbol, mktchgh::Float64,
mktchgl::Float64, pthresh::Float64, targetqty::Int64,
position\_actual\_mut::Array{Int64, 1}) `¶ <#method__luxorposlogic.1>`__

Target position and stop, limit prices (if any) for luxor strategy. ...
Returns ``(poschg::Int64, Vector[limitprice, stopprice]``.

*source:*
`TradingLogic/src/strategies/luxor.jl:30 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/luxor.jl#L30>`__

--------------

 #### luxortarget(s\_ohlc::Input{(DateTime, Array{Float64, 1})},
ohlc\_inds::Dict{Symbol, Int64}, position\_actual\_mut::Array{Int64, 1},
nsma\_fast::Int64, nsma\_slow::Int64, pthreshold::Float64,
targetqty::Int64) `¶ <#method__luxortarget.1>`__ Target signal for luxor
strategy.

*source:*
`TradingLogic/src/strategies/luxor.jl:60 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/strategies/luxor.jl#L60>`__

--------------

 #### neworderid(trig::ASCIIString) `¶ <#method__neworderid.1>`__
Generate oder ID string for a new order

*source:*
`TradingLogic/src/orderhandl.jl:4 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/orderhandl.jl#L4>`__

--------------

 #### orderhandling!(targ::(Int64, Array{Float64, 1}), pnow::Float64,
tnow::DateTime, position\_actual\_mut::Array{Int64, 1}, ordcurr::Order,
blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool)
`¶ <#method__orderhandling.1>`__

Order handling for backtesting and live trading. Input: - target
``targ`` as ``(poschg::Int64, Vector[limitprice, stopprice]``; -
current/instantaneous price ``pnow`` - current time ``tnow``; for
backtest, the time corresponding to ``targ`` (i.e. the current OHLC
step/bar time).

In-place modifies:

-  ``position_actual_mut`` vector;
-  ``ordcurr`` object;
-  ``backtestblotter`` associative collection.

Returns tuple with:

-  ``Bool`` system status;
-  ``Float64`` current cumulative profit/loss.

NOTE: As opposed to ``tradeperf`` function, here total PnL is updated at
each price change time-point.

*source:*
`TradingLogic/src/orderhandl.jl:87 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/orderhandl.jl#L87>`__

--------------

 #### perf\_pror\_auxil(ppos::Float64, pneg::Float64)
`¶ <#method__perf_pror_auxil.1>`__ Pessimistic rate of return with
extreme case handling.

*source:*
`TradingLogic/src/performance.jl:295 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L295>`__

--------------

 #### plimitcheck(orde::Order, pnow::Float64)
`¶ <#method__plimitcheck.1>`__ Backtesting helper function: check if
limit-price is reached

*source:*
`TradingLogic/src/exchange.jl:12 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L12>`__

--------------

 #### printvecstring(io, vstring::Array{T, 1}, separator::Char,
quotemark::Char) `¶ <#method__printvecstring.1>`__ Print a text line
from string vector.

*source:*
`TradingLogic/src/performance.jl:25 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L25>`__

--------------

 #### query\_orderstatus(orde::Order, pnow::Float64)
`¶ <#method__query_orderstatus.1>`__ Order status: backtesting version
based on current price ``pnow``

*source:*
`TradingLogic/src/exchange.jl:29 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L29>`__

--------------

 #### query\_orderstatus(ordid::ASCIIString)
`¶ <#method__query_orderstatus.2>`__ Order status: live version

*source:*
`TradingLogic/src/exchange.jl:41 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L41>`__

--------------

 #### runbacktesttarg{M}(ohlc\_ta::TimeArray{Float64, 2, M},
ohlc\_inds::Dict{Symbol, Int64}, fileout::Union(String, Nothing),
dtformat\_out, pfill::Symbol, position\_initial::Int64,
targetfun::Function, strategy\_args...)
`¶ <#method__runbacktesttarg.1>`__

Similar to ``runbacktest`` but instead of performance metrics, current
position and targets from the latest step are included in the output.

Input: same as ``runbacktest``.

Return tuple components:

-  transaction blotter as an associative collection;
-  ``Int64`` position as of the latest timestep;
-  ``Targ`` targeting tuple as of the latest timestep.

This function is useful to run through a recent historical period and
determine the latest timestep actions.

*source:*
`TradingLogic/src/TradingLogic.jl:259 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/TradingLogic.jl#L259>`__

--------------

 #### schange{T}(s\_inp::Signal{T}) `¶ <#method__schange.1>`__ Bool
change signal, true when input signal changes

*source:*
`TradingLogic/src/sigutils.jl:16 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/sigutils.jl#L16>`__

--------------

 #### setcancelled!(orde::Order) `¶ <#method__setcancelled.1>`__ Change
order status to ``:cancelled``

*source:*
`TradingLogic/src/types.jl:33 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/types.jl#L33>`__

--------------

 #### sighistbuffer!(buffer, valnew) `¶ <#method__sighistbuffer.1>`__

Buffer for storing previous signal values to be used with foldl when
indicators are calculated based on signal history.

**IMPORTANT**: Initial value supplied to ``foldl`` determines buffer
window size, i.e. how many past signal values are retained (rolling
window size). In the case of e.g. SMA that would be moving average
window. Specifying initial value may be tricky: see ``test/signals.jl``.

In-place modifies ``buffer`` argument and returns updated one.

*source:*
`TradingLogic/src/sigutils.jl:33 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/sigutils.jl#L33>`__

--------------

 #### submit\_ordercancel(orde::Order)
`¶ <#method__submit_ordercancel.1>`__ Cancel pending order backtest
version

*source:*
`TradingLogic/src/exchange.jl:69 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L69>`__

--------------

 #### submit\_ordercancel(ordid::ASCIIString)
`¶ <#method__submit_ordercancel.2>`__ Cancel order live version: provide
order ID string ``ordid``

*source:*
`TradingLogic/src/exchange.jl:79 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L79>`__

--------------

 #### submit\_ordernew(orde::Order, backtest::Bool)
`¶ <#method__submit_ordernew.1>`__ New order submission: backtesting
version.

*source:*
`TradingLogic/src/exchange.jl:50 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L50>`__

--------------

 #### submit\_ordernew(orde::Order, position\_actual::Int64)
`¶ <#method__submit_ordernew.2>`__ New order submission: live version

*source:*
`TradingLogic/src/exchange.jl:59 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/exchange.jl#L59>`__

--------------

 #### targ2order!(orde::Order, targ::(Int64, Array{Float64, 1}),
trig::ASCIIString, position\_actual::Int64, backtest::Bool)
`¶ <#method__targ2order.1>`__

Prepare new order from ``targ``
(``(poschg::Int64, Vector[limitprice,stopprice]``) and trigger-string
``trig``. Note: this function prepares limit and market orders for
submission. Stop-part of stoplimit orders is handled at the software
level in ``orderhandling!`` (even for live trading), which calls
``targ2order!`` for limit order submission if stop-price of stoplimit
order is reached. ... Overwrites ``orde`` and returns ``Bool`` request
status.

*source:*
`TradingLogic/src/orderhandl.jl:20 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/orderhandl.jl#L20>`__

--------------

 #### tradeperffold(perfprev::(Float64, Float64), statusnow::(Bool,
Float64)) `¶ <#method__tradeperffold.1>`__ Performance metrics helper
function for use in foldl.

*source:*
`TradingLogic/src/performance.jl:186 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L186>`__

--------------

 #### vapblotter(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__vapblotter.1>`__

Amount ``Vector{Int64)`` and price ``Vector{Float64)`` from blotter in
chronological order (returns vector tuple).

*source:*
`TradingLogic/src/performance.jl:10 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L10>`__

--------------

 #### vtblotter(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__vtblotter.1>`__ Ordered timestamps from blotter associative
collection.

*source:*
`TradingLogic/src/performance.jl:4 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/performance.jl#L4>`__

--------------

 #### Order `¶ <#type__order.1>`__ Order type

*source:*
`TradingLogic/src/types.jl:5 <https://github.com/JuliaQuant/TradingLogic.jl/tree/ae57b49a159ca81440cca4bb1c597fb7312b4258/src/types.jl#L5>`__
