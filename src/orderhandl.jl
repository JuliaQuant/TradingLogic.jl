## order processing (generic, not stargety-specific)

"Generate oder ID string for a new order"
function neworderid(trig::String)
  ### TODO hash order id to encrypt trigger-string
  return string(unix2datetime(time())) * "_" * string(trig)
end

"""
Prepare new order from `targ` (`(poschg::Int64, Vector[limitprice,stopprice]`)
and trigger-string `trig`.
Note: this function prepares limit and market orders for submission.
Stop-part of stoplimit orders is handled at the software level
in `orderhandling!` (even for live trading),
which calls `targ2order!` for limit order submission
if stop-price of stoplimit order is reached.
...
Overwrites `orde` and returns `Bool` request status.
"""
function targ2order!(orde::Order,
                     targ::Targ,
                     trig::String,
                     position_actual::Int64,
                     backtest::Bool)
  # this function should be called when position change is needed
  if targ[1] == 0
    warn("targ2order! should not be called when no position change is needed")
    return false
  end

  # overwrite orde components
  if length(targ[2]) == 0
    # no stop/limit conditions
    orde.price = NaN
    orde.ordertype = :market
  elseif length(targ[2]) == 1
    # limit order
    orde.price = targ[2][1]
    orde.ordertype = :limit
  else
    warn("targ2order! does not handle $targ")
    return false
  end
  orde.id = neworderid(trig)
  orde.quantity = abs(targ[1])
  orde.side = targ[1] > 0 ? :buy : :sell
  orde.status = :pending
  orde.trigger = trig

  # submit the order
  if backtest
    respid = submit_ordernew(orde, backtest)
  else
    respid = submit_ordernew(orde, position_actual)
  end
  if respid == "FAIL"
    return false
  end
  if orde.id != respid
    orde.id = respid
  end
  return true
end

"""
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
"""
function orderhandling!(targ::Targ,
                        pnow::Float64, tnow::DateTime,
                        position_actual_mut::Vector{Int64},
                        ordcurr::Order,
                        blotter::Blotter,
                        backtest::Bool
                        )
  posact = position_actual_mut[1]

  #println("enter orderhandling!: posact = $posact")
  #println(targ)

  if backtest
    if ispending(ordcurr)
      # check if previously pending order is now complete
      resp = query_orderstatus(ordcurr, pnow)
      if resp == :complete
        # assume order filled in full quantity at pnow
        poschg = getorderposchg(ordcurr)
        position_actual_mut[1] = posact + poschg
        blotter[tnow] = (poschg, pnow)
        # record different order status
        ordcurr.status = resp
        stillpending = false
        # need to re-evaluate target now that position changed
        return true, tradepnlfinal(blotter, pnow)
      elseif resp == :pending
        stillpending = true
      else
        # neither pending nor complete
        ordcurr.status = resp
        stillpending = false
      end
    else
      stillpending = false
    end
  else
    ### TODO query recent order fills
    ### update actual position based on that and rework pending order logic below
    error("yet to be implemented")

    ############################################################################
#     if ispending(ordcurr)
#     # check if previously pending order is now complete
#     if backtest
#       resp = query_orderstatus(ordcurr, pnow)
#     else
#       resp = query_orderstatus(ordcurr.id)
#     end
#     if resp == :complete
#       ### TODO partial order handling
#       ### (e.g. part of limit order execuled, part still pending)
#       ###### HIGHEST priority todo ##################################
#       ### get recent order fills and update position based on that
#       ### do that earlier in this function

#       # update actual position
#       ### for now assume order executed in full quantity
#       ### later: make opentrs length-10 or so
#       #opentrs
#       #position_actual = posact + getorderposchg(ordcurr)
#       position_actual_mut[1] = posact + getorderposchg(ordcurr)
#     #need to re-evaluate target now that position changed
#         return true, tradepnlfinal(blotter, pnow)
#       ### add new row to blotter here ###############################

#       # record different order status
#       ordcurr.status = resp
#       stillpending = false
#     elseif resp == :pending
#       stillpending = true
#     else
#       # neither pending nor complete
#       ordcurr.status = resp
#       stillpending = false
#     end
#   else
#     stillpending = false
#   end
    ##########################################################################
  end # if backtest

  # check if any position change is targeted at all
  if targ[1] == 0
    # holding the current position
    if stillpending
      # cancel pending order
      if backtest
        respstatus = submit_ordercancel(ordcurr)
      else
        respstatus = submit_ordercancel(ordcurr.id)
      end
      if respstatus
        setcancelled!(ordcurr)
        return respstatus, tradepnlfinal(blotter, pnow)
      else
        return respstatus, tradepnlfinal(blotter, pnow)
      end
    end
    # no pending orders, hold current position
    return true, tradepnlfinal(blotter, pnow)
  end

  # pending order (if any) must be in line with the target
  if stillpending
    if getorderposchg(ordcurr) == targ[1]
      if length(targ[2]) < 1 && ordcurr.ordertype == :market
        # let the order continue as is
        return true, tradepnlfinal(blotter, pnow)
      end
      if length(targ[2]) == 1 && ordcurr.ordertype == :limit
        # check if limit prices match
        if isapprox(targ[2][1], ordcurr.price)
          # let the order continue as is
          return true, tradepnlfinal(blotter, pnow)
        end
      end
      # otherwise no complete match between pending and target
      # cancel pending order not matching the target
      if backtest
        respstatus = submit_ordercancel(ordcurr)
      else
        respstatus = submit_ordercancel(ordcurr.id)
      end
      if respstatus
        setcancelled!(ordcurr)
        return respstatus, tradepnlfinal(blotter, pnow)
      else
        return respstatus, tradepnlfinal(blotter, pnow)
      end
    else
      # cancel pending order not in line with the target
      if backtest
        respstatus = submit_ordercancel(ordcurr)
      else
        respstatus = submit_ordercancel(ordcurr.id)
      end
      if respstatus
        setcancelled!(ordcurr)
        return respstatus, tradepnlfinal(blotter, pnow)
      else
        return respstatus, tradepnlfinal(blotter, pnow)
      end
    end
  end

  # no pending orders at this point
  if length(targ[2]) == 2
    # check stop condition of the stoplimit order
    if targ[1] > 0
      # buy: instantaneous price must exceed the stop-price
      if pnow >= targ[2][2]
        return (targ2order!(ordcurr,
                           (targ[1], targ[2][1:1]),
                           "buy-side software-stop",
                           posact, backtest), tradepnlfinal(blotter, pnow))
      end
    else
      # sell: instantaneous price must be below the stop-price
      if pnow <= targ[2][2]
        return (targ2order!(ordcurr,
                           (targ[1], targ[2][1:1]),
                           "sell-side software-stop",
                           posact, backtest), tradepnlfinal(blotter, pnow))
      end
    end
  elseif length(targ[2]) < 2
    # limit or market order
    return (targ2order!(ordcurr, targ, "limitormarket", posact, backtest),
            tradepnlfinal(blotter, pnow))
  else
    warn("orderhandling! does not handle $targ")
    return false, tradepnlfinal(blotter, pnow)
  end

  return true, tradepnlfinal(blotter, pnow)
end
