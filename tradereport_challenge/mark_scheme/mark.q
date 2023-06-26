test_tradereport:("DS*SJIJ";enlist",")0: `:/home/crichman/hackathon/tradereport_challenge/tradereport/tradereport.csv;
\c 20 200
sol:`coltypes`colnames!(exec t from meta test_tradereport;cols test_tradereport);
ans:`coltypes`colnames!(exec t from meta tradereport;cols tradereport);
points:sol=ans;
0N!points;
system"cd tradereport";
system"ls"
