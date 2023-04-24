// Changes
// No side column in trades table
// added depth table
// changed time type to timestamp
// data doesn't tick all day

// Generate fake equity database

// Params
syms:`NOK`YHOO`CSCO`ORCL`AAPL`DELL`IBM`MSFT`GOOG;
srcs:`N`O`L;
curr:syms!`EUR`USD`USD`USD`USD`GBP`USD`USD`USD;
starttime:08:00:00.0;
hoursinday:08:30:00.0;
/- initial prices
initpxs:syms!20f+count[syms]?30f;
/-create hdb from 21st April
startdate:2014.04.21;

// Schema
initschema:{[]
 quotes::([]time:`timestamp$();sym:`g#`$();src:`g#`$();bid:`float$();ask:`float$();bsize:`int$();asize:`int$());
 trades::([]time:`timestamp$();sym:`g#`$();src:`g#`$();price:`float$();size:`int$());
 depth::([]time:`timestamp$();sym:`g#`$(); bid1:`float$(); bsize1:`int$(); bid2:`float$(); bsize2:`int$(); bid3:`float$(); bsize3:`int$(); ask1:`float$(); asize1:`int$(); ask2:`float$(); asize2:`int$(); ask3:`float$(); asize3:`int$());
 };

// Utility Functions
rnd:{0.01*floor 100*x};

// Create TAQ database
makedb1:{[nq;nt;date;randomcounts]
 if[(not -9f=type randomcounts) or not randomcounts within (0;1); '"randomcounts factor should be float within 0 and 1"];
 /- randomize the number of quotes and trades
 nq:`int$nq * 1 + rand[randomcounts]*signum -.5+rand 1f;
 nt:`int$nt * 1 + rand[randomcounts]*signum -.5+rand 1f;
 /- the number of depth ticks - up to 
 nd:`int$nq*1.5+rand .5;
 qts:update px*initpxs sym from update px:exp px from update sums px by sym from update px:0.0005*-1+nq?2f from([]time:`#asc starttime+nq?hoursinday;sym:`g#nq?syms;src:`g#nq?srcs);
 qts:select time,sym,src,bid:rnd px-nq?0.03,ask:rnd px+nq?0.03,bsize:500*1+nq?20,asize:500*1+nq?20 from qts;
 trds:update bid:reverse fills reverse bid,ask:reverse fills reverse ask,bsize:reverse fills reverse bsize,asize:reverse fills reverse asize by sym from aj[`sym`time;([]time:`#asc starttime+nt?hoursinday;sym:nt?syms;src:nt?srcs;side:nt?`buy`sell);qts];
 trds:select time,sym,src,side,price:?[side=`buy;ask;bid],size:`int$(nt?1f)*?[side=`buy;asize;bsize] from trds;
 dpth:update bid:reverse fills reverse bid,ask:reverse fills reverse ask,bsize:reverse fills reverse bsize,asize:reverse fills reverse asize by sym from aj[`sym`time;([]time:`#asc starttime+nd?hoursinday;sym:nd?syms);qts];
 dpth:select time,sym,bid1:bid, bsize1:bsize, bid2:bid-.01, bsize2:bsize+500*1+nd?5, bid3:bid-.02,bsize3:bsize+500*1+nd?10,ask1:ask, asize1:asize,ask2:ask+.01,asize2:asize+500*1+nd?5,ask3:ask+.02,asize3:asize+500*1+nd?10 from dpth;
 initschema[];
 upsert[`quotes;update time:`timestamp$time+date from qts];
 upsert[`trades;update time:`timestamp$time+date from delete side from trds];
 upsert[`depth;update time:`timestamp$time+date from dpth];
 /- update the initial prices
 initpxs,::exec last price by sym from trds;
 };

makedb:makedb1[;;.z.D;0.00000001];
makehdb:{[dir;numdays;nq;nt]
	datelist:startdate + til 7*1+ceiling numdays%5;
	datelist:numdays#datelist where not (datelist mod 7) in 0 1;
	{[hdb;nq;nt;d]
	 makedb1[nq;nt;d;.3];
	 -1(string .z.z)," saving data for date ",(string d)," to ",string hdb;
	 .Q.hdpf[`:;hdb;d;`sym]}[dir;nq;nt] each datelist;} 

makecsv:{[dir;numdays;nq;nt]
	datelist:startdate + til 7*1+ceiling numdays%5;
        datelist:numdays#datelist where not (datelist mod 7) in 0 1;
        {[csvdir;nq;nt;d]
         makedb1[nq;nt;d;0f];
	 /- put the trades and quotes together
	 alldata:select time.time,sym,src:("EXCH=",/:string src),price,size,bid,ask,bsize,asize,tradeflag:?[null price;" ";(count sym)?"ABCD"],ccy:curr[sym] from `time xasc trades uj quotes;
	 /- rename the columns
	 alldata:(`$("TIME";"INSTRUMENT";"EXCH";"PRICE";"SIZE";"BID";"ASK";"BID SIZE";"ASK SIZE";"TRADE FLAG";"CURRENCY")) xcol alldata;
	 filename:hsym `$(string csvdir),"/tradesandquotes",(ssr[string d;".";""]),".csv";
         -1(string .z.z)," saving csv file for date ",(string d)," to ",string filename;
         filename 0: .h.cd alldata}[dir;nq;nt] each datelist;}

initschema[];
  
-1"USAGE: makedb[NUM QUOTES;NUM TRADES] eg makedb[100000;10000]\n\nmakedb1[NUM QUOTES;NUM TRADES;DATE;RANDOMISED COUNT FACTOR] eg makedb1[100000;10000;.z.d;.3]\n\nmakehdb[HDBDIR;NUM DAYS;APPROXIMATE NUM QUOTES PER DAY; APPROXIMATE NUM TRADES PER DAY] eg makehdb[`:hdb; 5; 100000; 10000]\n\nmakecsv[CSVDIR;NUM DAYS;NUM QUOTES;NUM TRADES]\n";

makedb[100;10]
