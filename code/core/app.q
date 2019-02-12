.app.PROC:`$getenv `APP_PROC;
.app.HOME_DIR:getenv `APP_HOME_DIR;
.app.CODE_DIR:getenv `APP_CODE_DIR;
.app.CORE_DIR:getenv `APP_CORE_DIR;
.app.LIBR_DIR:getenv `APP_LIBR_DIR;
.app.IMPORTS:`log`util`websocket`embedpy`extendpy`reflection!("lg.q";"ut.q";"ws.q";"p.q";"py.q";"reflect.p");

.app.imported:();

out:{-1 (string .z.z)," ", x};

///
// Imports python script/file
// 
// parameters:
// import [symbol] - name of python script/file (no extension)
.app.import:{[import]
  if[import in .app.imported; :(::)];
  if[not any file:.app.IMPORTS[import];
    '"invalidSelection - chose from: ",", " sv string key .app.IMPORTS];
  path:$[import <> `embedpy;.app.LIBR_DIR,"/";""],file;
  system "l ", path;
  out "Imported: ",string[import];
  .app.imported,:import;
  };

///
// Executes process init script
//
// parameters:
// proc [symbol] - name of process to start
.app.process:{[proc]
  if[null proc; :(::)];
  path:.app.CORE_DIR,"/",string[proc],".q";
  out "Load ",string[proc]," process";
  system "l ", path;
  };

// Import required components
// view `.app.imported` to see list of all imported components
.app.import[`extendpy];
.app.import[`websocket];

// Import and reflect cbpro python module
.py.import[`qoinbase];
.py.reflect[`qoinbase];

.app.process[.app.PROC];
