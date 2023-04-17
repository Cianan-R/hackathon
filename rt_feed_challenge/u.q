/2019.06.17 ensure sym has g attr for schema returned to new subscriber
/2008.09.09 .k -> .q
/2006.05.08 add

\d .u
init:{w::t!(count t::tables`.)#()} / initialises empty dict with tables as the key

del:{w[x]_:w[x;;0]?y};.z.pc:{del[;x]each t};

sel:{$[`~y;x;select from x where sym in y]}

pub:{[t;x]{[t;x;w]if[count x:sel[x]w 1;(neg first w)(`upd;t;x)]}[t;x]each w t}

add:{$[(count w x)>i:w[x;;0]?.z.w;.[`.u.w;(x;i;1);union;y];w[x],:enlist(.z.w;y)];(x;$[99=type v:value x;sel[v]y;@[0#v;`sym;`g#]])}

sub:{if[x~`;:sub[;y]each t];if[not x in t;'x];del[x].z.w;add[x;y]}

end:{(neg union/[w[;;0]])@\:(`.u.end;x)}

/ upd:{[t;x]t insert x;if[l;l enlist (`upd;t;x);j+:1]} /`l error
upd:{[t;x]t insert x}