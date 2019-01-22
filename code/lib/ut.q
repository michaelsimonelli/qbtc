
.ut.isSym:{ -11h = type x };
.ut.isChar:{ -10h = type x };
.ut.isString:{ 10h = type x };
.ut.isAtom:{ (0h > type x) and (-20h < type x) };
.ut.isList:{ (0h <= type x) and (20h > type x) };
.ut.isRList:{ (type x) in (5h$til 20)_10 };
.ut.isGList:{ 0h = type x };
.ut.isTable:{ .Q.qt x };
.ut.isDict:{ $[99h = type x;not .ut.isTable x; 0b] };
.ut.isNested:{ all in\:[type each x;(5h$til 20)_10] };
.ut.isNull:{ $[.ut.isAtom[x] or .ut.isList[x] or x ~ (::); $[.ut.isGList[x]; all .ut.isNull each x; all null x]; .ut.isTable[x] or .ut.isDict[x];$[count x;0b;1b];0b ] };
.ut.strToSym:{ if[any .ut[`isRList`isDict]@\:x; :.z.s'[x]]; $[any .ut[`isString`isChar]@\:x; `$x; x] };
.ut.toSym:{if[any .ut[`isRList`isDict]@\:x; :.z.s'[x]]; $[not any .ut[`isString`isChar]@\:x;`$ string x;`$x] };
.ut.enlist:{ $[not .ut.isList x;enlist x; x] };
.ut.raze:{ $[.ut.isList x; [tmp:raze x; $[1 = count tmp; first tmp; tmp] ]; x] };
.ut.repeat:{ (.ut.enlist x)!count[x]#enlist[y] };
.ut.filter:{ [l;fn] l where fn l };
.ut.round:{ ("j"$y*x) % x:xexp[10]x };
.ut.dict:{ (!/) flip $[not .ut.isNested x; enlist;]x };
.ut.table:{ x[0]!/:1_x };
.ut.eachKV:{key [x]y'x};

.ut.typ.nums:raze@[2#enlist 5h$where" "<>20#.Q.t;0;neg];
.ut.type.vector:1!.ut.table (enlist(`name;`num;`char)),flip{(key'[x$\:()];x;.Q.t x)}.ut.filter[.ut.typ.nums;{x>0}];
.ut.type.atom:1!.ut.table (enlist(`name;`num;`char)),flip{(key'[x$\:()];x;upper .Q.t abs x)}.ut.filter[.ut.typ.nums;{x<0}];
.ut.type.ref:(lj/){t:` sv `.ut.type, x;v:value t;c:`$"_" sv'string x,'1_cols t;r:(`name,c)xcol v;r}each `atom`vector;
.ut.type.map:1!.ut.table (enlist(`num;`char;`name)),flip{(x;?[x<0;upper .Q.t abs x;.Q.t x];key'[x$\:()])}.ut.typ.nums;
.ut.type.info:{ t:type x; m:.ut.type.map[t]; m };

.ut.params.registered:([component:`symbol$(); name:`symbol$()] val:(); required:`boolean$(); combo:(); descr:`symbol$());

.ut.params.registerRequired:{[component;name;typ;combo;descr]
  param:enlist each `component`name`val`required`combo`descr!(component;name;`;1b;enlist combo;`$descr);
  .ut.params.registered:.ut.params.registered,2!flip param;
  .ut.params.updateFromEnv[component;name;typ];
  };

.ut.params.registerOptional:{[component;name;default;combo;descr]
  param:enlist each `component`name`val`required`combo`descr!(component;name;default;0b;enlist combo;`$descr);
  .ut.params.registered:.ut.params.registered,2!flip param;

  typ:.ut.type.info[default]`name;
  .ut.params.updateFromEnv[component;name;typ];
  };

.ut.params.update:{[component_;name_;val_]
  tab:`.ut.params.registered;
  param:exec from tab where component = component_, name = name_;

  delete from tab where component = component_, name = name_;
  if[not .ut.isNull c:.ut.raze param[`combo];
    if[not val_ in c; 
      '`$"ERROR: Value needs to be in combo list"];
  ];

  param[`val]:val_;

  param:2!enlist param;

  .ut.params.registered,:param;
  };

.ut.params.updateFromEnv:{[component;name;typ]
  param:getenv name;

  if[.ut.isNull param; :0];
  
  if[1<count param; param:string .ut.raze `$"|" vs param];

  paramType:$[.ut.isNull typ;`symbol;typ];
  paramType:.ut.type[`atom;paramType;`char];
  param:paramType$param;
  .ut.params.update[component;name;param];
  };

.ut.params.get:{[component_]
  if[exec not component_ in component from .ut.params.registered;
    `$"ERROR: Invalid component name"];

  missing:exec name from .ut.params.registered where component=component_,required,.ut.isNull'[val];

  if[0<>count missing;
    '`$"ERROR: Missing required params (", string[component_],"): ",", " sv string missing
    ];

  params:exec name!.ut.raze'[val] from .ut.params.registered where component=component_;
  params};


.ut.params.set:{[names;values]
  names:.ut.enlist[names];
  values:.ut.enlist[values];

  setting:names!$[(1 = count names) and 1 < count values; enlist values; values];
  params:select component, name, val:setting name, ty:type each val from .ut.params.registered where name in names;

  {

    x[`val]:.[$;(abs x`ty; x`val);{x`val}[x]];
    if[.ut.isList x`ty; x[`val]:.ut.enlist x`val];
    .ut.params.update[x`component;x`name;x`val]
  } each params;

  };
