





get_currencies            
get_product_24hr_stats    
get_product_historic_rates
get_product_order_book    
get_product_ticker        
get_product_trades        
get_products              
get_time                  


q)key `.qoinbase
q)sdf


.py.meta[`cbpro;`classes;`PublicClient;`attributes;`functions;`$"__init__";`parameters]

///////////////////////////////////////
// TRADE API FUNCTIONS               //
///////////////////////////////////////
//
// Few simple utility and accessibility functions for exploring 
// the basics of the underlying library and q integration.
//
// * For documentation and full functionality of the underlying library
// see: https://github.com/danpaquin/coinbasepro-python
//
// * For the full coinbase pro API documentation
// see: https://docs.pro.coinbase.com/
// ____________________________________________________________________________

///
// Public Client
// Wrapper functions and operations available to the public client
// * Requires .qb.client to be initialized
// To utilize with manual client, point result at .qb.client
// q).qb.client:.qb.cli.PC[url]
// ____________________________________________________________________________

// Create a public client
.qb.PC:.qoinbase.PublicClient[]
.qb.PC.url[]

.qb.PC.docs_[`vars]

.qb.api.getCurrencies:{[]
  currencies:.qb.PC.get_currencies[];
  ccys:(uj/)(enlist each `message`details _/: currencies);
  ccys[`typ]:{x[`details]`type} each currencies;
  ccys:1!"SSFSSS"$/:ccys;
  ccys};

.qb.ccy.data:.qb.api.getCurrencies[];

///
// Get a list of available currency pairs for trading
//
// returns:
// products [ktable] - product reference data
.qb.api.getProducts:{[]
  products:.qb.PC.get_products[];
  p2:"SSSFFFSSbFFbbb"$/:`status_message`accessible _/: products;
  p2:`sym xkey @[p2;`sym;:;.Q.id'[p2`id]];
  p2};

.qb.PC.get_products[]

.qb.p2.data:.qb.api.getProducts[];
.qb.p2.nrml:{s:.Q.id $[.ut.isString x; `$; ]x;.qb.p2.data[s;`id]};

.qb.api.getProduct24hrStats:{[productID]
  pid:.qb.p2.nrml[productID];
  stats:.qb.PC.get_product_24hr_stats[pid];
  stats:"F"$/:stats;
  stats};


//.qb.api.getProduct24hrStats[`BTCUSD]

.qb.api.getProductHistoricRates:{[productID;start;end;granularity];
  pid:.qb.p2.nrml[productID]; 
  kwargs:`start`end`granularity!(.ut.q2ISO each (start;end)),granularity;
  rates:.qb.PC.get_product_historic_rates[pid;pykwargs kwargs];
  lhoc:`dt`lo`hi`op`cl`vol!flip .[rates;(::;0);.ut.epoch2Q];
  flip lhoc};

//.qb.api.getProductHistoricRates[`BTCUSD;2018.04.01T08:00:00.000;2018.04.01T09:00:00.000;60]

.qb.api.getProductTrades:{[productID;before;after;limit];
  pid:.qb.p2.nrml[productID]; 
  kwargs:`before`after`limit!(before;after;limit);
  trades:.qb.PC.get_product_trades[pid;pykwargs kwargs];
  res:-1 _ .py.builtins.list[trades];
  res:@[res;`time;{.ut.iso2Q'[x]}];
  res:"zjFFS"$/:res;
  res};

//.qb.api.getProductTrades[`BTCUSD;`;`;`]

.qb.api.getProductTicker:{[productID]
  pid:.qb.p2.nrml[productID];
  tick:.qb.PC.get_product_ticker[pid];
  tick:"jFFZFFF"$tick;
  tick};

//.qb.api.getProductTicker[`BTCUSD]
.qb.PC.get_product_ticker["BTC-USD"]
.qb.api.getTime:{[]
  tm:.qb.PC.get_time[];
  qiso:.ut.iso2Q tm`iso;
  qepoch:.ut.epoch2Q tm`epoch;
  tm[`qiso`qepoch]:(qiso;qepoch);
  tm
  };

//.qb.api.getTime[]

///
// Get a list of open orders for a product.
//
// parameters:
// sym [symbol] - symbol to request book data (no hyphen, ETHBTC instead of ETH-BTC)
// level [int]    - book level
//
// note:
// The amount of detail shown can be customized with the `level`
// levels:
//  1: Only the best bid and ask
//  2: Top 50 bids and asks (aggregated)
//  3: Full order book (non aggregated)
// Level 1 and Level 2 are recommended for polling. For the most
// up-to-date data, consider using the websocket stream.
//
// returns:
// book [dict] - list of bid, ask orders (price; size; num-orders) at requested level
//  sequence| 603223 
//  bids    | ,("0.031";"3.76039452";1)
//  asks    | ,("0.98999";"16703.58801245";6)
.qb.api.getProductOrderBook:{[productID;level]
  pid:.qb.p2.nrml[productID];
  book:.qb.PC.get_product_order_book[pid;level];
  cast:$[level<3;"FFj";"FFG"];
  book:@[book;`bids;cast$/:];
  book:@[book;`asks;cast$/:];
  book};


//.qb.api.getProductOrderBook[`BTCUSD;1]
//.qb.api.getProductOrderBook[`BTCUSD;2]
//.qb.api.getProductOrderBook[`BTCUSD;3]