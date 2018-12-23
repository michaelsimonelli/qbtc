\l p.q
\l ut.q
\l reflectPy.p

.py.mod:()!();
.py.ref:()!();

///
// Function: import
//  Wrapper around .p.import
//  Auto-maps the python module to native kdb functions
//  Auto-generates module metadata reference dictionary
.py.import:{[module] 
  if[module in key .py.mod;
    -1"Module already imported";
    :(::)];

  imported:@[.py.import0; module; .py.failed[module]];

  if[imported;
    modFmt:"'",string[module],"'";
    -1"Imported python module ", modFmt];
  };

.py.reflect:.p.get[`reflect;<];

.py.getVars:.p.get[`get_inst_attrs;<];

.py.builtin:.p.import[`builtins];

.py.next:.py.builtin[`:next;<];

.py.list:.py.builtin[`:list;<];

.py.it:`$"__init__";

.py.import0:{[module]
  pyMod:.py.mod[module]:.p.import module;
  reflection:.py.reflect[pyMod];
  classes:reflection[module;`classes];
  .py.ref[module]:classes;

  mapping:` sv (`.pym; module);
  mapping set .ut.eachKV[classes; .py.map[pyMod]];
  1b};

.py.failed:{[module;error]
  modFmt:"'",string[module],"'";
  errFmt:"(",error,")";
  -1"Python module ",modFmt," failed with: ", errFmt;
  0b};

.py.map:{[pyMod;name;class]
  pyObj:pyMod hsym name;
  attrib:class`attributes;
  project:.py.pro[pyObj;attrib];
  project};

.py.pro:{[pyObj;attrib;args]
  data:attrib`data;
  prop:attrib`properties;
  func:attrib`functions;

  init:func[.py.it];
  initParam:init[`parameters];
  required:initParam[::;`required];

  if[(.ut.isNull args) and (any required);
    '"Missing required parameters: ",", " sv string where required];
  
  pyArgs:.py.args[args];
  pyInst:pyObj[pyArgs];

  func _: .py.it;
  vars:.py.getVars[pyInst];
  docs:(enlist `dum)!enlist (::);

  if[count data; docs[`data]:data];
  if[count prop; docs[`prop]:prop];
  if[count func; docs[`func]:func];
  if[count vars; docs[`vars]:vars];

  mapDocs:(enlist `docs_)! enlist docs _ `dum;
  mapData:.ut.eachKV[data;.py.mapData[pyObj]];
  mapProp:.ut.eachKV[prop;.py.mapProp[pyInst]];
  mapFunc:.ut.eachKV[func;.py.mapFunc[pyInst]];
  mapVars:.ut.eachKV[vars;.py.mapVars[pyInst]];

  context:mapData,mapProp,mapFunc,mapVars;
  context,:mapDocs;
  context};


.py.mapData:{[pyObj;name;data]
  d:pyObj[hsym name;];
  d};

.py.mapProp:{[pyInst;name;prop]
  d:()!();
  pyProp:hsym name;
  if[prop[`getter];
    d[`get]:pyInst[pyProp;]];
  if[prop[`setter];
    d[`set]:pyInst[:;pyProp;]];
  d};

.py.mapFunc:{[pyInst;name;func]
  d:pyInst[;<]'[(hsym @\:name)];
  d};

.py.mapVars:{[pyInst;name;vars]
  d:()!();
  instVar:hsym name;
  d[`get]:pyInst[instVar;];
  d[`set]:pyInst[:;instVar;];
  d};

.py.args:{[args]
  args:.ut.strToSym[args];
  if[args=(::); :args];
  args:$[.ut.isDict args; pykwargs; pyarglist] args;
  args};


.py.import[`cbpro]

pc:.pym.cbpro.PublicClient[]