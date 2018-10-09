\l p.q
\l reflect.p

.py.imports:()!();

.py.list:.p.get[`pq_list;<];
.py.get_mod_info:.p.get[`get_module_info;<];
.py.get_inst_attr:.p.get[`get_inst_attributes;<];

.py.import:{[module] if[module in key .py.imports;:`imported];
  .py[module]:.p.import module;
  .py.imports[module]:.py.get_mod_info[.py[module]];
  .py.mapper[module] each key .py.imports[module];
  `success
  };

.py.t:`$"__init__";

.py.generic:{[module;class;args]
  modmeta:.py.imports[module;class];
  required:modmeta[.py.t;`required];
  functions:(key modmeta) except .py.t;

  if[.ut.isNull args;
    if[not .ut.isNull required;
      'paramsNeeded
    ];
  ];

  pimport:.py[module];
  pobject:pimport hsym class;
  pinstance:.[pobject;.ut.safeEnlist args];
  pcontext:functions!pinstance[;<]'[(hsym @\:functions)];
  qinstance:pcontext,(`attr`help`pget`pset!({[x;y].py.get_inst_attr[x]}[pinstance];{[x;y;z].py.imports[x;y]}[module;class];.py.pget[pinstance];.py.pset[pinstance]));
  qinstance};

.py.mapper:{[module;class]
  context:` sv (`;module;class);
  context set .py.generic[module;class];
  };

.py.pget:{[pinst; pattr]
  pval:pinst[hsym pattr]`;
  pval};

.py.pset:{[pinst; pattr; pval]
  pinst[:; hsym pattr; pval];
  .py.pget[pinst; pattr]};