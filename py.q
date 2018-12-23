\l p.q
\l ut.q
\l reflect.p

.py.imp:()!();

.py.meta.:(::);

.py.mod_info:.p.get[`module_info;<];

.py.import:{[module] 
  if[module in key .py.imp;
    -1"Module already imported"; :(::)];

  imported: @[{.py.imp[x]:.p.import x;1b}; module; .py.importError[module]];

  if[imported;
    ns:` sv (`.pq; module);
    ns set (!/) enlist each (`;::);
    -1"Imported python module '",string[module],"'"];
  };

.py.reflect:{[module]
  import: .py.imp[module];
  mdinfo: .py.mod_info[import];

  .py.meta[module]:mdinfo;

  classes: mdinfo[`classes];
  reflect: (key classes)!.py.cxt[import; classes];

  .pq[module],:reflect;
  
  1b};

.py.importError:{[module; error]
  -1"Python module '",string[module],"' failed with: ", "(",error,")";
  0b};

.py.cxt:{[import; classes]
  projection:{
    obj: x hsym y;
    atr: z`attributes;
    pro: .py.proj[obj; atr];
    pro}[import]./:flip(key;value)@\:classes;
  projection};

.py.proj:{[pyObj; attrib; args]
  data: attrib`data;
  prop: attrib`properties;
  func: attrib`functions;

  init: func[`$"__init__"];
  params: init[`parameters];
  required: params[::;`required];

  if[(.ut.isNull args) and (any required);
    '"Missing required parameters: ",", " sv string where required];
  
  pyArgs: .py.args[args];
  pyInst: pyObj[pyArgs];

  func _: `$"__init__";
  vars: .pq.builtins.vars[pyInst];
  docs: (enlist `dum)!enlist (::);

  if[count data; docs[`data]:data];
  if[count prop; docs[`prop]:prop];
  if[count func; docs[`func]:func];
  if[count vars; docs[`vars]:vars];

  mD: .py.mapData[pyInst; data];
  mP: .py.mapProp[pyInst; prop];
  mF: .py.mapFunc[pyInst; func];
  mV: .py.mapVars[pyInst; vars];
  mS: (enlist `docs_)! enlist docs _ `dum;

  cxt: mD,mP,mF,mV;
  cxt,:mS;
  cxt};

.py.args:{[args]
  args: .ut.strToSym[args];
  if[args=(::); :args];
  args: $[.ut.isDict args; pykwargs; pyarglist] args;
  args};

.py.mapData:{[obj; d]
  k: key d;
  v: obj@'hsym k;
  m: k!v;
  m};

.py.mapProp:{[ins; d]
  m: .ut.eachKV[d;{
      h: hsym y;
      d: (enlist `get)!(enlist x[h;]);
      if[z`setter; d[`set]:x[:;h;]];
      d}[ins;]];
  m};

.py.mapFunc:{[ins; d]
  f: key d;
  m: f!ins[;<]@'hsym f;
  m};

.py.mapVars:{[ins; vars]
  k: key vars;
  h: hsym k;
  v:{
    g: ins[x;];
    s: ins[:;x;];
    d:`get`set!(g;s);
    d} each h;
  m: (!/)($[1>=count k;.ut.enlist each;](k;v));
  m}

.py.attrs:.p.get[`get_attrs;<];

.py.imap:{[p; f]
  i: .py.imp[p];
  m: f!i[;<]@'hsym f;
  .pq[p],:m;
  m};

.py.import[`builtins];

.py.imap[`builtins;`list`next`vars`str];
