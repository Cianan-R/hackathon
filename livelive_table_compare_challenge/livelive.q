\l fakedb.q
makedb[100000;10000];
t1:trades
q1:quotes
makedb[100000;10000];
t2:trades
q2:quotes


trade_ana1:select maxprice:max price, minprice:min price, spread:(max price)-min price by sym,src from t1 
trade_ana2:select maxprice:max price, minprice:min price, spread:(max price)-min price by sym,src from t2 
tt: trade_ana1 uj trade_ana2
2!`sym`src`maxprice`maxprice2`minprice`minprice2`spread`spread2 xcols 0!tt
