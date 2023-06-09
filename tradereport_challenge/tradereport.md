# Trade Report 

## Preresequites: 
- fakedb.q script  
- fxrates.csv and symstatic.csv files 
 
## Problem definition: 

This challenge will have several requirements, with the end goal of creating a script 
that will query a database and generate a report as a csv file. As a prerequisite you will 
need to start a q process, create a HDB of 10 days using the fakedb.q script, and set the process 
listening on a port where the HDB is loaded in. You should also download tradereport.zip and extract it into your working directory. The tradereport folder contains two CSV files; symstatic and fxrates, that the script will need to load in. 

## Task: Deliver functionality which can, with a user input of two dates: 
- Open a connection to the HDB process. If the connection fails, return an error message “Failed to connect to HDB:” along with a string of the error result. 
- Query the HDB via IPC for the range of inputted dates, returning ntrade (number of trades), total size traded and turnover (sum of price X size) by date and sym from the trades table.  
- Join the table loaded in from the symstatic.csv file onto the table above (The column types for the symstatic.csv should be symbol, string and symbol respectively). 
- Load the fxrates.csv file into a table with column types; date, symbol and float respectively and again join onto the table above by date and curr (Note that fxrates only contains fx rates for EUR and GBP -> set rateUSD  to be 1 where the sym’s currency is already in USD). 
- Generate a trade report table by converting the turnover to USD. 
- Finally, save the trade report as a CSV file, and add functionality to send an email with the trade report attached (hint: System commands).  

## Optional extras: 
- Check the date input and if there aren’t two dates, query across a set, hardcoded date range. 
- Add logging messages including the current timestamp and a brief description of the steps above. 
- Modify the script to save the CSV file as tradereport_YYYYMMDD_YYYYMMDD.csv where the dates appended are the start and end dates provided.  
