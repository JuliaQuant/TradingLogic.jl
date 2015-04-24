# TradingLogic

## Exported
---

### runtrading!{M}(blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool, s_ohlc::Input{TimeArray{Float64, 2, M}}, s_pnow::Signal{Float64}, position_initial::Int64, targetfun::Function, strategy_args...)
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


*source:*
[TradingLogic/src/TradingLogic.jl:57](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/TradingLogic.jl#L57)

## Internal
---

### query_orderstatus
Get order status by order ID string.
Returns `Symbol` in line with `Order`-type options for status-slot.


*source:*
[TradingLogic/src/exchange.jl:26](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L26)

---

### submit_ordercancel
Cancel order request. Returns `Bool` request result.

*source:*
[TradingLogic/src/exchange.jl:66](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L66)

---

### submit_ordernew
Submit new order. Returns order ID string or `FAIL`-string

*source:*
[TradingLogic/src/exchange.jl:47](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L47)

---

### emptyblotter()
Initialize empty blotter as an associative collection
`DateTime => (Qty::Int64, FillPrice::Float64)`


*source:*
[TradingLogic/src/types.jl:53](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/types.jl#L53)

---

### emptyorder()
Empty order: no quantity

*source:*
[TradingLogic/src/types.jl:27](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/types.jl#L27)

---

### fsigchange(prev, x)
Signal value change function to be used with foldl;
use with (Bool, signal_t=0) tuple as initial fold value


*source:*
[TradingLogic/src/sigutils.jl:9](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/sigutils.jl#L9)

---

### getorderposchg(orde::Order)
Signed position change in the Order object

*source:*
[TradingLogic/src/types.jl:39](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/types.jl#L39)

---

### goldencrossmktstate(mafast::Float64, maslow::Float64)
Market state in goldencross strategy

*source:*
[TradingLogic/src/strategies/goldencross.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/goldencross.jl#L2)

---

### goldencrossposlogic(mktstate::Symbol, targetqty::Int64, position_actual_mut::Array{Int64, 1})
Target position for goldencross strategy.
This simplest form involves only market orders, long-side enter.
...
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.


*source:*
[TradingLogic/src/strategies/goldencross.jl:19](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/goldencross.jl#L19)

---

### goldencrosstarget{M}(s_ohlc::Input{TimeArray{Float64, 2, M}}, position_actual_mut::Array{Int64, 1}, targetqty::Int64)
Target signal for goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:46](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/goldencross.jl#L46)

---

### goldencrosstarget{M}(s_ohlc::Input{TimeArray{Float64, 2, M}}, position_actual_mut::Array{Int64, 1}, targetqty::Int64, nsma_fast::Int64)
Target signal for goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:46](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/goldencross.jl#L46)

---

### goldencrosstarget{M}(s_ohlc::Input{TimeArray{Float64, 2, M}}, position_actual_mut::Array{Int64, 1}, targetqty::Int64, nsma_fast::Int64, nsma_slow::Int64)
Target signal for goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:46](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/goldencross.jl#L46)

---

### ispending(orde::Order)
Check if order status is `:pending`

*source:*
[TradingLogic/src/types.jl:30](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/types.jl#L30)

---

### luxormktstate(mafast::Float64, maslow::Float64)
Market state in luxor strategy

*source:*
[TradingLogic/src/strategies/luxor.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/luxor.jl#L2)

---

### luxorposlogic(mktstate::Symbol, mktchgh::Float64, mktchgl::Float64, pthresh::Float64, targetqty::Int64, position_actual_mut::Array{Int64, 1})
Target position and stop, limit prices (if any) for luxor strategy.
...
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.


*source:*
[TradingLogic/src/strategies/luxor.jl:27](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/luxor.jl#L27)

---

### luxortarget{M}(s_ohlc::Input{TimeArray{Float64, 2, M}}, position_actual_mut::Array{Int64, 1}, nsma_fast::Int64, nsma_slow::Int64, pthreshold::Float64, targetqty::Int64)
Target signal for luxor strategy.

*source:*
[TradingLogic/src/strategies/luxor.jl:57](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/strategies/luxor.jl#L57)

---

### neworderid(trig::ASCIIString)
Generate oder ID string for a new order

*source:*
[TradingLogic/src/orderhandl.jl:4](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/orderhandl.jl#L4)

---

### orderhandling!(targ::(Int64, Array{Float64, 1}), pnow::Float64, tnow::DateTime, position_actual_mut::Array{Int64, 1}, ordcurr::Order, blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool)
Order handling for backtesting and live trading.
Input:
- target `targ` as `(poschg::Int64, Vector[limitprice, stopprice]`;
- current/instantaneous price `pnow`
- current time `tnow`; for backtest, the time corresponding to `targ`
(i.e. the current OHLC step/bar time).
...
In-place modifies:
 `position_actual_mut` vector, `ordcurr` object,
 and `backtestblotter` associative collection.
Returns `Bool` system status.


*source:*
[TradingLogic/src/orderhandl.jl:78](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/orderhandl.jl#L78)

---

### plimitcheck(orde::Order, pnow::Float64)
Backtesting helper function: check if limit-price is reached

*source:*
[TradingLogic/src/exchange.jl:12](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L12)

---

### query_orderstatus(orde::Order, pnow::Float64)
Order status: backtesting version based on current price `pnow`

*source:*
[TradingLogic/src/exchange.jl:29](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L29)

---

### query_orderstatus(ordid::ASCIIString)
Order status: live version

*source:*
[TradingLogic/src/exchange.jl:41](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L41)

---

### schange{T}(s_inp::Signal{T})
Bool change signal, true when input signal changes

*source:*
[TradingLogic/src/sigutils.jl:16](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/sigutils.jl#L16)

---

### setcancelled!(orde::Order)
Change order status to `:cancelled`

*source:*
[TradingLogic/src/types.jl:33](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/types.jl#L33)

---

### submit_ordercancel(orde::Order)
Cancel pending order backtest version

*source:*
[TradingLogic/src/exchange.jl:69](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L69)

---

### submit_ordercancel(ordid::ASCIIString)
Cancel order live version: provide order ID string `ordid`

*source:*
[TradingLogic/src/exchange.jl:79](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L79)

---

### submit_ordernew(orde::Order, backtest::Bool)
New order submission: backtesting version.

*source:*
[TradingLogic/src/exchange.jl:50](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L50)

---

### submit_ordernew(orde::Order, position_actual::Int64)
New order submission: live version

*source:*
[TradingLogic/src/exchange.jl:59](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/exchange.jl#L59)

---

### targ2order!(orde::Order, targ::(Int64, Array{Float64, 1}), trig::ASCIIString, position_actual::Int64, backtest::Bool)
Prepare new order from `targ` (`(poschg::Int64, Vector[limitprice,stopprice]`)
and trigger-string `trig`.
Note: this function prepares limit and market orders for submission.
Stop-part of stoplimit orders is handled at the software level
in `orderhandling!` (even for live trading),
which calls `targ2order!` for limit order submission
if stop-price of stoplimit order is reached.
...
Overwrites `orde` and returns `Bool` request status.


*source:*
[TradingLogic/src/orderhandl.jl:20](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/orderhandl.jl#L20)

---

### tradeperf(blotter::Dict{DateTime, (Int64, Float64)}, metrics::Array{Symbol, 1})
Trade analysis for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Input `metrics` specifies what to calculate.
Returns: tuple ( DateTime (ordered) array , assoc. collection of perf metrics ).
Basic transaction info is also included (quantity, fill price).


*source:*
[TradingLogic/src/performance.jl:8](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/performance.jl#L8)

---

### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)})
Final profit/loss for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
faster verision (minimizing memory allocation) to be used
in e.g. parameter optimization workflow.
Returns: final profit/loss `Float64` scalar.


*source:*
[TradingLogic/src/performance.jl:56](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/performance.jl#L56)

---

### Order
Order type

*source:*
[TradingLogic/src/types.jl:5](https://github.com/JuliaQuant/TradingLogic.jl/tree/d905bdf2a4c1cb0cec0f39662e217ee2a479c9f8/src/types.jl#L5)

