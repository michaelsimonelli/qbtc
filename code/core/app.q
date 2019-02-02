
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

