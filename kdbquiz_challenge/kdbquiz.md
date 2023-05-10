# KDB+ Quiz 

## Preresequites: 
- KDB+ questions in a predefined dictionary that can be loaded in 
 
## Problem Definition: 

This problem is to create a kdb+ quiz system that sends out questions about kdb to its users at timed intervals, can receive each user’s answer to correct, and tallies up the scores to finally present a winner at the end of the quiz.  

The idea is to have the entirety of the quiz system to be set up on a port such that the users can connect to it. Everything would be done server side and all the user has to do is type the answers into the console when the questions show up on their screen.  

The methods that the quiz system will have will be functionality to send questions to the users on a timed basis, to handle the answers that are received back from the users by comparing them to the right answers, and to keep track of each user’s score to be able to provide a scoreboard at the end. The end result will be a quiz system that can be started by a command and will run fully through by itself to the presentation of the end scores. 

## Task: To create a kdb+ Quiz System 

- Set up a process on a port that the users can connect to. 
- Create a table that will track information of the connected users to the quiz. 
- Send the questions from a predefined dictionary to the users at set time intervals. 
- Handle the user input such that they will type into the console, and it will be sent to server automatically. 
- Check answers as they come in and keep track of the scores. 
- At the end calculate the winner and send them a message of congratulations.
