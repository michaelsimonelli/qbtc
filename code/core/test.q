.app.import[`log]
.app.import[`util];
.app.import[`extendpy];
.app.import[`websocket];

.py.import[`cbpro];
.py.reflect[`cbpro;`.cbpro];

.ut.params.registerOptional[`cb; `CBPRO_ENV;             `dev; "Execution environment"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_KEY;        `;    "API private key"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_SECRET;     `;    "API private secret"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_PASSPHRASE; `;    "API private passphrase"];


.qb.api.get_products:{[func;x]
  //.qb.cli.assertInit[];
  products:func[];
  products:{ { $[.ut.isNull x; "";] x }each x} each products;
  products:@[products;`sym;:;`$,/'[flip products`base_currency`quote_currency]];
  `sym xkey "SSSFFFSSbSFFbbb*"$/:products};

.qb.api.get_currencies:{[func;x]
  currencies:func[];
  currencies:@[(uj/)(enlist each currencies);`message;string];
  1!"SSFSC**"$/:currencies};

.qb.api.get_product_24hr_stats:{[func;productID]
  stats:func[productID];
  stats:"F"$/:stats;
  stats};
  
.qb.api.get_product_historic_rates:{[func;productID;start;end;granularity]; 
  kwargs:`start`end`granularity!(.ut.q2ISO each (start;end)),granularity;
  rates:func[productID;pykwargs kwargs];
  rates};

.qb.api.get_product_historic_rates:{[func;productID]
  ticker:func[productID];
  "jFFZFFF"$(ticker)};

.qb.api.get_product_trades:{[func;productID;indexed]; 
  indexed:$[.ut.isNull indexed;`;(indexed 0) pykw (indexed 1)];
  trades:func[productID;indexed];
  res:-1 _ .py.builtins.list[trades];
  res:@[res;`time;{
        { rep:(23;22;20)!("0Z";"00Z";".000Z");
          $[24<>ct:count x;ssr[x;"Z";rep ct];x]}'[x]}];
  "ZjFFS"$/:res};


// Import required components
// view `.app.imported` to see list of all imported components
.app.import[`extendpy];
.app.import[`websocket];

// Import and reflect cbpro python module
.py.import[`cbpro];
.py.reflect[`cbpro; `qoinbase];

// Register parameters
.ut.params.registerOptional[`qb; `APP_ENV;           `dev; "Application environment - dictates client/trade/execution platform"];
.ut.params.registerOptional[`qb; `CBPRO_API_KEY;        `; "Coinbase Pro API key"];
.ut.params.registerOptional[`qb; `CBPRO_API_SECRET;     `; "Coinbase Pro API secret"];
.ut.params.registerOptional[`qb; `CBPRO_API_PASSPHRASE; `; "Coinbase Pro API passphrase"];

///
// Application environment
// Defaults to dev
// ** DEV STRONGLY RECOMMENDED **
// *** This client can execute LIVE trades ***
.qb.ENV:.ut.params.get[`qb]`APP_ENV;

///
// Live environment flag;
.qb.live:.qb.ENV=`live;

///
// Place holder for client 'instance'
// It is possible to create multiple clients on a single process, but this guide will maintain 1:1 
.qb.client:(::);

///
// Default access level unless authentication is provided
.qb.authenticated:0b;

///
// Initializes the coinbase pro client
.qb.cli.init:{[]
  params:.ut.params.get[`qb];

  url:$[.qb.ENV=`live;
    "https://api.pro.coinbase.com";
      "https://api-public.sandbox.pro.coinbase.com"];
 
  auth:params[`CBPRO_API_KEY`CBPRO_API_SECRET`CBPRO_API_PASSPHRASE];

  // Tries to initialize authenticated client, falls back to public on error
  .qb.client:.[.qb.cli.auth; (auth; url); .qb.cli.authError[url;]];

  // Generate ref data
  .qb.ref.products:.qb.api.getProducts[];
  .qb.ref.productIDMap:exec id!sym from .qb.ref.products;

  // Generate authenticated data
  if[.qb.authenticated;
    .qb.ref.accounts:.qb.api.getAccounts[];

  ];

  };

///
// Manual wrapper to init public client
.qb.cli.PC:{[url]
  url:(enlist `api_url)!enlist url;
  client:qoinbase.PublicClient[url];
  client};

///
// Manual wrapper to init authenticated client
.qb.cli.AC:{[privKey; secret; passphrase; url]
  auth:(privKey;secret;passphrase);
  client:.qb.cli.auth[auth; url];
  client};

///
// Attempts to create an authenticated client
// Spawns a public client as a fail over mechanism 
.qb.cli.auth:{[auth; url]
  api_url:(enlist `api_url)!enlist url;
  cli_arg:(auth, enlist api_url);
  client:@[qoinbase.AuthenticatedClient; cli_arg; .qb.cli.priv.authError[url;]];

  if[not `get_accounts in key client;
    :client];

  auth_test:client[`get_accounts][];

  if[.ut.isDict auth_test;
    :.qb.cli.priv.authError[url; first auth_test]];

  .qb.authenticated:1b;

  client};

///
// Error traps .qb.cli.auth
// Creates a public client
.qb.cli.priv.authError:{[url;error]
  errorLog:"Client authentication failed with: ", error;
  
  -1 errorLog;
  -1 "Defaulting to public client";
  
  client:.qb.cli.PC[url];
  client};

///
// Asserts .qb.client as been initialized
.qb.cli.priv.assertInit:{[] 
  .ut.assert[not .qb.client~(::);"Requires .qb.client to be initialized"]; 
  };

///
// Asserts .qb.client as been authenticated
.qb.cli.priv.assertAuth:{[] 
  .qb.cli.priv.assertInit[]; 
  .ut.assert[.qb.authenticated;"Requires .qb.client to be authenticated"]; 
  };

///
// Builds API endpoint
// based on current app environment
//
// parameters:
// api [symbol] - type of API to access (trade or feed)
//
// returns:
// route [string] - API endpoint URL
.qb.api.endpoint:{[api]
  htp:"https://";
  dom:".pro.coinbase.com";
  url:(`trade`feed!("api";"ws-feed"))[api],(enlist "-public.sandbox")[.qb.live];
  route:(htp,url,dom);
  route};

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

///
// Get a list of available currency pairs for trading
//
// returns:
// products [ktable] - product reference data
.qb.api.get_products:{[func;x]
  //.qb.cli.assertInit[];
  products:func[];
  products:{ { $[.ut.isNull x; "";] x }each x} each products;
  products:@[products;`sym;:;`$,/'[flip products`base_currency`quote_currency]];
  `sym xkey "SSSFFFSSbSFFbbb*"$/:products};

.qb.api.get_currencies:{[func;x]
  currencies:func[];
  currencies:@[(uj/)(enlist each currencies);`message;string];
  1!"SSFSC**"$/:currencies};

.qb.api.get_product_24hr_stats:{[func;productID]
  stats:func[productID];
  stats:"F"$/:stats;
  stats};
  
.qb.api.get_product_historic_rates:{[func;productID;start;end;granularity]; 
  kwargs:`start`end`granularity!(.ut.q2ISO each (start;end)),granularity;
  rates:func[productID;pykwargs kwargs];
  rates};

.qb.api.get_product_historic_rates:{[func;productID]
  ticker:func[productID];
  "jFFZFFF"$(ticker)};

.qb.api.get_product_trades:{[func;productID;indexed]; 
  indexed:$[.ut.isNull indexed;`;(indexed 0) pykw (indexed 1)];
  trades:func[productID;indexed];
  res:-1 _ .py.builtins.list[trades];
  res:@[res;`time;{
        { rep:(23;22;20)!("0Z";"00Z";".000Z");
          $[24<>ct:count x;ssr[x;"Z";rep ct];x]}'[x]}];
  "ZjFFS"$/:res};

///
// Get a list of open orders for a product.
//
// parameters:
// sym [symbol] - symbol to request book data (no hyphen, ETHBTC instead of ETH-BTC)
// lvl [int]    - book level
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
.qb.api.get_product_order_book:{[func;sym;level]
  productID:func[sym;`id];
  book:.qb.client.get_product_order_book[productID;1];
  book};

///
// Authenticated Client
// Wrapper functions and operations available to the authenticated client
// * Requires .qb.client to be initialized and authenticated
// To utilize with manual client, point result at .qb.client
// q).qb.client:.qb.cli.AC[auth;url]
// ____________________________________________________________________________

///
// Get a list of trading all accounts
//
// returns:
// accounts [ktable] - list of accounts keyed by currency
.qb.api.getAccounts:{[func;x]
  .qb.cli.assertAuth[];
  accounts:.qb.client.get_accounts[];
  accounts:"SSFFFS"$/:.qb.client.get_accounts[];
  `currency xkey accounts};

///
// Get information for a single account
// Access account by ID or CCY
//
// parameters:
// BY  [symbol] - indicates how to retrieve account info
// arg [symbol] - parameter to use for account retrieval
//
// returns:
// account [dict] - single account information
.qb.api.getAccount:{[BY;arg]
  account:.qb.api.getAccountBy[BY;arg];
  account};
  
///
// Get information for a single account by account ID
//
// parameters:
// accountID [symbol] - account ID
//
// returns:
// account [dict] - single account information
.qb.api.getAccountBy.ID:{[accountID]
  account:.qb.client.get_account[accountID];
  account};

///
// Get information for a single account by currency
//
// parameters:
// ccy [symbol] - account currency
//
// returns:
// account [dict] - single account information
.qb.api.getAccountBy.CCY:{[ccy]
  accountID:.qb.ref.accounts[ccy;`id];
  account:.qb.api.getAccountByID[accountID];
  account};


.qb.api.getAccountHistory:{[BY;arg;func]
  accountID:$[BY=`CCY;.qb.ref.accounts[arg;`id];arg];
  generator:.qb.client.get_account_history[accountID];
  accHstGen:.ut.generate[func;generator];
  accHstGen};

