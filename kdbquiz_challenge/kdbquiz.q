\d .quiz
/ define registry table
registry:([handle:`int$()] username:`$();  time:`timestamp$(); IP:`int$() )
curr_ans_tab:([handle:`int$()] user: `$();currans:())
results:([handle:`int$()] username:`$(); score:`int$())

/ add to table
.z.po:{`.quiz.registry upsert (x;.z.u;.z.p;.z.a); `.quiz.results upsert (x;.z.u;0i)}

/ questions and answers
d:("Q1";"Q2";"Q3")!("A1";"A2";"A3")
/ define current answer table

/ works for sending down
/.z.ts:{if[not `test in key `;.test.ctr:0]; $[.test.ctr>=count d; [system"t 0";.test.ctr:0;]; [.test.mess:(key d) .test.ctr; {x(show; .test.mess)}each key .z.W; .test.ctr+:1;]]}
quizover:{{x(show; "Quiz over!")}each key .z.W; system"t 0";.test.ctr:0;}
cont:{
 vals:?[(value d) .test.ctr ~/: exec currans from curr_ans_tab; 1i;0i]; 
 .quiz.results:.quiz.results pj ([handle: exec handle from curr_ans_tab] score: ans);
 .test.mess:(key d) .test.ctr; {x(show; .test.mess)}each key .z.W; 
 .test.ctr+:1;
 }

.z.ts:{
 if[not `test in key `;.test.ctr:0]; 
 $[.test.ctr>=count d; 
  .quiz.quizover[]; 
  .quiz.cont[x]]
 }

.z.ps:{`.quiz.curr_ans_tab upsert (.z.w;.z.u;x)}

/system"t 2000"
