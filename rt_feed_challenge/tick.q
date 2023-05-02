/ generate data

sn:2 cut (
 `AMD;"ADVANCED MICRO DEVICES";
 `AIG;"AMERICAN INTL GROUP INC";
 `AAPL;"APPLE INC COM STK";
 `DELL;"DELL INC";
 `DOW;"DOW CHEMICAL CO";
 `GOOG;"GOOGLE INC CLASS A";
 `HPQ;"HEWLETT-PACKARD CO";
 `INTC;"INTEL CORP";
 `IBM;"INTL BUSINESS MACHINES CORP";
 `MSFT;"MICROSOFT CORP")

s:first each sn
n:last each sn
p:33 27 84 12 20 72 36 51 42 29 / price
m:" ABHILNORYZ" / mode
c:" 89ABCEGJKLNOPRTWZ" / cond
e:"NONNONONNN" / ex
src:`BARX`GETGO`SUN`DB
side:`buy`sell

cnt:count s
pi:acos -1
gen:{exp 0.001 * normalrand x}
normalrand:{(cos 2 * pi * x ? 1f) * sqrt neg 2 * log x ? 1f}
randomize:{value "\\S ",string "i"$0.8*.z.p%1000000000}
rnd:{0.01*floor 0.5+x*100}
vol:{10+`int$x?90}

randomize[]

/ =========================================================================================
/ generate weights to stop even distribution of counts and sizes
weight:0.1*1+neg[cnt]?2*cnt

/ assign multipliers to skew size columns
volmap:s!neg[cnt]?weight
bidmap:s!neg[cnt]?weight
askmap:s!neg[cnt]?weight

/ returns list where count of each item is given by random permutation of integer weights
skewitems:{[weights;items]raze weights#'neg[count items]?items}

/ skew sym counts with weighted list of indices
weightedsyms:skewitems[`long$weight*10;til cnt]

/ assign skewed side and src lists to determine probabilities of appearing
sideweight:cnt?{x,cnt-x}'[1+til cnt-1]
sidemap:s!skewitems[;side] each sideweight
srcweight:1+til count src
srcmap:s!skewitems[srcweight;] each cnt#enlist src

/ =========================================================================================
/ generate a batch of prices
/ qx index, qb/qa margins, qp price, qn position
batch:{
 d:gen x;
 qx::x?weightedsyms;
 qb::rnd x?1.0;
 qa::rnd x?1.0;
 n:where each qx=/:til cnt;
 s:p*prds each d n;
 qp::x#0.0;
 (qp raze n):rnd raze s;
 p::last each s;
 qn::0}

len:10000
batch len

maxn:10 / max trades per tick
qpt:5   / avg quotes per trade

/ =========================================================================================

t:{
 if[not (qn+x)<count qx;batch len];
 i:qx n:qn+til x;qn+:x;
 (s i;qp n;`int$volmap[s i]*x?99;1=x?20;x?c;e i;raze 1?'sidemap[s i])}

q:{
 if[not (qn+x)<count qx;batch len];
 i:qx n:qn+til x;p:qp n;qn+:x;
 (s i;p-qb n;p+qa n;`long$bidmap[s i]*vol x;`long$askmap[s i]*vol x;x?m;e i;raze 1?'srcmap[s i])}

/ set up process on port
system"p 4368"

/ table schemas
quote:([]time:`timestamp$(); sym:`g#`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$(); mode:`char$(); ex:`char$(); src:`symbol$());
trade:([]time:`timestamp$(); sym:`g#`symbol$(); price:`float$(); size:`int$(); stop:`boolean$(); cond:`char$(); ex:`char$();side:`symbol$());

/ load in .u funtions and initialise tables
\l u.q 
.u.init[]

/ function for generating timestamps and publishing the tables
pubtq:{
    o:"p"$9e5*floor (.z.P-3600000)%9e5;
    d:.z.P-o;
    len:floor d%113;
    times:`timestamp$o+asc len?d;
    .u.pub[`trade;(enlist a#times), t a:1+rand maxn];
    .u.pub[`quote;(enlist a#times), q a:1+rand qpt*maxn];
 }

// create timer function to randomly publish
.z.ts:{pubtq[]}

// every 2 seconds to publish
\t 2000




