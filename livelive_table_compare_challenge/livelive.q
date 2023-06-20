/ LOAD CSVS

.live.load:{[f;t]
  path:hsym `$(f,".csv");
  (t;enlist ",")0:path
  };

/ error trap loading in CSV

t1:.[.live.load;((.Q.opt[.z.x]`tables)[0];"PSSFI");{0N!x}];
t2:.[.live.load;((.Q.opt[.z.x]`tables)[1];"PSSFI");{0N!x}];

/ report on nulls
null1:select sum_nulls_t1:sum(sum size;sum time;sum price;sum sym;sum src) from null t1;
null2:select sum_nulls_t2:sum(sum size;sum time;sum price;sum sym;sum src) from null t2;
0N!flip (flip null1),flip null2;

/ Either backfill nulls
t1:fills t1;
t2:fills t2;
/ or delete row with nulls from data
delete from `t1 where (time=0Np)or(sym=`)or(src=`)or(price=0n)or(size=0N);                                                    
delete from `t2 where (time=0Np)or(sym=`)or(src=`)or(price=0n)or(size=0N);                                                    

/ functions for creating the two comparison tables


/ make ohlc comparison table
ohlc:{[tab1;tab2]
 t1:select open1:first price, high1:max price, low1:min price, close1:last price by sym from tab1;
 t2:select open2:first price, high2:max price, low2:min price, close2:last price by sym from tab2;
 ohlc:t1 uj t2;
 1!`sym`open1`open2`high1`high2`low1`low2`close1`close2 xcols 0!ohlc 
 }

/call the ohlc function with t1 and t2

ohlc[t1;t2]

/ compare trade tables for each date and save down
each_date:{[hdb1;hdb2;date1] / works
 / get trades data for that day
 t1:hdb1({?[`trades;enlist(=;`date;x);0b;()]};date1);
 q1:hdb1({?[`quotes;enlist(=;`date;x);0b;()]};date1);
 t2:hdb2({?[`trades;enlist(=;`date;x);0b;()]};date1);
 q2:hdb2({?[`quotes;enlist(=;`date;x);0b;()]};date1);
 / run functions
 .live.ohlctab:ohlc[t1;t2];
 /summary table with % comparison
 .live.summary:update open_diff:abs open1%open2,high_diff:abs high1%high2,low_diff:abs low1%low2, close_diff:abs close1%close2 from .live.ohlctab;
 / get spread table from query
 spread_tab:?[`.live.ohlctab;();(enlist `sym)!enlist `sym;`spread1`spread2!((-;`open1;`close1);(-;`open2;`close2))];
 / find which table has smaller spread and save this table
 s1:raze exec spread1 from spread_tab;
 s2:raze exec spread2 from spread_tab;
 which_hdb:$[(sum abs s1)<(sum abs s2);1;2];
 .live.tradetab:$[which_hdb=1;t1;t2];
 .live.quotetab:$[which_hdb=1;q1;q2];

 / save trades and quotes tables down to that date
 {.Q.dpft[`:newhdb;x;`sym;`trades set .live.tradetab]}date1; / have to set to global namespace
 {.Q.dpft[`:newhdb;x;`sym;`quotes set .live.quotetab]}date1; / have to set to global namespace
 }

/ for calling functions to compare trade data 
hdbcompare:{[hdbport1;hdbport2]
 hdb1:hopen hdbport1; hdb2:hopen hdbport2;
 dates: raze value flip hdb1"select distinct date from trades";
 each_date[hdb1;hdb2] each dates;
 hclose hdb1; hclose hdb2;
 }

hdbcompare[1578;1579]
