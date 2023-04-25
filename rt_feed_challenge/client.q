\l u.q
// table schemas
quote:([]time:`timestamp$(); sym:`g#`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$(); mode:`char$(); ex:`char$(); src:`symbol$());
trade:([]time:`timestamp$(); sym:`g#`symbol$(); price:`float$(); size:`int$(); stop:`boolean$(); cond:`char$(); ex:`char$();side:`symbol$());

// define upd function
// this is the function invoked when the publisher pushes data to it
/upd:{[t;x]show t;show flip x;} / show values
upd:{[t;x] t insert x;f1[];f2[];f3[]}       / add to table

// open a handle to the publisher
h:@[hopen;`::4368;{-2"Failed to open connection to publisher on port 9000: ",
                     x,". Please ensure publisher is running";
                     exit 1}]

// subscribe to the required data
// ` is wildcard for all
h(`.u.sub;`;`);

// first function to calculate the VWAP per min by sym
f1:{[]`vwap set vwap:select vwap:size wavg price by sym,1 xbar time.minute from trade};

// second function to calculate the positions and cost by sym
f2:{[]`position set tab:update cost:sums price*size*?[side=`buy;-1;1], position:sums size*?[side=`buy;1;-1] by sym from trade};

// third function to find any outliers by sym and exchange
f3:{[]`outliers set tab:select outliers: count i by sym,ex from trade where abs[price-(avg;price) fby ([]sym;ex)] > 2*(dev;price) fby ([]sym;ex)}
