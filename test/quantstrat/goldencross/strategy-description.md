# Strategy summary

Luxor trend-following accounting LPPL bubble signals


## Indicators

* Fast SMA of closing price (`fast`)
* Slow SMA of closing price (`slow`)


## Signals

* `fast.gt.slow` only when `fast >= slow` crossover
* `fast.lt.slow` only when `fast < slow` crossover


## Rules

* **Enter long** with maximum position on `fast.gt.slow` signal
* **Exit from long** completely on `fast.lt.slow` signal

