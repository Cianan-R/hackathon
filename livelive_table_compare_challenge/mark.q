\c 20 200
test_t1:("PSSFI";enlist ",")0: `:/home/crichman/hackathon/livelive_table_compare_challenge/t1.csv;
test_t2:("PSSFI";enlist ",")0: `:/home/crichman/hackathon/livelive_table_compare_challenge/t2.csv;
sol:`t1_coltypes`t1_colnames`t2_coltypes`t2_colnames!(exec t from meta test_t1;cols test_t1;exec t from meta test_t2;cols test_t2);
ans:`t1_coltypes`t1_colnames`t2_coltypes`t2_colnames!(exec t from meta t1;cols t1;exec t from meta t2;cols t2);
0N!sol=ans;
test_ohlc:get `:/home/crichman/hackathon/livelive_table_compare_challenge/solutions/ohlctab;
ohlc_ans:`ohlc_columntypes`ohlc_syms!(exec t from meta .live.ohlctab;exec count distinct sym from .live.ohlctab);
ohlc_sol:`ohlc_columntypes`ohlc_syms!(exec t from meta test_ohlc;exec count distinct sym from test_ohlc);
0N!(ohlc_sol=ohlc_ans);
system"cd newhdb/";
system"ls"
