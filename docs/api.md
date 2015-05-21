# TradingLogic

## Exported

---

<a id="method__emptyblotter.1" class="lexicon_definition"></a>
#### emptyblotter() [¶](#method__emptyblotter.1)
Initialize empty blotter as an associative collection
`DateTime => (Qty::Int64, FillPrice::Float64)`


*source:*
[TradingLogic/src/types.jl:53](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/types.jl#L53)

---

<a id="method__printblotter.1" class="lexicon_definition"></a>
#### printblotter(io::IO, blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__printblotter.1)
Print blotter transactions. Resembles DataFrames.printtable.

*source:*
[TradingLogic/src/performance.jl:40](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L40)

---

<a id="method__runbacktest.1" class="lexicon_definition"></a>
#### runbacktest{M}(ohlc_ta::TimeArray{Float64, 2, M}, ohlc_inds::Dict{Symbol, Int64}, fileout::Union(Nothing, String), dtformat_out, pfill::Symbol, position_initial::Int64, targetfun::Function, strategy_args...) [¶](#method__runbacktest.1)
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


*source:*
[TradingLogic/src/TradingLogic.jl:126](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/TradingLogic.jl#L126)

---

<a id="method__runtrading.1" class="lexicon_definition"></a>
#### runtrading!(blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool, s_ohlc::Input{(DateTime, Array{Float64, 1})}, ohlc_inds::Dict{Symbol, Int64}, s_pnow::Signal{Float64}, position_initial::Int64, targetfun::Function, strategy_args...) [¶](#method__runtrading.1)
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


*source:*
[TradingLogic/src/TradingLogic.jl:61](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/TradingLogic.jl#L61)

---

<a id="method__tradeperf.1" class="lexicon_definition"></a>
#### tradeperf(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__tradeperf.1)
Trade analysis for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Input `metrics` specifies what to calculate (PnL included already - others).
Returns: tuple ( DateTime (ordered) array , assoc. collection of perf metrics ).
Basic transaction info is also included (quantity, fill price).

**CAUTION**: PnL and drawdown are calculated here based on the transaction blotter
only, not the price history. Hence, price swing effects while holding
an open position are not showing up in the results. Use `orderhandling!`
output if performance metrics over the whole price history are needed
(as typically done when analyzing PnL and drawdown).


*source:*
[TradingLogic/src/performance.jl:93](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L93)

---

<a id="method__tradeperf.2" class="lexicon_definition"></a>
#### tradeperf(blotter::Dict{DateTime, (Int64, Float64)}, metrics::Array{Symbol, 1}) [¶](#method__tradeperf.2)
Trade analysis for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Input `metrics` specifies what to calculate (PnL included already - others).
Returns: tuple ( DateTime (ordered) array , assoc. collection of perf metrics ).
Basic transaction info is also included (quantity, fill price).

**CAUTION**: PnL and drawdown are calculated here based on the transaction blotter
only, not the price history. Hence, price swing effects while holding
an open position are not showing up in the results. Use `orderhandling!`
output if performance metrics over the whole price history are needed
(as typically done when analyzing PnL and drawdown).


*source:*
[TradingLogic/src/performance.jl:93](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L93)

---

<a id="method__tradeperfcurr.1" class="lexicon_definition"></a>
#### tradeperfcurr(s_status::Signal{(Bool, Float64)}) [¶](#method__tradeperfcurr.1)
Selected performance metrics from `runtrading!` signal output.

Output tuple-signal components:

* `Float64` cumulative maximum PnL;
* `Float64` maximum drawdown over the entire trading session hisotry.

NOTE: Use this function only if needed, otherwise save resources; it is
not required for running the trading session.


*source:*
[TradingLogic/src/performance.jl:211](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L211)

---

<a id="method__writeblotter.1" class="lexicon_definition"></a>
#### writeblotter(filename::String, blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__writeblotter.1)
Write blotter transactions to file.

*source:*
[TradingLogic/src/performance.jl:70](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L70)

## Internal

---

<a id="function__query_orderstatus.1" class="lexicon_definition"></a>
#### query_orderstatus [¶](#function__query_orderstatus.1)
Get order status by order ID string.
Returns `Symbol` in line with `Order`-type options for status-slot.


*source:*
[TradingLogic/src/exchange.jl:26](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L26)

---

<a id="function__submit_ordercancel.1" class="lexicon_definition"></a>
#### submit_ordercancel [¶](#function__submit_ordercancel.1)
Cancel order request. Returns `Bool` request result.

*source:*
[TradingLogic/src/exchange.jl:66](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L66)

---

<a id="function__submit_ordernew.1" class="lexicon_definition"></a>
#### submit_ordernew [¶](#function__submit_ordernew.1)
Submit new order. Returns order ID string or `FAIL`-string

*source:*
[TradingLogic/src/exchange.jl:47](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L47)

---

<a id="function__tradepnlfinal.1" class="lexicon_definition"></a>
#### tradepnlfinal [¶](#function__tradepnlfinal.1)
Final profit/loss for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Faster verision (minimizing memory allocation) to be used
in e.g. parameter optimization workflow.

Returns: final profit/loss `Float64` scalar.


*source:*
[TradingLogic/src/performance.jl:169](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L169)

---

<a id="method__apnlcum.1" class="lexicon_definition"></a>
#### apnlcum(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__apnlcum.1)
Cumulative position, profit/loss, last fill price for blotter.

*source:*
[TradingLogic/src/performance.jl:137](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L137)

---

<a id="method__emptyorder.1" class="lexicon_definition"></a>
#### emptyorder() [¶](#method__emptyorder.1)
Empty order: no quantity

*source:*
[TradingLogic/src/types.jl:27](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/types.jl#L27)

---

<a id="method__fsigchange.1" class="lexicon_definition"></a>
#### fsigchange(prev, x) [¶](#method__fsigchange.1)
Signal value change function to be used with foldl;
use with (Bool, signal_t=0) tuple as initial fold value


*source:*
[TradingLogic/src/sigutils.jl:9](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/sigutils.jl#L9)

---

<a id="method__getorderposchg.1" class="lexicon_definition"></a>
#### getorderposchg(orde::Order) [¶](#method__getorderposchg.1)
Signed position change in the Order object

*source:*
[TradingLogic/src/types.jl:39](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/types.jl#L39)

---

<a id="method__goldencrossmktstate.1" class="lexicon_definition"></a>
#### goldencrossmktstate(mafast::Float64, maslow::Float64) [¶](#method__goldencrossmktstate.1)
Market state in goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/goldencross.jl#L2)

---

<a id="method__goldencrossposlogic.1" class="lexicon_definition"></a>
#### goldencrossposlogic(mktstate::Symbol, targetqty::Int64, position_actual_mut::Array{Int64, 1}) [¶](#method__goldencrossposlogic.1)
Target position for goldencross strategy.
This simplest form involves only market orders, long-side enter.
...
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.


*source:*
[TradingLogic/src/strategies/goldencross.jl:22](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/goldencross.jl#L22)

---

<a id="method__goldencrosstarget.1" class="lexicon_definition"></a>
#### goldencrosstarget(s_ohlc::Input{(DateTime, Array{Float64, 1})}, ohlc_inds::Dict{Symbol, Int64}, position_actual_mut::Array{Int64, 1}, targetqty::Int64) [¶](#method__goldencrosstarget.1)
Target signal for goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:49](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/goldencross.jl#L49)

---

<a id="method__goldencrosstarget.2" class="lexicon_definition"></a>
#### goldencrosstarget(s_ohlc::Input{(DateTime, Array{Float64, 1})}, ohlc_inds::Dict{Symbol, Int64}, position_actual_mut::Array{Int64, 1}, targetqty::Int64, nsma_fast::Int64) [¶](#method__goldencrosstarget.2)
Target signal for goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:49](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/goldencross.jl#L49)

---

<a id="method__goldencrosstarget.3" class="lexicon_definition"></a>
#### goldencrosstarget(s_ohlc::Input{(DateTime, Array{Float64, 1})}, ohlc_inds::Dict{Symbol, Int64}, position_actual_mut::Array{Int64, 1}, targetqty::Int64, nsma_fast::Int64, nsma_slow::Int64) [¶](#method__goldencrosstarget.3)
Target signal for goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:49](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/goldencross.jl#L49)

---

<a id="method__initbuff.1" class="lexicon_definition"></a>
#### initbuff(nbuff::Int64, xinit::Float64) [¶](#method__initbuff.1)
Initialization of `nbuff`-size float-elements buffer
with NaNs and last element `xinit`.


*source:*
[TradingLogic/src/sigutils.jl:43](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/sigutils.jl#L43)

---

<a id="method__ispending.1" class="lexicon_definition"></a>
#### ispending(orde::Order) [¶](#method__ispending.1)
Check if order status is `:pending`

*source:*
[TradingLogic/src/types.jl:30](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/types.jl#L30)

---

<a id="method__luxormktstate.1" class="lexicon_definition"></a>
#### luxormktstate(mafast::Float64, maslow::Float64) [¶](#method__luxormktstate.1)
Market state in luxor strategy

*source:*
[TradingLogic/src/strategies/luxor.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/luxor.jl#L2)

---

<a id="method__luxorposlogic.1" class="lexicon_definition"></a>
#### luxorposlogic(mktstate::Symbol, mktchgh::Float64, mktchgl::Float64, pthresh::Float64, targetqty::Int64, position_actual_mut::Array{Int64, 1}) [¶](#method__luxorposlogic.1)
Target position and stop, limit prices (if any) for luxor strategy.
...
Returns `(poschg::Int64, Vector[limitprice, stopprice]`.


*source:*
[TradingLogic/src/strategies/luxor.jl:30](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/luxor.jl#L30)

---

<a id="method__luxortarget.1" class="lexicon_definition"></a>
#### luxortarget(s_ohlc::Input{(DateTime, Array{Float64, 1})}, ohlc_inds::Dict{Symbol, Int64}, position_actual_mut::Array{Int64, 1}, nsma_fast::Int64, nsma_slow::Int64, pthreshold::Float64, targetqty::Int64) [¶](#method__luxortarget.1)
Target signal for luxor strategy.

*source:*
[TradingLogic/src/strategies/luxor.jl:60](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/strategies/luxor.jl#L60)

---

<a id="method__neworderid.1" class="lexicon_definition"></a>
#### neworderid(trig::ASCIIString) [¶](#method__neworderid.1)
Generate oder ID string for a new order

*source:*
[TradingLogic/src/orderhandl.jl:4](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/orderhandl.jl#L4)

---

<a id="method__orderhandling.1" class="lexicon_definition"></a>
#### orderhandling!(targ::(Int64, Array{Float64, 1}), pnow::Float64, tnow::DateTime, position_actual_mut::Array{Int64, 1}, ordcurr::Order, blotter::Dict{DateTime, (Int64, Float64)}, backtest::Bool) [¶](#method__orderhandling.1)
Order handling for backtesting and live trading.
Input:
- target `targ` as `(poschg::Int64, Vector[limitprice, stopprice]`;
- current/instantaneous price `pnow`
- current time `tnow`; for backtest, the time corresponding to `targ`
(i.e. the current OHLC step/bar time).

In-place modifies:

* `position_actual_mut` vector;
* `ordcurr` object;
* `backtestblotter` associative collection.

Returns tuple with:

* `Bool` system status;
* `Float64` current cumulative profit/loss.

NOTE: As opposed to `tradeperf` function, here total PnL is updated
at each price change time-point.


*source:*
[TradingLogic/src/orderhandl.jl:87](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/orderhandl.jl#L87)

---

<a id="method__plimitcheck.1" class="lexicon_definition"></a>
#### plimitcheck(orde::Order, pnow::Float64) [¶](#method__plimitcheck.1)
Backtesting helper function: check if limit-price is reached

*source:*
[TradingLogic/src/exchange.jl:12](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L12)

---

<a id="method__printvecstring.1" class="lexicon_definition"></a>
#### printvecstring(io, vstring::Array{T, 1}, separator::Char, quotemark::Char) [¶](#method__printvecstring.1)
Print a text line from string vector.

*source:*
[TradingLogic/src/performance.jl:23](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L23)

---

<a id="method__query_orderstatus.1" class="lexicon_definition"></a>
#### query_orderstatus(orde::Order, pnow::Float64) [¶](#method__query_orderstatus.1)
Order status: backtesting version based on current price `pnow`

*source:*
[TradingLogic/src/exchange.jl:29](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L29)

---

<a id="method__query_orderstatus.2" class="lexicon_definition"></a>
#### query_orderstatus(ordid::ASCIIString) [¶](#method__query_orderstatus.2)
Order status: live version

*source:*
[TradingLogic/src/exchange.jl:41](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L41)

---

<a id="method__schange.1" class="lexicon_definition"></a>
#### schange{T}(s_inp::Signal{T}) [¶](#method__schange.1)
Bool change signal, true when input signal changes

*source:*
[TradingLogic/src/sigutils.jl:16](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/sigutils.jl#L16)

---

<a id="method__setcancelled.1" class="lexicon_definition"></a>
#### setcancelled!(orde::Order) [¶](#method__setcancelled.1)
Change order status to `:cancelled`

*source:*
[TradingLogic/src/types.jl:33](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/types.jl#L33)

---

<a id="method__sighistbuffer.1" class="lexicon_definition"></a>
#### sighistbuffer!(buffer, valnew) [¶](#method__sighistbuffer.1)
Buffer for storing previous signal values to be used with foldl when
indicators are calculated based on signal history.

**IMPORTANT**: Initial value supplied to `foldl` determines buffer window
size, i.e. how many past signal values are retained (rolling window
size). In the case of e.g. SMA that would be moving average window.
Specifying initial value may be tricky: see `test/signals.jl`.

In-place modifies `buffer` argument and returns updated one.


*source:*
[TradingLogic/src/sigutils.jl:33](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/sigutils.jl#L33)

---

<a id="method__submit_ordercancel.1" class="lexicon_definition"></a>
#### submit_ordercancel(orde::Order) [¶](#method__submit_ordercancel.1)
Cancel pending order backtest version

*source:*
[TradingLogic/src/exchange.jl:69](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L69)

---

<a id="method__submit_ordercancel.2" class="lexicon_definition"></a>
#### submit_ordercancel(ordid::ASCIIString) [¶](#method__submit_ordercancel.2)
Cancel order live version: provide order ID string `ordid`

*source:*
[TradingLogic/src/exchange.jl:79](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L79)

---

<a id="method__submit_ordernew.1" class="lexicon_definition"></a>
#### submit_ordernew(orde::Order, backtest::Bool) [¶](#method__submit_ordernew.1)
New order submission: backtesting version.

*source:*
[TradingLogic/src/exchange.jl:50](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L50)

---

<a id="method__submit_ordernew.2" class="lexicon_definition"></a>
#### submit_ordernew(orde::Order, position_actual::Int64) [¶](#method__submit_ordernew.2)
New order submission: live version

*source:*
[TradingLogic/src/exchange.jl:59](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/exchange.jl#L59)

---

<a id="method__targ2order.1" class="lexicon_definition"></a>
#### targ2order!(orde::Order, targ::(Int64, Array{Float64, 1}), trig::ASCIIString, position_actual::Int64, backtest::Bool) [¶](#method__targ2order.1)
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
[TradingLogic/src/orderhandl.jl:20](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/orderhandl.jl#L20)

---

<a id="method__tradeperffold.1" class="lexicon_definition"></a>
#### tradeperffold(perfprev::(Float64, Float64), statusnow::(Bool, Float64)) [¶](#method__tradeperffold.1)
Performance metrics helper function for use in foldl.

*source:*
[TradingLogic/src/performance.jl:184](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L184)

---

<a id="method__tradepnlfinal.1" class="lexicon_definition"></a>
#### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__tradepnlfinal.1)
Based on blotter only, ending at the last transaction timestamp.

*source:*
[TradingLogic/src/performance.jl:172](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L172)

---

<a id="method__tradepnlfinal.2" class="lexicon_definition"></a>
#### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)}, pnow::Float64) [¶](#method__tradepnlfinal.2)
Adding current price as the last timestamp.

*source:*
[TradingLogic/src/performance.jl:175](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L175)

---

<a id="method__vapblotter.1" class="lexicon_definition"></a>
#### vapblotter(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__vapblotter.1)
Amount `Vector{Int64)` and price `Vector{Float64)` from blotter
in chronological order (returns vector tuple).


*source:*
[TradingLogic/src/performance.jl:8](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L8)

---

<a id="method__vtblotter.1" class="lexicon_definition"></a>
#### vtblotter(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__vtblotter.1)
Ordered timestamps from blotter associative collection.

*source:*
[TradingLogic/src/performance.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/performance.jl#L2)

---

<a id="type__order.1" class="lexicon_definition"></a>
#### Order [¶](#type__order.1)
Order type

*source:*
[TradingLogic/src/types.jl:5](https://github.com/JuliaQuant/TradingLogic.jl/tree/7357a8d10161fc28103c913283b5483164f10c75/src/types.jl#L5)

