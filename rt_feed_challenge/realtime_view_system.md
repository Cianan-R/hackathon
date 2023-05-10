# Real-time View System 

## Preresequites: 
- Tick.q (streams and publishes data) 
- Client.q (to modify) 
- u.q (has required .u functions) 

## Problem definition: 

This problem deals with the handling and manipulation of live data to provide real-time analysis. These views of tables are calculated and updated at regular intervals. The tick.q script will publish a stream of live data, the .u.q script will contain the required .u functions, and the client.q script is to be modified to query the data for real-time analysis. For this problem, the aim is to create a client.q script that can connect to the tick.q script and subscribe to the relevant data to then perform the given calculations to provide updating tables that can be queried. 
 
## Task: Deliver functionality on a real-time view of streaming data 
- Create the client.q script – this script will need: 
  - A table schema (empty table) for the tables of incoming data (trade and quote) 
  - To open a handle to the port the tick.q script is active on (this port number is hardcoded in the tick.q script and can be changed if that port is not free) 
  - A defined upd function (this function is called whenever data is published from the tick.q script) 
  - A defined .u.sub function (this function is required to subscribe to the required data.) 
- Add functionality in the client.q script to: 
  - Calculate 1-minute TWAP (time weighted average price) by sym from the trades table. 
  - Update the trades table to include two new columns: a position column, where position is the accumulated sum of amount of shares held (for side=buy the position will increase, and oppositely for side=sell the accumulated position will decrease), and a cost column (accumulated price x size) that will decrease the net value if a position is bought, and increase if a position is sold. 
  - Calculate the number of trades that occur more than two times the standard deviation away from the mean price for each exchange and instrument from the trades table. 
