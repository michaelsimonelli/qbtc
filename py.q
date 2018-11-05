\l p.q
\l py.p
\l ut.q

///
// Namespace: .py
//  Simple embedPy framework.
//  Focus on seamless integration.
// ________________________________________________________

///
// Dictionary: imports
//  Stores imported python modules, metadata.
//  Drill down dictionary:
//  module
//  |--> class1
//         |---> prop1 [getter;setter;deleter]
//         ----> func1 [args;default;values;required;doc]
//         ----> func2 [args;default;values;required;doc]
.py.imports:()!();

///
// Function: import
//  Wrapper around .p.import
//  Auto-maps the python module to native kdb functions
//  Auto-generates module metadata reference dictionary
.py.import:{[module] 
  if[module in key .py.imports;
    -1"Module already imported";
    :(::)];

  imported:@[.py.priv.onImport; module; 
              .py.priv.onImportFailed[module]];

  if[imported;
    modFmt:"'",string[module],"'";
    -1"Imported python module ", modFmt];
  };

.py.pget:{[pinst; pattr]
  pval:pinst[hsym pattr]`;
  pval};

.py.pset:{[pinst; pattr; pval]
  pinst[:; hsym pattr; pval];
  .py.pget[pinst; pattr]};




.py.builtin:.p.import[`builtins];

.py.next:.py.builtin[`:next;<];
.py.list:.py.builtin[`:list;<];
///
// Function: onImport
//  Called on .py.import to trap import errors
.py.priv.onImport:{[module]
  .py[module]:.p.import module;
  .py.imports[module]:.py.priv.get_mod_info[.py[module]];
  .py.priv.mapper[module] each key .py.imports[module];
  1b};

///
// Function: onImportFailed
//  Called on .py.import to throw import errors
.py.priv.onImportFailed:{[module;error]
  modFmt:"'",string[module],"'";
  errFmt:"(",error,")";
  -1"Python module ",modFmt," failed with: ", errFmt;
  0b};


// constant python built-in 
.py.priv.t:`$"__init__";

///
// Function: get_mod_info 
//  Gets imported python module metadata
.py.priv.get_mod_info:.p.get[`get_mod_info;<];

///
// Function: get_inst_attr 
//  Gets python object instance attributes
.py.priv.get_inst_attr:.p.get[`get_inst_attr;<];

///
// Function: mapper 
//  Maps a python class to a native q context
.py.priv.mapper:{[module;class]
  context:` sv (`;`pm;module;class);
  context set .py.priv.generic[module;class];
  };

///
// Function: generic
//  Called as a projection to dynamically set
//  imported python functions as a q callable object
//
// Note: q mapped python modules are stored in .pm namespace
// 
// Example:
//  .pm.module.class.func[]
//  accepts 1st positional, *args, or **kwargs
//  *Does not accept multiple positional args
.py.priv.generic:{[module;class;args]
  metadata:.py.imports[module;class];
  required:metadata[.py.priv.t;`required];
  if[(.ut.isNull args) and (not .ut.isNull required); 
      '"Missing required parameters"];

  py_module:.py[module];
  py_object:py_module hsym class;
  py_params:.py.priv.args[args];
  py_instance:py_object[py_params];
  py_functions:(key metadata) except .py.priv.t;
  py_context:py_functions!py_instance[;<]'[(hsym @\:py_functions)];
  q_context:py_context,(`attr`help`pget`pset!({[x;y].py.priv.get_inst_attr[x]}[py_instance];{[x;y;z].py.imports[x;y]}[module;class];.py.pget[py_instance];.py.pset[py_instance]));
  q_context};

.py.priv.args:{[args]
  args:.ut.strToSym[args];
  $[.ut.isDict args; pykwargs; pyarglist] args
  };