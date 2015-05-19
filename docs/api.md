# TradingLogic

## Exported

---

<a id="method__emptyblotter.1" class="lexicon_definition"></a>
#### emptyblotter() [¶](#method__emptyblotter.1)
Initialize empty blotter as an associative collection
`DateTime => (Qty::Int64, FillPrice::Float64)`


*source:*
[TradingLogic/src/types.jl:53](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/types.jl#L53)

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
[TradingLogic/src/performance.jl:206](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/performance.jl#L206)

## Internal

---

<a id="function__query_orderstatus.1" class="lexicon_definition"></a>
#### query_orderstatus [¶](#function__query_orderstatus.1)
Get order status by order ID string.
Returns `Symbol` in line with `Order`-type options for status-slot.


*source:*
[TradingLogic/src/exchange.jl:26](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L26)

---

<a id="function__submit_ordercancel.1" class="lexicon_definition"></a>
#### submit_ordercancel [¶](#function__submit_ordercancel.1)
Cancel order request. Returns `Bool` request result.

*source:*
[TradingLogic/src/exchange.jl:66](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L66)

---

<a id="function__submit_ordernew.1" class="lexicon_definition"></a>
#### submit_ordernew [¶](#function__submit_ordernew.1)
Submit new order. Returns order ID string or `FAIL`-string

*source:*
[TradingLogic/src/exchange.jl:47](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L47)

---

<a id="function__tradepnlfinal.1" class="lexicon_definition"></a>
#### tradepnlfinal [¶](#function__tradepnlfinal.1)
Final profit/loss for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Faster verision (minimizing memory allocation) to be used
in e.g. parameter optimization workflow.

Returns: final profit/loss `Float64` scalar.


*source:*
[TradingLogic/src/performance.jl:164](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/performance.jl#L164)

---

<a id="method__emptyorder.1" class="lexicon_definition"></a>
#### emptyorder() [¶](#method__emptyorder.1)
Empty order: no quantity

*source:*
[TradingLogic/src/types.jl:27](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/types.jl#L27)

---

<a id="method__fsigchange.1" class="lexicon_definition"></a>
#### fsigchange(prev, x) [¶](#method__fsigchange.1)
Signal value change function to be used with foldl;
use with (Bool, signal_t=0) tuple as initial fold value


*source:*
[TradingLogic/src/sigutils.jl:9](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/sigutils.jl#L9)

---

<a id="method__getorderposchg.1" class="lexicon_definition"></a>
#### getorderposchg(orde::Order) [¶](#method__getorderposchg.1)
Signed position change in the Order object

*source:*
[TradingLogic/src/types.jl:39](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/types.jl#L39)

---

<a id="method__goldencrossmktstate.1" class="lexicon_definition"></a>
#### goldencrossmktstate(mafast::Float64, maslow::Float64) [¶](#method__goldencrossmktstate.1)
Market state in goldencross strategy.

*source:*
[TradingLogic/src/strategies/goldencross.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/strategies/goldencross.jl#L2)

---

<a id="method__initbuff.1" class="lexicon_definition"></a>
#### initbuff(nbuff::Int64, xinit::Float64) [¶](#method__initbuff.1)
Initialization of `nbuff`-size float-elements buffer
with NaNs and last element `xinit`.


*source:*
[TradingLogic/src/sigutils.jl:43](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/sigutils.jl#L43)

---

<a id="method__ispending.1" class="lexicon_definition"></a>
#### ispending(orde::Order) [¶](#method__ispending.1)
Check if order status is `:pending`

*source:*
[TradingLogic/src/types.jl:30](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/types.jl#L30)

---

<a id="method__luxormktstate.1" class="lexicon_definition"></a>
#### luxormktstate(mafast::Float64, maslow::Float64) [¶](#method__luxormktstate.1)
Market state in luxor strategy

*source:*
[TradingLogic/src/strategies/luxor.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/strategies/luxor.jl#L2)

---

<a id="method__plimitcheck.1" class="lexicon_definition"></a>
#### plimitcheck(orde::Order, pnow::Float64) [¶](#method__plimitcheck.1)
Backtesting helper function: check if limit-price is reached

*source:*
[TradingLogic/src/exchange.jl:12](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L12)

---

<a id="method__query_orderstatus.1" class="lexicon_definition"></a>
#### query_orderstatus(orde::Order, pnow::Float64) [¶](#method__query_orderstatus.1)
Order status: backtesting version based on current price `pnow`

*source:*
[TradingLogic/src/exchange.jl:29](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L29)

---

<a id="method__schange.1" class="lexicon_definition"></a>
#### schange{T}(s_inp::Signal{T}) [¶](#method__schange.1)
Bool change signal, true when input signal changes

*source:*
[TradingLogic/src/sigutils.jl:16](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/sigutils.jl#L16)

---

<a id="method__setcancelled.1" class="lexicon_definition"></a>
#### setcancelled!(orde::Order) [¶](#method__setcancelled.1)
Change order status to `:cancelled`

*source:*
[TradingLogic/src/types.jl:33](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/types.jl#L33)

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
[TradingLogic/src/sigutils.jl:33](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/sigutils.jl#L33)

---

<a id="method__submit_ordercancel.1" class="lexicon_definition"></a>
#### submit_ordercancel(orde::Order) [¶](#method__submit_ordercancel.1)
Cancel pending order backtest version

*source:*
[TradingLogic/src/exchange.jl:69](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L69)

---

<a id="method__submit_ordernew.1" class="lexicon_definition"></a>
#### submit_ordernew(orde::Order, backtest::Bool) [¶](#method__submit_ordernew.1)
New order submission: backtesting version.

*source:*
[TradingLogic/src/exchange.jl:50](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/exchange.jl#L50)

---

<a id="method__tradepnlfinal.1" class="lexicon_definition"></a>
#### tradepnlfinal(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__tradepnlfinal.1)
Based on blotter only, ending at the last transaction timestamp.

*source:*
[TradingLogic/src/performance.jl:167](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/performance.jl#L167)

---

<a id="method__vapblotter.1" class="lexicon_definition"></a>
#### vapblotter(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__vapblotter.1)
Amount `Vector{Int64)` and price `Vector{Float64)` from blotter
in chronological order (returns vector tuple).


*source:*
[TradingLogic/src/performance.jl:8](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/performance.jl#L8)

---

<a id="method__vtblotter.1" class="lexicon_definition"></a>
#### vtblotter(blotter::Dict{DateTime, (Int64, Float64)}) [¶](#method__vtblotter.1)
Ordered timestamps from blotter associative collection.

*source:*
[TradingLogic/src/performance.jl:2](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/performance.jl#L2)

---

<a id="type__order.1" class="lexicon_definition"></a>
#### Order [¶](#type__order.1)
Order type

*source:*
[TradingLogic/src/types.jl:5](https://github.com/JuliaQuant/TradingLogic.jl/tree/39f157e013c05663572371cb58a144b9dd832304/src/types.jl#L5)

