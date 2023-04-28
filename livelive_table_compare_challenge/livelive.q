/ LOAD CSVS
t1:("PSSFI";enlist",")0:`:t1.csv;
t1:update `g#sym, `g#src from t1;
t2:("PSSFI";enlist",")0:`:t2.csv;
t2:update `g#sym, `g#src from t2;

null1:select sum_nulls_t1:sum(sum size;sum time;sum price;sum sym;sum src) from null t1;
null2:select sum_nulls_t2:sum(sum size;sum time;sum price;sum sym;sum src) from null t2;
0N!flip (flip null1),flip null2;
t1:fills t1;
t2:fills t2;

/ functions for creating the two comparison tables
\d .live

/ make ohlc comparison table
ohlc:{[tab1;tab2] / works
 t1:select open1:first price, high1:max price, low1:min price, close1:last price by sym from tab1;
 t2:select open2:first price, high2:max price, low2:min price, close2:last price by sym from tab2;
 ohlc:t1 uj t2;
 1!`sym`open1`open2`high1`high2`low1`low2`close1`close2 xcols 0!ohlc 
 }
/ make minmax comparison table
minmax:{[tab1;tab2] / works
 t1:select maxprice1:max price, minprice1:min price by sym from tab1;
 t2:select maxprice2:max price, minprice2:min price by sym from tab2;
 minmax:t1 uj t2;
 1!`sym`maxprice1`maxprice2`minprice1`minprice2 xcols 0!minmax
 }
/ define query for creating spread table
spread_query:{[tab;x1;x2;n1;n2] /works
 ?[tab;();(enlist `sym)!enlist `sym;`spread1`spread2!((-;x1;n1);(-;x2;n2))]
 }
/ find which table has smaller spread
spread:{[spread_tab] / works
 .live.sum1:0;
 
 / lowest spread is compare which abs(value) is smaller and count
 s1:raze exec spread1 from spread_tab;
 s2:raze exec spread2 from spread_tab;

 .live.sum1:sum ?[(abs s1)<abs s2;1;0];
 / if >4 is 1 then s1 is better use tab1, else use tab2
 $[.live.sum1>4;tab:t1;tab:t2]
 /$[.live.sum1>4;0N!"t1";0N!"t2"]; / for debug
 }
/ compare trade tables for each date and save down
each_date:{[hdb1;hdb2;date1] / works
 / get trades data for that day
 t1:hdb1({?[`trades;enlist(=;`date;x);0b;()]};date1);
 t2:hdb2({?[`trades;enlist(=;`date;x);0b;()]};date1);

 / run functions
 .live.ohlctab:ohlc[t1;t2];
 .live.minmaxtab:minmax[t1;t2];
 
 / get spread table
 spread_tab:.live.spread_query[`.live.ohlctab;`open1;`open2;`close1;`close2];
 spread_tab:.live.spread_query[`.live.minmaxtab;`maxprice1;`maxprice2;`minprice1;`minprice2];

 / new table to save
 /.live.tab:spread[ohlc_spread_tab];
 .live.tab:.live.spread[spread_tab];

 / save this table down to that date
 {.Q.dpft[`:newhdb;x;`sym;`trades set .live.tab]}date1; / have to set to global namespace
 }

/ for calling functions to compare trade data 
hdbcompare:{[hdbport1;hdbport2]
 hdb1:hopen hdbport1;
 hdb2:hopen hdbport2;
 dates:hdb1"select distinct date from trades";
 dates: raze value flip dates;
 each_date_hdb:each_date[hdb1;hdb2];
 each_date_hdb each dates;
 hclose hdb1;
 hclose hdb2;
 }
