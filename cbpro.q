\l ut.q
\l py.q
\c 1000 1000

.py.import[`cbpro];

.ut.params.registerOptional[`cb; `CBPRO_ENV;             `dev; `dev`live; "Execution environment"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_KEY;        `;     `;        "API private key"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_SECRET;     `;     `;        "API private secret"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_PASSPHRASE; `;     `;        "API private passphrase"];

.cb.endpoints.api:.ut.dict (
  (`live;"https://api.pro.coinbase.com");
  (`dev;"https://api-public.sandbox.pro.coinbase.com"));

.cb.endpoints.feed:.ut.dict (
  (`live;"wss://ws-feed.pro.coinbase.com");
  (`dev;"wss://ws-feed-public.sandbox.pro.coinbase.com"));

.cb.auth.env:{[params]
  if[.ut.isNull params;
    params:.ut.params.get`cb];

  envVar:`CBPRO_PRIV_KEY`CBPRO_PRIV_SECRET`CBPRO_PRIV_PASSPHRASE;
  if[any missEnvVar:.ut.isNull each params[envVar];
    evStr:", " sv string envVar where missEnvVar;
    '"Missing parameters to authenticate from environment: ",evStr];

  auth:params[envVar];
  auth};

.cb.auth.arg:{[privKey;secret;passphrase]
  auth:(privKey;secret;passphrase);
  auth};

.cb.app.init:{[]
  params:.ut.params.get[`cb];

  .cb.app.env:params[`CBPRO_ENV];

  .cb.api.url:.cb.endpoints[`api;.cb.app.env];
  .cb.feed.url:.cb.endpoints[`feed;.cb.app.env];

  auth:.cb.auth.env[];
  .cb.client:.pm.cbpro.AuthenticatedClient[auth];

  if[.cb.app.env=`dev;
    .cb.client.pset[`url;.cb.api.url]];
  };


.feed.productCache:{[]
  p:.cb.client.get_products[];
  t:exec c!t from meta p;
  p:{[t;p]
    k:where null t;
    v:{$[.ut.isNull x;"";x]} each p[k];
    p[k]:v;
    p}[t]'[p];
  update sym:`$(string[base_currency],'string[quote_currency]) from "SSSFFFSSbSFFbbb"$/:p
  };


\l init.q
.feed.upd:{
  e:.j.k x;
  t:`$e`type;
  0N!e;
  if[t in key .evt;
    .evt[t]e];
  }

.cb.init.main:{[]
  params:.ut.params.get[`cbpro];

  .book.init[];
  
  auth:params[`CBPRO_PRIV_KEY`CBPRO_PRIV_SECRET`CBPRO_PRIV_PASSPHRASE];

  .cb.client:.cbpro.AuthenticatedClient[auth];
  .cb.client.pset[`url;.api.url];

  .feed.refdata:.feed.productCache[];
  .admin.accounts:"SSFFFS"$/:.cb.client.get_accounts[];

  .feed.handle:.ws.open[.feed.url;`.feed.upd;`];

  .feed.sub[.feed.handle;.feed.products;.feed.channels];
  
  };





.cbpro.getAccounts:{
  accs:"SSFFFS"$/:client.get_accounts[];
  accs};

.cbpro.getAccountHistory:{[accountId]
  accPage:client.get_account_history[accountId];
  accHist:"ZjFFS*"$/:`time`id`amount`balance`typ`details xcol .py.list[accPage];
  accHist};


ethusd:`$"ETH-USD";
btcusd:`$"BTC-USD";
ethbtc:`$"ETH-BTC";
stpRisk:0.025;
lmtRisk:0.05;

.cbpro.autoHedge:{[sym;side;price;size;dargs]
  if[not side in `buy`sell;'`$"bad side argument"];

  fn:$[side=`sell;+;-];
  ad:fn[1;] each (stpRisk;lmtRisk);
  px:price*(ad);
  sp:string .ut.round[2]px[0];
  lp:string .ut.round[2]px[1];
  ord:.cbpro.client.place_limit_order[sym;side;price;size];
  stp:.cbpro.stopLimit[sym;side;sp;size;lp;`];
  (ord;stp)};

.cbpro.stopLimit:{[sym;side;stop_price;size;limit_price;dargs]
  if[not side in `buy`sell;'`$"bad side argument"];
  
  kw:`product_id`order_type`type`stop`stop_price`size`price!
  (sym;`stop;`limit;`;stop_price;size;limit_price);

  kw[`stop]:$[side=`sell;`loss;`entry];
  if[not .ut.isNull dargs;kw,:dargs];
  
  .cbpro.client[side][pykwargs kw]
  };


o:.cbpro.autoHedge[ethusd;`sell;268.55;0.25;`]