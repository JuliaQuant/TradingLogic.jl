[![Documentation Status](https://readthedocs.org/projects/tradinglogicjl/badge/?version=latest)](http://tradinglogicjl.readthedocs.io/en/latest/?badge=latest)

# TradingLogic.jl

An attempt at a unified framework in Julia language for both event-driven backtesting and live trading. This package utilizes reactive programming elements implemented in [Reactive.jl](https://github.com/JuliaLang/Reactive.jl).

The main objective is to be able to backtest and place real-time orders using the same trading strategy functions.

NOTE: The current `master`-branch code requires `Julia >=0.4.0`. See the `julia03` branch for the last version tested with Julia 0.3 before [0.4.0 final release](https://github.com/JuliaLang/julia/releases).
