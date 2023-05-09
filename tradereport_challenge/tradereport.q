/\d .test
/define dates from command line variables
dates:"D"$.z.x[0 1];
/open port to the HDB process
-1 (string .z.p),": Connecting to HDB...";
h:@[hopen;9999;{-2"Failed to connect to HDB: ",x;exit 1}];
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
-1 (string .z.p),": Emailing report";
filepath: 1_string name;
system "mail -s 'Trade Report' -A ",filepath," emma.goodwin@dataintellect.com < /dev/null"
-1 (string .z.p),": Report complete. Exiting...";
exit 0;
