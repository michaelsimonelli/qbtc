
.app.HOME_DIR:getenv `APP_HOME_DIR;
.app.CODE_DIR:getenv `APP_CODE_DIR;
.app.IMPORTS:`log`util`websocket!`lg`ut`ws;
.app.loaded:();
.app.proc:();

.app.import:{[imp]
  if[imp in .app.loaded; :(::)];
  if[null file:.app.IMPORTS[imp];
    '"invalidImport - chose from: ",", " sv string key .app.IMPORTS];
  dir:.app.CODE_DIR,"/common/";
  path:dir,string[file],".q";
  system "l ", path;
  .app.loaded,:imp;
  };

.app.process:{[proc]
  dir:.app.CODE_DIR,"/core/";
  path:dir,string[proc],".q";
  system "l ", path;
  .app.proc:proc;
  };

.app.import[`util]
.app.import[`util]
.app.import[`util]

.cb.load
f:"/" sv (getenv `CBPRO_LIBR;"py.q")
.py.import[`cbpro];
.py.reflect[`cbpro];

`APP_HOME_DIR setenv "/home/mike/shadow/cbpro"
`APP_CODE_DIR setenv "/home/mike/shadow/cbpro/code"
`REFLECTION_PY setenv "/home/mike/shadow/cbpro/code/lib/reflect.p"
export REFLECTION_PY="$APP_CODE_DIR/lib/reflect.p"
CBPRO_HOME 
system "echo $PWD"

.ut.params.registerOptional[`cb; `CBPRO_ENV;             `dev; "Execution environment"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_KEY;        `;    "API private key"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_SECRET;     `;    "API private secret"];
.ut.params.registerOptional[`cb; `CBPRO_PRIV_PASSPHRASE; `;    "API private passphrase"];

url:"wss://ws-feed.pro.coinbase.com"

.Q.hap hsym `$url

sturl:{(":"=first x)_x:$[-11=type x;string;]x} 
hsurl:{hsym $[10=type x;`$;]x}   
prsu:{.Q.hap[x z]y}[$[.z.K<3.6;hsurl;sturl]] 
.Q.hap hsurl url

.ws.hap:{[url]
  if[not 10h = type url; '"URL must string"];
  .Q.hap $[.z.K<3.6;hsym `$;]url};

.ws.hap url
.py.mod`cbpro

.py.mod.cbpro

.cbpro.PC:.py.mod.cbpro.PublicClient[]
.cbpro.PC.get_currencies[]
.cbpro.PC.docs_.func[`get_currencies]
.ut.params.update
t
exec from t where component = `cb, name = `CBPRO_ENV
flip 0!f#t
.ut.ktRXD[t;`cb`CBPRO_ENV]
f:enlist k!`cb`CBPRO_ENV
.ut.params.registered
.ut.params.registerd


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

.cb.p2.refData:{[]
  p2:.cb.client.get_products[];
  p2:{ { $[.ut.isNull x; "";] x }each x} each p2;
  p2:@[p2;`sym;:;`$,/'[flip p2`base_currency`quote_currency]];
  `sym xkey "SSSFFFSSbSFFbbb*"$/:p2};

.cb.p2.order_book:{[sym]
  p2ID:.cb.p2.ref[sym;`id];
  .cb.client.get_product_order_book[p2ID]
  };

.cb.acc.data:.cb.acc.upd[];

.cb.p2.ref:.cb.p2.refData[];

.cb.p2.idmap:exec id!sym from .cb.p2.ref;
