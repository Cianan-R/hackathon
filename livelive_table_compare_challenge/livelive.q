\l fakedb.q
/makedb[100000;10000];
/t1:trades
/q1:quotes
/makedb[100000;10000];
/t2:trades
/q2:quotes

/trade_ana1:select maxprice1:max price, minprice1:min price, spread1:(max price)-min price by sym,src from t1 
/trade_ana2:select maxprice2:max price, minprice2:min price, spread2:(max price)-min price by sym,src from t2 
/tt: trade_ana1 uj trade_ana2
/2!`sym`src`maxprice1`maxprice2`minprice1`minprice2`spread1`spread2 xcols 0!tt

/ LOAD CSVS
t1:("PSSFI";enlist",")0:`:t1.csv
t1:update `g#sym, `g#src from t1
t2:("PSSFI";enlist",")0:`:t2.csv
t2:update `g#sym, `g#src from t2


func:{[tab1;tab2]
 t1:select open:first price, high:max price, low:min price , close:last price by sym from tab1
 t2:select open:first price, high:max price, low:min price , close:last price by sym from tab2
 t2:`sym`open2`high2`low2`close2 xcol t2
 t1 uj t2
 }
