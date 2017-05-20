## broker/exchange communication

## IMPORTANT:
## careful error handling needed here not to crash live trading session!
## try-catch nearly everything!

### TODO how to plug-in function sets for different brokers/exchanges
### for now: need to overwrite ALL these functions
### to start a trading instance

"Backtesting helper function: check if limit-price is reached"
function plimitcheck(orde::Order, pnow::Float64)
  if (orde.side == :buy) && (pnow <= orde.price)
    return true
  end
  if (orde.side == :sell) && (pnow >= orde.price)
    return true
  end
  return false
end

"""
Get order status by order ID string.
Returns `Symbol` in line with `Order`-type options for status-slot.
"""
:query_orderstatus

"Order status: backtesting version based on current price `pnow`"
function query_orderstatus(orde::Order, pnow::Float64)
  if orde.ordertype == :market
    return :complete
  end
  if plimitcheck(orde, pnow)
    # limit-price reached
    return :complete
  end
  return :pending
end

"Order status: live version"
function query_orderstatus(ordid::String)
  ### TODO
  return resp_orderstatus
end

"Submit new order. Returns order ID string or `FAIL`-string"
:submit_ordernew

"New order submission: backtesting version."
function submit_ordernew(orde::Order, backtest::Bool)
  if !backtest
    return "FAIL"
  end
  #println("Submitting order $orde")
  return orde.id
end

"New order submission: live version"
function submit_ordernew(orde::Order, position_actual::Int64)
  ### TODO
  ### add short-sell logic here by checking position_actual
  return resp_orderid # if error return "FAIL"
end

"Cancel order request. Returns `Bool` request result."
:submit_ordercancel

"Cancel pending order backtest version"
function submit_ordercancel(orde::Order)
  if orde.status != :pending
    warn("Attempting to cancel a non-pending order")
    return false
  end
  #println("Cancelling pending order $orde")
  return true
end

"Cancel order live version: provide order ID string `ordid`"
function submit_ordercancel(ordid::String)
  ### TODO
  return resp_status
end
