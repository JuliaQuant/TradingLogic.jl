using MarketData

facts("Luxor strategy backtesting") do
  context("TODO contexts for zipline, quantstrat") do
    s_ohlc = Reactive.Input(ohlc[1:50])
    # backtest at close price
    s_pnow = Reactive.lift(s -> values(s["Close"])[end],
                           Float64, s_ohlc)
    blotter = TradingLogic.emptyblotter()

    s_status = TradingLogic.runtrading!(
      blotter, true, s_ohlc, s_pnow, 0,
      TradingLogic.luxortarget, 10, 40, 10.0, 100)

    for i in 51:200
      push!(s_ohlc, ohlc[i-50:i])
      #println(blot)

      #println(ohlc[i]["Close"])
    end

    println(blotter)

    ### TODO
    @fact 0 => 1
  end
end
