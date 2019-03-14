///
// General Utility
// ______________________________________________

.ut.isSym:{ -11h = type x };
.ut.isStr:{ 10h = type x };
.ut.isChar:{ -10h = type x };
.ut.isAtom:{ (0h > type x) and (-20h < type x) };
.ut.isList:{ (0h <= type x) and (20h > type x) };
.ut.isRList:{ (type x) in (5h$til 20)_10 };
.ut.isGList:{ 0h = type x };
.ut.isTable:{ .Q.qt x };
.ut.isDict:{ $[99h = type x;not .ut.isTable x; 0b] };
.ut.isNull:{ $[.ut.isAtom[x] or .ut.isList[x] or x ~ (::); $[.ut.isGList[x]; all .ut.isNull each x; all null x]; .ut.isTable[x] or .ut.isDict[x];$[count x;0b;1b];0b ] };
.ut.strToSym:{ if[any {(type x) in ((5h$til 20)_10),98 99h}@\:x; :.z.s'[x]]; $[10h = abs type x; `$x; x] };
.ut.enlist:{ $[not .ut.isList x;enlist x; x] };
.ut.raze:{ $[.ut.isList x; [tmp:raze x; $[1 = count tmp; first tmp; tmp] ]; x] };
.ut.repeat:{ (.ut.enlist x)!count[x]#enlist[y] };
.ut.dict:{ (!/) flip $[not all .ut.isRList each x; enlist;]x };
.ut.table:{ x[0]!/:1_x };
.ut.eachKV:{key [x]y'x};
.ut.exists:{x ~ key x};
.ut.assert:{ [x;y] if[not x;'"Assert failed: ",y] };

///
// Type Info
// ______________________________________________

.ut.typ.num:raze@[2#enlist 5h$where" "<>20#.Q.t;0;neg];

.ut.typ.ref:1!.ut.table (enlist(`int;`chr;`sym)),flip{(x;?[x<0;upper .Q.t abs x;.Q.t x];key'[x$\:()])}.ut.typ.num

.ut.type:{ t:type x;((enlist `int)!enlist t),.ut.typ.ref[t] };

///
// Temporal Cast
// ______________________________________________

.ut.iso.cmap:(23;22;20)!("0Z";"00Z";".000Z");

.ut.iso2Q:{ "Z"$ $[24<>ct:count x;ssr[x;"Z";.ut.iso.cmap ct];x]};

.ut.q2ISO:{[qtime]
  if[not (typ: type qtime) in (-12h;-15h);'"datetime or timestamp expected"];
  if[-15h = typ;qtime:"p"$qtime];
  iso:-6 _ .h.iso8601 "j"$qtime;
  iso};

.ut.epoch.secondsInDay:24 * 60* 60;

.ut.epoch.dateTimeDiff:(`datetime$2000.01.01)-(`datetime$1970.01.01);

.ut.epoch2Q:{`datetime$(x % .ut.epoch.secondsInDay) - .ut.epoch.dateTimeDiff}

///
// Parameter Registration API
// ______________________________________________

.app.params.registerRequired:{[component; name; descr]
  param:enlist each `component`name`val`required`descr!(component;name;`;1b;`$descr);
  .app.params.priv.registered:.app.params.priv.registered,2!flip param;
  .app.params.priv.updateFromEnv[component; name];
  };

.app.params.registerOptional:{[component; name; default; descr]
  param:enlist each `component`name`val`required`descr!(component;name;default;0b;`$descr);
  .app.params.priv.registered:.app.params.priv.registered,2!flip param;
  .app.params.priv.updateFromEnv[component; name];
  };

.app.params.get:{[component_]
  // Assert component exist
  if[exec not component_ in component from .app.params.priv.registered; 'InvalidComponent];
  // Assert non-null required
  missing:exec name from .app.params.priv.registered where component = component_, required, .ut.isNull'[val];
  // Signal if missing
  if[0<>count missing;
    '`$"ERROR: Missing required params (", string[component_],"): ",", " sv string missing];
  // Return name->value dict
  params:exec name!.ut.raze'[val] from .app.params.priv.registered where component=component_;
  params};

.app.params.set:{[names; values]
  names:.ut.enlist[names];
  values:.ut.enlist[values];
  // Match names to values (can be on to many)
  setting:names!$[(1 = count names) and 1 < count values; enlist values; values];
  // Select params with name, set new values, and get types
  params:select component, name, val:setting name, ty:type each val from .app.params.priv.registered where name in names;
  // For each param row
  { // Attempt to cast
    x[`val]:.[$;(abs x`ty; x`val);{x`val}[x]];
    // Conform if list
    if[.ut.isList x`ty; x[`val]:.ut.enlist x`val];
    // Update
    .app.params.priv.update[x`component; x`name; x`val];
  } each params;
  };

.app.params.priv.registered:([component:`symbol$(); name:`symbol$()] val:(); required:`boolean$(); descr:`symbol$());

.app.params.priv.update:{[component_; name_; val_]
  // Get the old param row as a dict
  param:exec from `.app.params.priv.registered where component = component_, name = name_;
  // Remove the old param (facilitates atom -> list type change)
  delete from `.app.params.priv.registered where component = component_, name = name_;
  // Set the new param value
  param[`val]:val_;
  // Convert the param dict into a table
  param:2!enlist param;
  // Join the new 'param' table with the existing table
  .app.params.priv.registered,:param;
  };

.app.params.priv.updateFromEnv:{[component; name]
  param:getenv name;

  if[.ut.isNull param; :0];

  if[1<count param; param:string .ut.raze `$"|" vs param];

  typ:.ut.type .app.params.priv.registered[component,name; `val];
  param:typ[`chr]$param;

  .app.params.priv.update[component; name; param];
  };

.app.params.registerOptional[`unused; `MIXED_TYPE;  ("";`); "Unused, Stores a mixed type to ensure safe updates"];

///
// App Entry Point
// ______________________________________________

.app.params.registerRequired[`app; `APP_NAME;        "Application root name"];
.app.params.registerRequired[`app; `APP_HOME_DIR;    "Application home directory"];
.app.params.registerRequired[`app; `APP_CODE_DIR;    "Application code directory"];
.app.params.registerRequired[`app; `APP_CONF_DIR;    "Application config directory"];
.app.params.registerRequired[`app; `APP_CORE_DIR;    "Application core directory"];
.app.params.registerRequired[`app; `APP_LIB_DIR;     "Application lib directory"];

///
// Imports library file
// 
// parameters:
// imp [symbol] - name of library component
.app.import:{[imp]
  if[imp in .app.imported; :(::)];
  if[not imp in l:(key .app.IMPORTS)`imp;
    '"invalidSelection - chose from: ",", " sv string l];

  info: .app.IMPORTS[imp];
  path: $[not null d:info`dir; .cfg.dir[d],"/"; ""],string info`file;

  system "l ", path;
  .app.imported,:imp;
  };

syst
.config.IMPORTS
system "ls ", .cb.dir.lib
///
// Get config file
//
// parameters:
// conf [string] - config file
// cast [string] - data type chars
.app.getConfig:{[conf;cast]
  file: hsym `$.cfg.dir.conf,"/",conf,".csv";
  config:1!(cast;enlist",") 0: file;
  config};

.cfg.dir,:`home`code`conf`logs`core`lib ! getenv each `APP_HOME_DIR`APP_CODE_DIR`APP_CONF_DIR`APP_LOGS_DIR`APP_CORE_DIR`APP_LIB_DIR;

.cfg.endpoints.api: .ut.dict (
  (`live;"https://api.pro.coinbase.com");
  (`sbox;"https://api-public.sandbox.pro.coinbase.com"));

.cfg.endpoints.feed: .ut.dict (
  (`live;"wss://ws-feed.pro.coinbase.com");
  (`sbox;"wss://ws-feed-public.sandbox.pro.coinbase.com"));

.cfg.envmap:`dev`qa`live!(`sbox`sbox`sbox;`sbox`live`live;`live`live`live)

.app.IMPORTS:.cb.getConfig["imports";"SSSS"];

.app.imported:();

.app.params.registerOptional[`cb; `PROC_ENV;       "Configures the various coinbase API environments"];
.app.params.registerRequired[`cb; `PROC_TYPE;      "Process type"];
.app.params.registerRequired[`cb; `PROC_NAME;      "Process name"];
.app.params.registerRequired[`cb; `PROC_PORT;      "Process port"];
.app.params.registerOptional[`cb; `PROC_HOST;  `;  "Process host"];
.app.params.registerOptional[`cb; `PROC_LOG;   `;  "Process log file"];

.app.params.registerRequired[`cb; `CB_REST_API_ENDPOINTS;  "Coinbase REST API environments (live, sandbox)"];
.app.params.registerRequired[`cb; `CB_FEED_API_ENDPOINTS;  "Coinbase feed API environments (live, sandbox)"];
.app.params.registerOptional[`cb; `CB_PRIV_KEY;        `;    "Coinbase auth API private key"];
.app.params.registerOptional[`cb; `CB_PRIV_SECRET;     `;    "Coinbase auth API private secret"];
.app.params.registerOptional[`cb; `CB_PRIV_PASSPHRASE; `;    "Coinbase auth API private passphrase"];


.cb.import[`log];
.cb.import[`expy];
.py.import[`qoinbase];
.py.reflect[`qoinbase];


/ .cb.cfg.endp:.cb.getConfig["endp";"S**"];
/ .cb.cfg.comp:.cb.getConfig["comp";"SSSSB"];

/ .cb.env:{[]

/   };

/ .cb.init:{[]
/   / get params
/   p: .app.params.get[`cb];
/   / get env
/   .cb.ENV: `trade`data!p`TRADE_ENV`DATA_ENV;
/   / build comp config 
/   .cb.COMP: 1!`id`env`api_url`client`auth#{ 
/                 c :.cb.cfg.comp[x];
/                   e :.cb.ENV[c`src];
/                     u :.cb.cfg.endp[c`api; e];
/                       c,`id`env`api_url!(x; e; u) } each `trade`data`feed;


/   .lg.init[p`APP_BASE; p`PROC_LOG];
/   .cb.log:.lg.create[`core];
 
/   };

/ .cb.init[];

/ .cb.import[`feed];


/   / initialize and create logger
/   .lg.init[p]; 
/   .app.log: .lg.create[p`PROC_TYPE];
/   .app.log.info "Launching process with configuration:\n",
/                 "api_env:\n",.Q.s[.app.ENV],"\n",
/                 "imports: ",(", " sv string .app.imported),"\n",
/                 "config:\n",.Q.s select name,val,descr from .app.params.priv.registered;

/   };
/ .app.params.get[`qb]
/ .app.init[];

/ .app.ENV:.qb.ENV