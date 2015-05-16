Miscellaneous
=============

This section collects various notes for package users and developers as well as caveats related to the trading functionality.


Functionality notes
-------------------

- *Order placement time in backtesting:* Controlled by ``s_pnow`` signal. For example, set it to the Open-price of the OHLC-signal to fill orders at the opening of the next OHLC timestep.  
- *Single action per timestep:* If e.g. a sell-order is initiated at a timestep ``t``, position update (if the corresponding order is complete) is the only action that would take place at ``t+1``. This behavior differs from quantstrat backtesting where a sequence such as ``sell(t), buy(t+1), sell(t+2)`` is possible (an example of that in quantstrat can be found if running the full date range of ``OHLC_BA.csv`` in ``test/quantstrat/goldencross/quantstrat_goldencross.R``, with 3 sequential transactions around 2012-09-06).


Developer notes
---------------

Run all tests and re-generate API documentation before each commit to the ``master`` branch.

*Run tests* (Julia, package root directry e.g. ``~/.julia/v0.3/TradingLogic``): ::

    using TradingLogic
    include("test/runtests.jl")

*Re-generate docstrings* (Julia): ::

    using Lexicon, TradingLogic
    save("docs/api.md", TradingLogic)

Generate ``rst``-file for the documentation system (shell): ::

    pandoc --from=markdown --to=rst --output=docs/source/api.rst docs/api.md

Commit once each of these steps is error-free.

