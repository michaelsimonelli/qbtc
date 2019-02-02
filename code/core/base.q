\l lib/py.q
.app.import[`log]
.app.import[`util]
.app.import[`websocket]

.py.import[`cbpro];
.py.reflect[`cbpro];

.ut.params.registerOptional[`cb; `CBPRO_ENV;             `dev; "Execution environment"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_KEY;        `;    "API private key"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_SECRET;     `;    "API private secret"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_PASSPHRASE; `;    "API private passphrase"];

.cb.cli.PC:{[url]
  url:(enlist `api_url)!enlist url;
  client:.pq.cbpro.PublicClient[url];
  client};

.cb.cli.AC:{[privKey; secret; passphrase; url]
  auth:(privKey;secret;passphrase);
  client:.cb.cli.auth[auth; url];
  client};

.cb.cli.init:{[]
  params:.ut.params.get[`cb];

  .cb.cli.env:params[`CBPRO_ENV];

  .cb.cli.api_url:$[.cb.cli.env=`live;
                    "https://api.pro.coinbase.com";
                      "https://api-public.sandbox.pro.coinbase.com"];
 

  auth:params[`CBPRO_PRIV_KEY`CBPRO_PRIV_SECRET`CBPRO_PRIV_PASSPHRASE];

  // Tries to initialize authenticated client, defaults to public on error
  .cb.client:.[.cb.cli.auth; (auth; .cb.cli.api_url); .cb.cli.authError[.cb.cli.api_url;]];

  };

.cb.cli.auth:{[auth; url]
  api_url:(enlist `api_url)!enlist url;
  cli_arg:(auth, enlist api_url);
  client:@[.pq.cbpro.AuthenticatedClient; cli_arg; .cb.cli.authError[url;]];

  if[not `get_accounts in key client;
    :client];

  auth_test:client[`get_accounts][];

  if[.ut.isDict auth_test;
    :.cb.cli.authError[url; first auth_test]];

  client};


// On authentication error, return public client
.cb.cli.authError:{[url;error]
  errorLog:"Client authentication failed with: ", error;
  
  -1 errorLog;
  -1 "Defaulting to public client";
  
  client:.cb.cli.PC[url];
  client};

// Public Client

.cb.p2.refData:{[]
  p2:.cb.client.get_products[];
  p2:{ { $[.ut.isNull x; "";] x }each x} each p2;
  p2:@[p2;`sym;:;`$,/'[flip p2`base_currency`quote_currency]];
  `sym xkey "SSSFFFSSbSFFbbb*"$/:p2};

.cb.p2.order_book:{[sym]
  p2ID:.cb.p2.ref[sym;`id];
  .cb.client.get_product_order_book[p2ID]
  };


.cb.p2.ref:.cb.p2.refData[];

.cb.p2.idmap:exec id!sym from .cb.p2.ref;


// Authenticated Client

.cb.getAccounts:{[]
  accs:.cb.client.get_accounts[];
  .ut.isTable accs
  accs:"SSFFFS"$/:.cb.client.get_accounts[];
  `currency xkey accs
.cb.getAccountsError:{[error]
  errorLog:"Client authentication failed with: ", error;
  -1 errorLog;
  -1 "Defaulting to public client";
  .cb.client:.pq.cbpro.PublicClient[]
  .cb.access:`PUBLIC;
  };


.cb.acc.upd:{[]
  accs:"SSFFFS"$/:.cb.client.get_accounts[];
  `currency xkey accs};

.cb.acc.get:{[accID]
  .cb.client.get_account[accID]
  };

.cb.acc.page:{[accID]
  accPage:.cb.client.get_account_history[accID];
  pager:{[x;pager].py.next[x]}accPage
  pager};

.cb.acc.history:{[accID]
  accPage:.cb.client.get_account_history[id];
  accHist:"ZjFFS*"$/:`time`id`amount`balance`typ`details xcol .py.list[accPage];
  accHist};

.cb.acc.data:.cb.acc.upd[];
