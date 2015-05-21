using FactCheck
using MarketData
using DataFrames
#using TradingLogic

include("signals.jl")
include("orders.jl")
include("exchange_backtest.jl")
include("perfmetrics.jl")
include("backtest.jl")

# testing built-in trading strategies
include("teststrategy_goldencross.jl")
include("teststrategy_luxor.jl")

#exitstatus()
