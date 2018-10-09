\l init.q
.py.import[`cbpro];

.ut.params.registerOptional[`cbpro;`CBPRO_ENV;`;`dev;`dev`live;"Execution environment"];
.ut.params.registerRequired[`cbpro;`CBPRO_PRIV_KEY;`;`;"API private key"];
.ut.params.registerRequired[`cbpro;`CBPRO_PRIV_SECRET;`;`;"API private secret"];
.ut.params.registerRequired[`cbpro;`CBPRO_PRIV_PASSPHRASE;`;`;"API private passphrase"];

.feed.productCache:{[]
  p:client.get_products[];
  t:exec c!t from meta p;
  p:{[t;p]
    k:where null t;
    v:{$[.ut.isNull x;"";x]} each p[k];
    p[k]:v;
    p}[t]'[p];
  update sym:`$(string[base_currency],'string[quote_currency]) from "SSSFFFSSbSFFbbb"$/:p
  };

.cb.init.main:{[]
  params:.ut.params.get[`cbpro];

  .book.init[];
  
  auth:params[`CBPRO_PRIV_KEY`CBPRO_PRIV_SECRET`CBPRO_PRIV_PASSPHRASE];

  client:.cbpro.AuthenticatedClient[auth];
  client.pset[`url;.api.url];

  .feed.refdata:.feed.productCache[];
  .admin.accounts:"SSFFFS"$/:client.get_accounts[];

  .feed.handle:.ws.open[.feed.url;`.feed.upd;`];

  .feed.sub[.feed.handle;.feed.products;.feed.channels];
  
  };
  
.feed.upd:{
  e:.j.k x;
  t:`$e`type;
  0N!e;
  if[t in key .evt;
    .evt[t]e];
  }

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