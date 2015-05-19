TradingLogic
============

Exported
--------

--------------

 #### emptyblotter() `¶ <#method__emptyblotter.1>`__ Initialize empty
blotter as an associative collection
``DateTime => (Qty::Int64, FillPrice::Float64)``

*source:*
`TradingLogic/src/types.jl:53 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/types.jl#L53>`__

--------------

 #### tradeperfcurr(s\_status::Signal{(Bool, Float64)})
`¶ <#method__tradeperfcurr.1>`__ Selected performance metrics from
``runtrading!`` signal output.

Output tuple-signal components:

-  ``Float64`` cumulative maximum PnL;
-  ``Float64`` maximum drawdown over the entire trading session hisotry.

NOTE: Use this function only if needed, otherwise save resources; it is
not required for running the trading session.

*source:*
`TradingLogic/src/performance.jl:206 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/performance.jl#L206>`__

Internal
--------

--------------

 #### query\_orderstatus `¶ <#function__query_orderstatus.1>`__ Get
order status by order ID string. Returns ``Symbol`` in line with
``Order``-type options for status-slot.

*source:*
`TradingLogic/src/exchange.jl:26 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L26>`__

--------------

 #### submit\_ordercancel `¶ <#function__submit_ordercancel.1>`__ Cancel
order request. Returns ``Bool`` request result.

*source:*
`TradingLogic/src/exchange.jl:66 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L66>`__

--------------

 #### submit\_ordernew `¶ <#function__submit_ordernew.1>`__ Submit new
order. Returns order ID string or ``FAIL``-string

*source:*
`TradingLogic/src/exchange.jl:47 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L47>`__

--------------

 #### tradepnlfinal `¶ <#function__tradepnlfinal.1>`__ Final profit/loss
for ``blotter`` provided as
``DateTime => (Qty::Int64, FillPrice::Float64)`` assoc. collection.
Faster verision (minimizing memory allocation) to be used in e.g.
parameter optimization workflow.

Returns: final profit/loss ``Float64`` scalar.

*source:*
`TradingLogic/src/performance.jl:164 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/performance.jl#L164>`__

--------------

 #### emptyorder() `¶ <#method__emptyorder.1>`__ Empty order: no
quantity

*source:*
`TradingLogic/src/types.jl:27 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/types.jl#L27>`__

--------------

 #### fsigchange(prev, x) `¶ <#method__fsigchange.1>`__ Signal value
change function to be used with foldl; use with (Bool, signal\_t=0)
tuple as initial fold value

*source:*
`TradingLogic/src/sigutils.jl:9 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/sigutils.jl#L9>`__

--------------

 #### getorderposchg(orde::Order) `¶ <#method__getorderposchg.1>`__
Signed position change in the Order object

*source:*
`TradingLogic/src/types.jl:39 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/types.jl#L39>`__

--------------

 #### goldencrossmktstate(mafast::Float64, maslow::Float64)
`¶ <#method__goldencrossmktstate.1>`__ Market state in goldencross
strategy.

*source:*
`TradingLogic/src/strategies/goldencross.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/strategies/goldencross.jl#L2>`__

--------------

 #### initbuff(nbuff::Int64, xinit::Float64) `¶ <#method__initbuff.1>`__
Initialization of ``nbuff``-size float-elements buffer with NaNs and
last element ``xinit``.

*source:*
`TradingLogic/src/sigutils.jl:43 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/sigutils.jl#L43>`__

--------------

 #### ispending(orde::Order) `¶ <#method__ispending.1>`__ Check if order
status is ``:pending``

*source:*
`TradingLogic/src/types.jl:30 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/types.jl#L30>`__

--------------

 #### luxormktstate(mafast::Float64, maslow::Float64)
`¶ <#method__luxormktstate.1>`__ Market state in luxor strategy

*source:*
`TradingLogic/src/strategies/luxor.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/strategies/luxor.jl#L2>`__

--------------

 #### plimitcheck(orde::Order, pnow::Float64)
`¶ <#method__plimitcheck.1>`__ Backtesting helper function: check if
limit-price is reached

*source:*
`TradingLogic/src/exchange.jl:12 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L12>`__

--------------

 #### query\_orderstatus(orde::Order, pnow::Float64)
`¶ <#method__query_orderstatus.1>`__ Order status: backtesting version
based on current price ``pnow``

*source:*
`TradingLogic/src/exchange.jl:29 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L29>`__

--------------

 #### schange{T}(s\_inp::Signal{T}) `¶ <#method__schange.1>`__ Bool
change signal, true when input signal changes

*source:*
`TradingLogic/src/sigutils.jl:16 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/sigutils.jl#L16>`__

--------------

 #### setcancelled!(orde::Order) `¶ <#method__setcancelled.1>`__ Change
order status to ``:cancelled``

*source:*
`TradingLogic/src/types.jl:33 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/types.jl#L33>`__

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
`TradingLogic/src/sigutils.jl:33 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/sigutils.jl#L33>`__

--------------

 #### submit\_ordercancel(orde::Order)
`¶ <#method__submit_ordercancel.1>`__ Cancel pending order backtest
version

*source:*
`TradingLogic/src/exchange.jl:69 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L69>`__

--------------

 #### submit\_ordernew(orde::Order, backtest::Bool)
`¶ <#method__submit_ordernew.1>`__ New order submission: backtesting
version.

*source:*
`TradingLogic/src/exchange.jl:50 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/exchange.jl#L50>`__

--------------

 #### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__tradepnlfinal.1>`__ Based on blotter only, ending at the
last transaction timestamp.

*source:*
`TradingLogic/src/performance.jl:167 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/performance.jl#L167>`__

--------------

 #### vapblotter(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__vapblotter.1>`__ Amount ``Vector{Int64)`` and price
``Vector{Float64)`` from blotter in chronological order (returns vector
tuple).

*source:*
`TradingLogic/src/performance.jl:8 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/performance.jl#L8>`__

--------------

 #### vtblotter(blotter::Dict{DateTime, (Int64, Float64)})
`¶ <#method__vtblotter.1>`__ Ordered timestamps from blotter associative
collection.

*source:*
`TradingLogic/src/performance.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/performance.jl#L2>`__

--------------

 #### Order `¶ <#type__order.1>`__ Order type

*source:*
`TradingLogic/src/types.jl:5 <https://github.com/JuliaQuant/TradingLogic.jl/tree/b82f55754e2d6d3add6c7dc86edaf722dbea4c46/src/types.jl#L5>`__
