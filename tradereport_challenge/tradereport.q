/define dates from command line variables
if[10=count .z.x[1] and 10=count .z.x[0]; dates:"D"$(.Q.opt[.z.x]`dates)[0 1];]

-1 (string .z.p),": Connecting to HDB..."; /open port to the HDB process
h:@[hopen;1567;{-2"Failed to connect to HDB: ",x;exit 1}]

if[not `dates in key `.; / if no dates provided from command line, gets first and last date
 mindate:h"min raze flip select distinct date from trades";
 maxdate:h"max raze flip select distinct date from trades";
 dates:mindate,maxdate];

/query HDB
-1 (string .z.p),": Querying HDB...";
trades:0!h({[DATES] select ntrades:count i, sum size,turnover:sum size*price by date,sym from trades where date within DATES};dates);
/load symstatic.csv
-1 (string .z.p),": Loading symstatic.csv...";
static:("S*S";enlist ",") 0: `:tradereport/symstatic.csv;
/join static data to trades
-1 (string .z.p),": Joining static data...";
trades:trades lj 1!static;
/load fxrates.csv
-1 (string .z.p),": Loading fxrates.csv...";
fxrates:("DSF";enlist ",") 0: `:tradereport/fxrates.csv;
/join fxrates;
-1 (string .z.p),": Joining fxrates...";
trades:aj[`curr`date;trades;update `g#curr from fxrates];
update rateUSD:1. from `trades where curr=`USD;
/calculate turnover in USD
tradereport:select date,sym,description,curr,ntrades,size,turnoverUSD:`long$turnover*rateUSD from trades;
/save report to csv file
-1 (string .z.p),": Writing to csv...";
save `:tradereport/tradereport.csv;
name:(`$":tradereport/tradereport_",(("_" sv string dates) except "."),".csv");
name 0: "," 0:tradereport;
/to save as non csv
`:tradereport/tradereport_table set tradereport
-1 (string .z.p),": Emailing report";
filepath: 1_string name;
system "mail -s 'Trade Report' -A ",filepath," cianan.richman@dataintellect.com < /dev/null"
-1 (string .z.p),": Report complete.";

