TradingLogic
============

Exported
--------

.. function:: runtrading!{M}(blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool, s\_ohlc::Input{TimeArray{Float64, 2, M}}, s\_pnow::Signal{Float64}, position\_initial::Int64, targetfun::Function, strategy\_args...)


Event-driven backtesting / live trading. Input: - ``blotter`` (could be initially empty) to write transactions to, as an associative collection
DateTime => (Qty::Int64, FillPrice::Float64)\ ``; -``\ backtest\ ``is``\ Bool\ ``, live trading performed if``\ false\ ``; -``\ s\_ohlc\ ``is``\ TimeArray\ 
``-valued signal; -``\ targetfun\ ``is the trading strategy function generating``\ (poschg::Int64, Vector[limitprice, stopprice]\ ``signal; - additional 
arguments``...\ ``to be passed to``\ targetfun\ ``: these would most commonly be trading strategy parameters. ... In-place modifies``\ blotter\ ``(adds 
transactions to it). Returns``\ Bool\`-signal for the overall status of the trading system (false if problems are detected).

**source:**
`TradingLogic/src/TradingLogic.jl:54 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/TradingLogic.jl#L54>`__

Internal
--------

.. function:: query\_orderstatus

Get order status by order ID string. Returns ``Symbol`` in line with ``Order``-type options for status-slot.

**source:**
`TradingLogic/src/exchange.jl:26 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L26>`__

--------------

.. function:: submit\_ordercancel

Cancel order request. Returns ``Bool`` request result.

**source:**
`TradingLogic/src/exchange.jl:66 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L66>`__

--------------

.. function:: submit\_ordernew

Submit new order. Returns order ID string or ``FAIL``-string

**source:**
`TradingLogic/src/exchange.jl:47 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L47>`__

--------------

.. function:: emptyblotter()

Initialize empty blotter as an associative collection ``DateTime => (Qty::Int64, FillPrice::Float64)``

**source:**
`TradingLogic/src/types.jl:53 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/types.jl#L53>`__

--------------

.. function:: emptyorder()

Empty order: no quantity

**source:**
`TradingLogic/src/types.jl:27 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/types.jl#L27>`__

--------------

.. function:: fsigchange(prev, x)

Signal value change function to be used with foldl; use with (Bool, signal\_t=0) tuple as initial fold value

**source:**
`TradingLogic/src/sigutils.jl:9 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/sigutils.jl#L9>`__

--------------

.. function:: getorderposchg(orde::Order)

Signed position change in the Order object

**source:**
`TradingLogic/src/types.jl:39 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/types.jl#L39>`__

--------------

.. function:: goldencrossmktstate(mafast::Float64, maslow::Float64)

Market state in goldencross strategy

**source:**
`TradingLogic/src/strategies/goldencross.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/goldencross.jl#L2>`__

--------------

.. function:: goldencrossposlogic(mktstate::Symbol, targetqty::Int64, position\_actual\_mut::Array{Int64, 1})

Target position for goldencross strategy. This simplest form involves only market orders, long-side enter. ... Returns ``(poschg::Int64, 
Vector[limitprice, stopprice]``.

**source:**
`TradingLogic/src/strategies/goldencross.jl:19 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/goldencross.jl#L19>`__

--------------

.. function:: goldencrosstarget{M}(s\_ohlc::Input{TimeArray{Float64, 2, M}}, position\_actual\_mut::Array{Int64, 1}, targetqty::Int64)

Target signal for goldencross strategy.

**source:**
`TradingLogic/src/strategies/goldencross.jl:46 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/goldencross.jl#L46>`__

--------------

.. function:: goldencrosstarget{M}(s\_ohlc::Input{TimeArray{Float64, 2, M}}, position\_actual\_mut::Array{Int64, 1}, targetqty::Int64, nsma\_fast::Int64)

Target signal for goldencross strategy.

**source:**
`TradingLogic/src/strategies/goldencross.jl:46 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/goldencross.jl#L46>`__

--------------

.. function:: goldencrosstarget{M}(s\_ohlc::Input{TimeArray{Float64, 2, M}}, position\_actual\_mut::Array{Int64, 1}, targetqty::Int64, nsma\_fast::Int64, nsma\_slow::Int64)

Target signal for goldencross strategy.

**source:**
`TradingLogic/src/strategies/goldencross.jl:46 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/goldencross.jl#L46>`__

--------------

.. function:: ispending(orde::Order)

Check if order status is ``:pending``

**source:**
`TradingLogic/src/types.jl:30 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/types.jl#L30>`__

--------------

.. function:: luxormktstate(mafast::Float64, maslow::Float64)

Market state in luxor strategy

**source:**
`TradingLogic/src/strategies/luxor.jl:2 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/luxor.jl#L2>`__

--------------

.. function:: luxorposlogic(mktstate::Symbol, mktchgh::Float64, mktchgl::Float64, pthresh::Float64, targetqty::Int64, position\_actual\_mut::Array{Int64, 1})

Target position and stop, limit prices (if any) for luxor strategy. ...  Returns ``(poschg::Int64, Vector[limitprice, stopprice]``.

**source:**
`TradingLogic/src/strategies/luxor.jl:27 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/luxor.jl#L27>`__

--------------

.. function:: luxortarget{M}(s\_ohlc::Input{TimeArray{Float64, 2, M}}, position\_actual\_mut::Array{Int64, 1}, nsma\_fast::Int64, nsma\_slow::Int64, pthreshold::Float64, targetqty::Int64)

Target signal for luxor strategy.

**source:**
`TradingLogic/src/strategies/luxor.jl:57 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/strategies/luxor.jl#L57>`__

--------------

.. function:: neworderid(trig::ASCIIString)

Generate oder ID string for a new order

**source:**
`TradingLogic/src/orderhandl.jl:4 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/orderhandl.jl#L4>`__

--------------

.. function:: orderhandling!(targ::(Int64, Array{Float64, 1}), pnow::Float64, tnow::DateTime, position\_actual\_mut::Array{Int64, 1}, ordcurr::Order, blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool)

Order handling for backtesting and live trading. Input: - target
``targ`` as ``(poschg::Int64, Vector[limitprice, stopprice]``; -
current/instantaneous price ``pnow`` - current time ``tnow``; for
backtest, the time corresponding to ``targ`` (i.e. the current OHLC
step/bar time). ... In-place modifies: ``position_actual_mut`` vector,
``ordcurr`` object, and ``backtestblotter`` associative collection.
Returns ``Bool`` system status.

**source:**
`TradingLogic/src/orderhandl.jl:78 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/orderhandl.jl#L78>`__

--------------

.. function:: plimitcheck(orde::Order, pnow::Float64)

Backtesting helper function: check if limit-price is reached

**source:**
`TradingLogic/src/exchange.jl:12 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L12>`__

--------------

.. function:: query\_orderstatus(orde::Order, pnow::Float64)

Order status: backtesting version based on current price ``pnow``

**source:**
`TradingLogic/src/exchange.jl:29 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L29>`__

--------------

.. function:: query\_orderstatus(ordid::ASCIIString)

Order status: live version

**source:**
`TradingLogic/src/exchange.jl:41 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L41>`__

--------------

.. function:: schange{T}(s\_inp::Signal{T})

Bool change signal, true when input signal changes

**source:**
`TradingLogic/src/sigutils.jl:16 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/sigutils.jl#L16>`__

--------------

.. function:: setcancelled!(orde::Order)

Change order status to ``:cancelled``

**source:**
`TradingLogic/src/types.jl:33 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/types.jl#L33>`__

--------------

.. function:: submit\_ordercancel(orde::Order)

Cancel pending order backtest version

**source:**
`TradingLogic/src/exchange.jl:69 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L69>`__

--------------

.. function:: submit\_ordercancel(ordid::ASCIIString)

Cancel order live version: provide order ID string ``ordid``

**source:**
`TradingLogic/src/exchange.jl:79 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L79>`__

--------------

.. function:: submit\_ordernew(orde::Order, backtest::Bool)

New order submission: backtesting version.

**source:**
`TradingLogic/src/exchange.jl:50 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L50>`__

--------------

.. function:: submit\_ordernew(orde::Order, position\_actual::Int64)

New order submission: live version

**source:**
`TradingLogic/src/exchange.jl:59 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/exchange.jl#L59>`__

--------------

.. function:: targ2order!(orde::Order, targ::(Int64, Array{Float64, 1}), trig::ASCIIString, position\_actual::Int64, backtest::Bool)

Prepare new order from ``targ``
(``(poschg::Int64, Vector[limitprice,stopprice]``) and trigger-string
``trig``. Note: this function prepares limit and market orders for
submission. Stop-part of stoplimit orders is handled at the software
level in ``orderhandling!`` (even for live trading), which calls
``targ2order!`` for limit order submission if stop-price of stoplimit
order is reached. ... Overwrites ``orde`` and returns ``Bool`` request
status.

**source:**
`TradingLogic/src/orderhandl.jl:20 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/orderhandl.jl#L20>`__

--------------

.. function:: tradeperf(blotter::Dict{DateTime, (Int64, Float64)}, metrics::Array{Symbol, 1})

Trade analysis for ``blotter`` provided as
``DateTime => (Qty::Int64, FillPrice::Float64)`` assoc. collection.
Input ``metrics`` specifies what to calculate. Returns: tuple ( DateTime
(ordered) array , assoc. collection of perf metrics ).

**source:**
`TradingLogic/src/performance.jl:7 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/performance.jl#L7>`__

--------------

.. function:: tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)})

Final profit/loss for ``blotter`` provided as
``DateTime => (Qty::Int64, FillPrice::Float64)`` assoc. collection.
faster verision (minimizing memory allocation) to be used in e.g.
parameter optimization workflow. Returns: final profit/loss ``Float64``
scalar.

**source:**
`TradingLogic/src/performance.jl:43 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/performance.jl#L43>`__

--------------

.. function:: Order

Order type

**source:**
`TradingLogic/src/types.jl:5 <https://github.com/JuliaQuant/TradingLogic.jl/tree/5e6aaddd7f0d78c0f92adaedaa1e370f00ada71e/src/types.jl#L5>`__
