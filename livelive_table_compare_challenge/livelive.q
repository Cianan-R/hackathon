/ load in fakedb for generating hdbs
/ load in two csvs

/ function for creating the two comparison tables
/ max/min price by sym
/ ohlc

/ load in 2 hdbs from different ports
/ do comparison over each day?

/ over each day, use logic to determine which hdb data is best
/ logic -> best max/min price by sym per day, best ohlc per day
/ best -> lowest spread on oc/hl?, lowest spread on max/min? 
/ save down each best day using .Q.dpft

\d .live
/ LOAD CSVS
t1:("PSSFI";enlist",")0:`:t1.csv
t1:update `g#sym, `g#src from t1
t2:("PSSFI";enlist",")0:`:t2.csv
t2:update `g#sym, `g#src from t2

/ functions for creating the two comparison tables

ohlc:{[tab1;tab2]
 t1:select open1:first price, high1:max price, low1:min price, close1:last price by sym from tab1;
 t2:select open2:first price, high2:max price, low2:min price, close2:last price by sym from tab2;
 ohlc:t1 uj t2;
 1!`sym`open1`open2`high1`high2`low1`low2`close1`close2 xcols 0!ohlc 
 }
minmax:{[tab1;tab2]
 t1:select maxprice1:max price, minprice1:min price by sym from tab1;
 t2:select maxprice2:max price, minprice2:min price by sym from tab2;
 minmax:t1 uj t2;
 1!`sym`maxprice1`maxprice2`minprice1`minprice2 xcol 0!minmax
 }

olhc_spread:{[ohlctab]
 / get spreads
 spread_tab:select spread1:open1-close1, spread2:open2-close2 by sym from ohlctab;
 .live.sum1:0;
 .live.sum2:0;
 / get # of elements>0 for each table
 {if[x>0;sum1::sum1+1];}each raze exec spread1 from spread_tab;
 {if[x>0;sum2::sum2+1];}each raze exec spread2 from spread_tab;
 / if # elems>0 is greater in a use tab1, else use tab2
 $[sum1>=sum2;tab:t1;tab:t2]
 }


each_date:{[hdb1;hdb2;date1]
 / get trades data for that day
 t1:hdb1({?[`trades;enlist(=;`date;x);0b;()]};date1);
 t2:hdb2({?[`trades;enlist(=;`date;x);0b;()]};date1);

 / run functions
 ohlctab:ohlc[t1;t2];
 minmax[t1;t2];

 / get spreads and new table to save
 .live.tab:olhc_spread[ohlctab];

 / maybe another check for max/min

 /$[sum1>=sum2;0N!"t1";0N!"t2"]; / for debug

 / save this table down to that date
 {.Q.dpft[`:newhdb;x;`sym;`trades set .live.tab]}date1; / have to set to global namespace
 }

hdbcompare:{[hdbport1;hdbport2]
 hdb1:hopen hdbport1;
 hdb2:hopen hdbport2;
 dates:hdb1"select distinct date from trades";
 dates: raze value flip dates;
 each_date_hdb:each_date[hdb1;hdb2;];
 each_date_hdb each dates;
 }