rel(path::String) = joinpath(splitdir(@__FILE__)[1], path)

facts("OHLC backtest with timearray input") do
  # using quantstrat goldencross test
  #  details in teststrategy_goldencross.jl
  ohlc_BA = TimeSeries.readtimearray(
    rel("quantstrat/goldencross/data/OHLC_BA_2.csv"))
  targetfun = TradingLogic.goldencrosstarget
  mafast = 50; maslow = 200; targetqty = 100
  date_final = Date(2012,8,31)
  ohlc_ta = ohlc_BA[Date(1961,12,31):date_final]
  ohlc_inds = @compat Dict{Symbol,Int64}()
  ohlc_inds[:open] = 1; ohlc_inds[:close] = 4

  # quantstrat/goldencross/results_summary.txt
  pnlnet_ref = 2211.0 # Net.Trading.PL
  ddownmax_ref = 17374.0 # Max.Drawdown

  # backtest settings
  position_initial = 0
  pfill = :open

  context("Final performance and transactions blotter") do
    pnlfin, ddownmax, blotter = TradingLogic.runbacktest(
      ohlc_ta, ohlc_inds, nothing, "", pfill, position_initial,
      targetfun, targetqty, mafast, maslow)
    #TradingLogic.printblotter(STDOUT, blotter)
    @fact pnlfin --> roughly(pnlnet_ref)
    @fact ddownmax --> roughly(ddownmax_ref)

    # quantstrat output: transactions
    txnsdf = DataFrames.readtable(
      rel("quantstrat/goldencross/transactions.csv"),
      header = true,
      names = [:datestr, :qty, :prc, :fees, :val, :avgcost, :pl],
      eltypes = [UTF8String, Int64, Float64, Float64,
                 Float64, Float64, Float64])[2:end,:]
    # vectors to verify
    vqty = convert(Array, txnsdf[:qty])
    vprc = convert(Array, txnsdf[:prc])
    vpnlcum = cumsum(convert(Array, txnsdf[:pl]))
    # NOTE: quantstrat records transaction times when
    #  signal is fired not when open fill-price is taken
    # adjusting for that
    vdate = Date(DateTime(convert(Array, txnsdf[:datestr]),
                          "yyyy-mm-dd HH:MM:SS"))
    oneday = Day(1)
    for i = 1:length(vdate)
      vdate[i] = vdate[i] + oneday
    end

    # verify blotter: transaction matching
    vt, perfm = TradingLogic.tradeperf(blotter, [:DDown])
    @fact length(perfm[:Qty]) --> length(txnsdf[:datestr])
    @fact Date(vt) --> vdate
    @fact perfm[:Qty] --> vqty
    @fact perfm[:FillPrice] --> roughly(vprc)
  end

  context("Output file content") do
    fileout = rel("backtest_out.csv")
    dtformat_out = "yyyy-mm-ddTHH:MM:SS"

    pnlfin, ddownmax, blotter = TradingLogic.runbacktest(
      ohlc_ta, ohlc_inds, fileout, dtformat_out,
      pfill, position_initial,
      targetfun, targetqty, mafast, maslow)
    @fact pnlfin --> roughly(pnlnet_ref)
    @fact ddownmax --> roughly(ddownmax_ref)

    # output file as timearray
    taf = TimeSeries.readtimearray(fileout,
                                   format=dtformat_out)
    run(`rm $fileout`)
    @fact length(taf) --> length(ohlc_ta)
    @fact taf.timestamp --> ohlc_ta.timestamp
    @fact taf.colnames --> [ohlc_ta.colnames, "CumPnL", "DDown"]
    @fact taf.values[:,1:end-2] --> roughly(ohlc_ta.values)
    @fact taf["CumPnL"].values[1] --> roughly(0.0)
    @fact taf["DDown"].values[1] --> roughly(0.0)
    @fact maximum(abs(taf["DDown"].values)) --> roughly(ddownmax_ref)
  end

  context("Latest timestep position and targets") do
    # final step: non-zero position, no changes targeted
    itfin = findfirst(ohlc_ta.timestamp .== Dates.Date(1967,02,23))
    blotter, posact, targ = TradingLogic.runbacktesttarg(
      ohlc_ta[1:itfin], ohlc_inds, nothing, "", pfill, position_initial,
      targetfun, targetqty, mafast, maslow)
    #TradingLogic.printblotter(STDOUT, blotter)
    @fact length(blotter) --> 3
    @fact posact --> 100
    @fact targ[1] --> 0

    # final step: non-zero position, exit targeted
    # if continued, exit transaction fills on 1967-10-27
    itfin = findfirst(ohlc_ta.timestamp .== Dates.Date(1967,10,26))
    blotter, posact, targ = TradingLogic.runbacktesttarg(
      ohlc_ta[1:itfin], ohlc_inds, nothing, "", pfill, position_initial,
      targetfun, targetqty, mafast, maslow)
    #TradingLogic.printblotter(STDOUT, blotter)
    @fact length(blotter) --> 3
    @fact posact --> 100
    @fact targ[1] --> -100

    # final step: zero position, no changes targeted
    itfin = findfirst(ohlc_ta.timestamp .== Dates.Date(1967,10,30))
    blotter, posact, targ = TradingLogic.runbacktesttarg(
      ohlc_ta[1:itfin], ohlc_inds, nothing, "", pfill, position_initial,
      targetfun, targetqty, mafast, maslow)
    #TradingLogic.printblotter(STDOUT, blotter)
    @fact length(blotter) --> 4
    @fact posact --> 0
    @fact targ[1] --> 0
  end
end
