
\l u.q
/ table schemas
quote:([]time:`timestamp$(); sym:`g#`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$(); mode:`char$(); ex:`char$(); src:`symbol$());
trade:([]time:`timestamp$(); sym:`g#`symbol$(); price:`float$(); size:`int$(); stop:`boolean$(); cond:`char$(); ex:`char$();side:`symbol$());

// define upd function
// this is the function invoked when the publisher pushes data to it
upd:{[t;x]show t;show flip x;} / show values
/upd:{[t;x] .u.upd[t;x]}       / add to table

// open a handle to the publisher
h:@[hopen;`::9000;{-2"Failed to open connection to publisher on port 9000: ",
                     x,". Please ensure publisher is running";
                     exit 1}]

// subscribe to the required data
// .u.sub[tablename; list of instruments]
// ` is wildcard for all
h(`.u.sub;`;`);