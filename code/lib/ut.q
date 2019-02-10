///
// General Utility
// ______________________________________________

.ut.isSym:{ -11h = type x };
.ut.isChar:{ -10h = type x };
.ut.isString:{ 10h = type x };
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

.ut.iso.cmap:(23;22;20)!("0Z";"00Z";".000Z");
.ut.iso2Q:{ "Z"$ $[24<>ct:count x;ssr[x;"Z";.ut.iso.cmap ct];x]};
.ut.q2ISO:{[qtime]
  if[not (typ: type qtime) in (-12h;-15h);'"datetime or timestamp expected"];
  if[-15h = typ;qtime:"p"$qtime];
  iso:-10 _ .h.iso8601 "j"$qtime;
  iso};

.ut.epoch.secondsInDay:24 * 60* 60;
.ut.epoch.dateTimeDiff:(`datetime$2000.01.01)-(`datetime$1970.01.01);
.ut.epoch2Q:{`datetime$(x % .ut.epoch.secondsInDay) - .ut.epoch.dateTimeDiff}

///
// Parameter Registration API
// ______________________________________________

.ut.params.registerRequired:{[component; name; descr]
  param:enlist each `component`name`val`required`descr!(component;name;`;1b;`$descr);
  .ut.params.priv.registered:.ut.params.priv.registered,2!flip param;
  .ut.params.priv.updateFromEnv[component; name];
  };

.ut.params.registerOptional:{[component; name; default; descr]
  param:enlist each `component`name`val`required`descr!(component;name;default;0b;`$descr);
  .ut.params.priv.registered:.ut.params.priv.registered,2!flip param;
  .ut.params.priv.updateFromEnv[component; name];
  };

.ut.params.get:{[component_]
  // Assert component exist
  if[exec not component_ in component from .ut.params.priv.registered; 'InvalidComponent];
  // Assert non-null required
  missing:exec name from .ut.params.priv.registered where component = component_, required, .ut.isNull'[val];
  // Signal if missing
  if[0<>count missing;
    '`$"ERROR: Missing required params (", string[component_],"): ",", " sv string missing];
  // Return name->value dict
  params:exec name!.ut.raze'[val] from .ut.params.priv.registered where component=component_;
  params};

.ut.params.set:{[names; values]
  names:.ut.enlist[names];
  values:.ut.enlist[values];
  // Match names to values (can be on to many)
  setting:names!$[(1 = count names) and 1 < count values; enlist values; values];
  // Select params with name, set new values, and get types
  params:select component, name, val:setting name, ty:type each val from .ut.params.priv.registered where name in names;
  // For each param row
  { // Attempt to cast
    x[`val]:.[$;(abs x`ty; x`val);{x`val}[x]];
    // Conform if list
    if[.ut.isList x`ty; x[`val]:.ut.enlist x`val];
    // Update
    .ut.params.priv.update[x`component; x`name; x`val];
  } each params;
  };

.ut.params.priv.registered:([component:`symbol$(); name:`symbol$()] val:(); required:`boolean$(); descr:`symbol$());

.ut.params.priv.update:{[component_; name_; val_]
  // Get the old param row as a dict
  param:exec from `.ut.params.priv.registered where component = component_, name = name_;
  // Remove the old param (facilitates atom -> list type change)
  delete from `.ut.params.priv.registered where component = component_, name = name_;
  // Set the new param value
  param[`val]:val_;
  // Convert the param dict into a table
  param:2!enlist param;
  // Join the new 'param' table with the existing table
  .ut.params.priv.registered,:param;
  };

.ut.params.priv.updateFromEnv:{[component; name]
  param:getenv name;

  if[.ut.isNull param; :0];

  if[1<count param; param:string .ut.raze `$"|" vs param];

  typ:.ut.type .ut.params.priv.registered[component,name; `val];
  param:typ[`chr]$param;

  .ut.params.priv.update[component; name; param];
  };

