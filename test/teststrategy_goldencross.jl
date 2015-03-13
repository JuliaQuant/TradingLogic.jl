facts("Goldencross trading logic") do
  context("Market state") do
    fm = TradingLogic.goldencrossmktstate
    @fact fm(120.0, 50.0) => :trendup
    @fact fm(20.0, 50.0) => :trenddown
    @fact fm(20.0, 20.0) => :crosspoint
  end
  context("Target position") do
    tq = 100
    ft(mkt, posnow) = TradingLogic.goldencrossposlogic(
      mkt, tq, [posnow])
    stlim = Array(Float64, 0)

    # up, zero position
    @fact ft(:trendup, 0) => (tq, stlim)
    # up, position less than target (e.g. partial fill)
    p = int(tq/2)
    @fact ft(:trendup, p) => (tq - p, stlim)

    # down: sell
    @fact ft(:trenddown, tq) => (-tq, stlim)
    @fact ft(:trenddown, p) => (-p, stlim)
    # down: nothing left to sell
    @fact ft(:trenddown, 0) => (0, stlim)

    # hold position in line with the market state
    @fact ft(:trendup, tq) => (0, stlim)

    # crosspoint: wait
    @fact ft(:crosspoint, tq) => (0, stlim)

    # negative position: should not happen, close it
    @fact ft(:trendup, -5) => (5, stlim)
    @fact ft(:trenddown, -5) => (5, stlim)
    @fact ft(:crosspoint, -5) => (5, stlim)
  end
end

facts("Goldencross strategy backtesting") do
  context("SP500 daily vs. zipline") do
    mafast = 50
    maslow = 200
    targetqty = 100

    ### TODO change data input

    s_ohlc = Reactive.Input(ohlc[1:maslow])

    # backtest at close price
    s_pnow = Reactive.lift(s -> values(s["Close"])[end],
                           Float64, s_ohlc)
    blotter = TradingLogic.emptyblotter()

    s_status = TradingLogic.runtrading!(
      blotter, true, s_ohlc, s_pnow, 0,
      TradingLogic.goldencrosstarget, targetqty, mafast, maslow)
    for i in (maslow + 1):length(ohlc)
      push!(s_ohlc, ohlc[i-maslow:i])
      #println(ohlc[i]["Close"])
    end

    println(blotter)

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    println(vt)
    println(perfm)

    ### TODO
    @pending 0 => 1
  end
end
