.ut.isSym:{-11h = type x};
.ut.isAtom:{(0h > type x) and (-20h < type x)};
.ut.isList:{(0h <= type x) and (20h > type x)};
.ut.isGList:{0h = type x};
.ut.isTable:{.Q.qt x};
.ut.isDict:{$[99h = type x;not .ut.isTable x; 0b]};
.ut.isMulti:{@[{$[10h=type x[;0];0b;1b]};x;{0b}]};
.ut.isNull:{$[.ut.isAtom[x] or .ut.isList[x] or x ~ (::); $[.ut.isGList[x]; all .ut.isNull each x; all null x]; .ut.isTable[x] or .ut.isDict[x];$[count x;0b;1b];0b ]};
.ut.enlist:{$[not .ut.isList x;enlist x; x]};
.ut.repeat:{(.ut.enlist x)!count[x]#enlist[y]};
.ut.round:{("j"$y*x) % x:xexp[10]x};
.ut.raze:{$[.ut.isList x;[tmp:raze x;$[1=count tmp;first tmp;tmp]];x]};
.ut.dict:{(!/) flip $[not .ut.isMulti x; enlist;]x};
.ut.table:{x[0]!/:1_x};
.ut.ktRXD:{k:keys x;v:enlist'[y];w:(=),'(k,'enlist'[v]);r:?[x;w;();()];r};
.ut.ktDel:{k:keys x;v:enlist'[y];w:$[1=count y;enlist(=;first k;v);(=),'(k,'enlist'[v])];r:![x;w;0b;`symbol$()];r};
.ut.filter:{[l;fn] l where fn l};

.ut.typ.nums:raze@[2#enlist 5h$where" "<>20#.Q.t;0;neg];
.ut.type.vector:1!.ut.table (enlist(`name;`num;`char)),flip{(key'[x$\:()];x;.Q.t x)}.ut.filter[.ut.typ.nums;{x>0}];
.ut.type.atom:1!.ut.table (enlist(`name;`num;`char)),flip{(key'[x$\:()];x;upper .Q.t abs x)}.ut.filter[.ut.typ.nums;{x<0}];
.ut.type.ref:(lj/){t:` sv `.ut.type, x;v:value t;c:`$"_" sv'string x,'1_cols t;r:(`name,c)xcol v;r}each `atom`vector;
.ut.type.map:1!.ut.table (enlist(`num;`char;`name)),flip{(x;?[x<0;upper .Q.t abs x;.Q.t x];key'[x$\:()])}.ut.typ.nums;

.ut.params.registered:([component:`symbol$(); name:`symbol$()] val:(); required:`boolean$(); default:(); combo:(); descr:`symbol$());

.ut.params.registerRequired:{[component;name;typ;combo;descr]
  param:enlist each `component`name`val`required`default`combo`descr!(component;name;`;1b;`;enlist combo;`$descr);
  .ut.params.registered,:2!flip param;
  .ut.params.updateFromEnv[component;name;typ];
  };

.ut.params.registerOptional:{[component;name;typ;default;combo;descr]
  param:enlist each `component`name`val`required`default`combo`descr!(component;name;`;0b;default;enlist combo;`$descr);
  .ut.params.registered,:2!flip param;
  .ut.params.updateFromEnv[component;name;typ];
  };

.ut.params.update:{[component_;name_;val_]
  param:.ut.ktRXD[.ut.params.registered;(component_;name_)];
  .sim.val:val_;
  .sim.param:param;
  if[not .ut.isNull c:.ut.raze param[`combo];
    if[not val_ in c; 
      '`$"ERROR: Value needs to be in combo list"];
  ];

  .ut.ktDel[`.ut.params.registered;(component_;name_)];

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
