\p 9999

\d .quiz
/ define initial tables table
registry:([handle:`int$()] username:`$();  time:`timestamp$(); IP:`int$() )     / initial registry
curr_ans_tab:([handle:`int$()] user: `$();currans:())                           / keep track of current answers
results:([handle:`int$()] username:`$(); score:`int$())                         / tally of results

/ add to table for each user joining, also allow console of client to be sent to server
.z.po:{
 `.quiz.registry upsert (x;.z.u;.z.p;.z.a); 
 `.quiz.results upsert (x;.z.u;0i); 
 `.quiz.curr_ans_tab upsert (x;.z.u;"000"); 
 x".z.pi:{(neg h)x}";
 }

/ questions and answers
questions:("Q1";"Q2";"Q3");
answers:("A1";"A2";"A3");
d:questions!answers;


/ runs when the quiz is over
quizover:{
 {x(show; "Quiz over!")}each key .z.W;                  / sends quiz over message
 sorted:desc .quiz.results;                             / sorts results
 max_score:exec max score from sorted;                  / get value of max score
 winners:exec handle from sorted where score=max_score; / handles of winner(s)
 {x(show;"Congrats! You are the winner!")}each winners; / sends winner message to teh winner(s)
 .test.ctr:0;                                           / resets counters
 .test.quiz_ind:0;
 system"t 0";                                           / stop timer
 {x(exit;0);}each key .z.W;                             / send message to exit bc can't reset the .z.pi client side
 }

/ sends the questions from current index
send_question:{
 .test.mess:(key .quiz.d) .test.quiz_ind; 
 {x(show; .test.mess)}each key .z.W; 
 }

/ matches current answer with dict answers and adds the list of 1/0s to results to keep track
evaluate:{
 .quiz.vals:?[((value .quiz.d) .test.quiz_ind) ~/: exec currans from .quiz.curr_ans_tab; 1i;0i];          / if ans to current question matches each ans from current answer returns list 0,1 
 .quiz.results:.quiz.results pj ([handle: exec handle from .quiz.curr_ans_tab] score: .quiz.vals);
 }

/ to make if else tidier
cont:{
 .quiz.evaluate[];
 .test.ctr+:1;
 .test.quiz_ind+:1;
 .quiz.send_question[]; 
 }

.z.ts:{
 if[not `test in key `;.test.ctr:0;.test.quiz_ind:0];             / just makes ctr and initialises it to 0
 $[.test.ctr=0;[.quiz.send_question[];.test.ctr+:1];              / if first question, just send out question and +1 counter
  .test.ctr>=count .quiz.d;[.quiz.evaluate[];.quiz.quizover[]];   / if ctr>number of questions, evaluate and end the quiz
  .quiz.cont[x]                                                   / otherwise continue with quiz
  ]
 }

.z.ps:{x: -1 _ x;`.quiz.curr_ans_tab upsert (.z.w;.z.u; x)}       / remove /n from string, upsert it to current ans table

\d .
/ call start[10] for 10 seconds for each question
start:{system"t ",string x*1000}
                                         
