#!/usr/bin/Rscript --vanilla

############################# DEFINE VARIABLES ##############################

sym      = 'BA'
port     = 'Boeing'
acct     = 'Aerospace'
initEq   = 100000
initDate = '1961-12-31'
endDate  = '2012-08-31'
fast     = 50
slow     = 200

############################# GET DATA ######################################

suppressMessages(require(quantstrat))

#load('data/BA.RData') # need absolute path unless running R in current directory
#load('~/.julia/v0.3/TradingLogic/test/data/BA.RData')
#BA = BA[,1:4]

BA = as.xts(read.zoo("data/OHLC_BA_2.csv", header=TRUE, sep=","))

print("Data gotten")

############################# INITIALIZE ####################################

currency('USD')
stock(sym, currency='USD', multiplier=1)
initPortf(port, sym, initDate=initDate)
initAcct(acct, port, initEq=initEq, initDate=initDate)
initOrders(port, initDate=initDate )
BAcross = strategy(port)

print("Initialized")

############################# MAX POSITION LOGIC ############################

addPosLimit(portfolio = port,
            symbol    = sym, 
            timestamp = initDate,  
            maxpos    = 100)

print("Max position defined")

############################# INDICATORS ####################################

# stratMACROSS <- add.indicator(strategy = stratMACROSS, 
#                               name = "SMA", 
#                               arguments = list(x=quote(Cl(mktdata)), n=50),
#                               label= "ma50" )
# stratMACROSS <- add.indicator(strategy = stratMACROSS, 
#                               name = "SMA", 
#                               arguments = list(x=quote(Cl(mktdata)[,1]), n=200),
#                               label= "ma200")

BAcross <- add.indicator(strategy  = BAcross, 
                         name      = 'SMA', 
                         arguments = list(x=quote(Cl(mktdata)), n=slow),
                         label     = 'slow')

BAcross <- add.indicator(strategy  = BAcross, 
                         name      = 'SMA', 
                         #arguments = list(x=quote(Cl(mktdata)), n=fast),
                         arguments = list(x=quote(Cl(mktdata)[,1]), n=fast),
                         label     = 'fast')

print("Indicators defined")

############################# SIGNALS #######################################

BAcross <- add.signal(strategy  = BAcross,
                      name      = 'sigCrossover',
                      arguments = list(columns=c('fast','slow'), relationship='lt'),
                      label     = 'fast.lt.slow')

BAcross <- add.signal(strategy  = BAcross,
                      name      = 'sigCrossover',
                      arguments = list(columns=c('fast','slow'), relationship='gte'),
                      label     = 'fast.gt.slow')

print("Signals defined")

############################# RULES #########################################

BAcross <- add.rule(strategy  = BAcross,
                    name      = 'ruleSignal',
                    arguments = list(sigcol    = 'fast.gt.slow',
                                     sigval    = TRUE,
                                     orderqty  = 100,
                                     ordertype = 'market',
                                     orderside = 'long'),
                                     # orderside = 'long',
                                     # osFUN     = 'osMaxPos'),
                    type      = 'enter',
                    label     = 'EnterLONG')

BAcross <- add.rule(strategy  = BAcross,
                    name      = 'ruleSignal',
                    arguments = list(sigcol    = 'fast.lt.slow',
                                     sigval    = TRUE,
                                     orderqty  = 'all',
                                     ordertype = 'market',
                                     orderside = 'long'),
                    type      = 'exit',
                    label     = 'ExitLONG')

# BAcross <- add.rule(strategy  = BAcross,
#                     name      = 'ruleSignal',
#                     arguments = list(sigcol     = 'fast.lt.slow',
#                                       sigval    = TRUE,
#                                       orderqty  =  -100,
#                                       ordertype = 'market',
#                                       orderside = 'short'),
#                                       # orderside = 'short',
#                                       # osFUN     = 'osMaxPos'),
#                     type      = 'enter',
#                     label     = 'EnterSHORT')
# 
# BAcross <- add.rule(strategy  = BAcross,
#                     name      = 'ruleSignal',
#                     arguments = list(sigcol     = 'fast.gt.slow',
#                                      sigval     = TRUE,
#                                      orderqty   = 'all',
#                                      ordertype  = 'market',
#                                      orderside  = 'short'),
#                     type      = 'exit',
#                     label     = 'ExitSHORT')

print("Rules defined")

############################# APPLY STRATEGY ################################

applyStrategy(BAcross, port, prefer='Open', verbose=FALSE)

print("Strategy applied")

############################# UPDATE ########################################

#updatePortf(port, sym, Date=paste('::',as.Date(Sys.time()),sep=''))
#updatePortf(port, Date=paste('::',as.Date(Sys.time()),sep=''))
updatePortf(port)
updateAcct(acct)

print("Updates applied")

########################### USEFUL CONTAINERS #############################

invisible(mktdata)
stratStats   = tradeStats(port)
stratReturns = PortfReturns(acct)

############################# EXAMPLE STATS #################################

cat('Profit Factor for BAcross is: ', stratStats$Profit.Factor, '\n')

suppressMessages(require(PerformanceAnalytics))

cat('Sortino Ratio for BAcross is: ', SortinoRatio(stratReturns), '\n')

##### PLACE THIS BLOCK AT END OF DEMO SCRIPT ################### 

book  = getOrderBook(port)
stats = tradeStats(port)
rets  = PortfReturns(acct)
txns  = getTxns(port, sym)

# transactions csv
write.zoo(txns, file="transactions.csv", sep=",")

# results summary with session information
print(getwd())
fnm <- "results_summary.txt"
sink(fnm, append=FALSE)
print(t(tradeStats(port)))
sink(fnm, append=TRUE)
print(sessionInfo(package=NULL), locale=FALSE)
sink()
