# KDB+ Live-Live Table comparison tool 

## Preresequites: 
- Two csv files containing data to be analysed 
- Fakedb.q script for creating the two hdbs 

## Problem Definition: 
When working with data, especially with data that changes day to day, it can be useful to be able to compare data. This problem involves creating a table comparison tool to be able to compare two different tables, first to compare two trade tables and then to expand this to be able to compare two hdb trade tables.  

What we want to compare is the open-high-low-close per sym. The idea is to have a function to call that will take in, for example, the names of the tables to compare and then it will create the two resulting comparison tables as a result.  

The second part of this involves extending this functionality to looking at two different hdb trade tables and then using this comparison data modified to cycle through day by day and choose and save down the “best” day to a new hdb which will then sync the data across to create a single consistent dataset. The “best” day that we will use will be the smallest spread over open/close as this indicates less volatility and more stable data. 

## Task: Deliver a Live-Live Table comparison tool 

### First part 
- Load in the two csv files containing the datasets that we are comparing. 
- Report on and handle the null values how you see fit. 
- Create a function that will get the open-high-low-close by sym of each table and join them to create a comparison table where the same columns are beside each other to make the comparisons easier ie. Open1 open2 high1 high2 etc. 

### Second Part 
- Create two hdbs of 10 days each using the fakedb.q script. 
- Use the function from the previous section as a starting point to create the same comparison table over the trade data of the two hdbs for each day. 
- Using the data from these comparison tables, determine which hdb has the “best” trade data per day by finding which one has the smallest spread over open/close by sym per day. 
- Using this choice, save the “best” day's trade and quote tables down into a new hdb to create a single, consistent dataset that will contain one trade and one quote table for each day. Note: we are only comparing the trade data but saving down both the trade and quote tables of that best day each time. 
