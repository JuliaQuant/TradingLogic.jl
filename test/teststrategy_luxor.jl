facts("Goldencross trading logic") do
  context("Market state") do
    fm = TradingLogic.luxormktstate
    @fact fm(120.0, 50.0) => :trendup
    @fact fm(20.0, 50.0) => :trenddown
    @fact fm(20.0, 20.0) => :crosspoint
  end
  context("Target position") do
    tq = 100
    ft(mkt, posnow) = TradingLogic.luxorposlogic(
      mkt, 155.0, 150.0, 10.0, tq, [posnow])
    stlim = Array(Float64, 0)

    # enter long
    @fact ft(:trendup, 0) => (tq, [165.0, 155.0])
    # enter long partial fill
    p = int(tq/2)
    @fact ft(:trendup, p) => (tq - p, [165.0, 155.0])

    # enter short
    @fact ft(:trenddown, 0) => (-tq, [140.0, 150.0])
    # enter short partial fill
    p = -int(tq/2)
    @fact ft(:trenddown, p) => (-abs(tq-p), [140.0, 150.0])

    # hold position in line with the market state
    @fact ft(:trendup, tq) => (0, stlim)
    @fact ft(:trenddown, -tq) => (0, stlim)

    # exit long position
    @fact ft(:trenddown, tq) => (-tq, stlim)
    p = int(tq/2)
    @fact ft(:trenddown, p) => (-p, stlim)

    # exit short position
    @fact ft(:trendup, -tq) => (tq, stlim)
    p = -int(tq/2)
    @fact ft(:trendup, p) => (abs(p), stlim)

    # crosspoint: wait
    @fact ft(:crosspoint, 0) => (0, stlim)
    @fact ft(:crosspoint, -tq) => (0, stlim)
    @fact ft(:crosspoint, tq) => (0, stlim)
  end
end

facts("Luxor strategy backtesting") do
  context("GBPUSD vs. quantstrat") do
    mafast = 10
    maslow = 40
    targetqty = 100
    pthresh = 10.0

    ### TODO change data input

    s_ohlc = Reactive.Input(ohlc[1:maslow])
    # backtest at close price
    s_pnow = Reactive.lift(s -> s["Close"].values[end],
                           Float64, s_ohlc)
    blotter = TradingLogic.emptyblotter()

    s_status = TradingLogic.runtrading!(
      blotter, true, s_ohlc, s_pnow, 0,
      TradingLogic.luxortarget, mafast, maslow, pthresh, targetqty)
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
