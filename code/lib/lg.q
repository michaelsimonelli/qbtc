// Modified implementation of p.bukowinski log4q: https://github.com/prodrive11/log4q
.app.import[`util];

.ut.params.registerOptional[`log; `APP_NAME; `app; "Base application name"];

\d .lg
cmp:(!)."SS"$\:();
fmt:"%z %l (%c) %m %w\r\n";
app:.ut.params.get[`log]`APP_NAME;
lvs:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL;
fns:`$string lower lvs;rnk:lvs!til count lvs;snk:lvs!();
sev:$[`log in key .Q.opt .z.x;first `$upper .Q.opt[.z.x]`log;`INFO];
a:{$[1<count x;[h[x 0]::x 1;snk[y],::x 0];[h[x]::{x@y};snk[y],::x;]];};r:{snk::@[snk;y;except;x];};
l:{ssr/[fmt;"%",/:lfmt;m[lfmt:raze -1_/:2_/:nl where fmt like/: nl:"*%",/:(.Q.a,.Q.A),\:"*"].\:(x;y;z)]};
w:{mem:"/" sv value string ceiling @["f"$.Q.w[];`used`heap`peak`wmax`mmap`mphy`symw;%;1e6];"MEM(MB): [",mem,"]"};
p:{$[10h~type x:(),x;x;(2~count x) & 10h~type x 0;ssr/[x 0;"%",/:string 1+til count (),x 1;.Q.s1 each (),x 1];.Q.s1 x]};
h:m:()!();m["l"]:{[x;y;z]string x};m["c"]:{[x;y;z]string y};m["f"]:{[x;y;z]string .z.f};m["p"]:{[x;y;z]string .z.p};m["P"]:{[x;y;z]string .z.P};m["m"]:{[x;y;z]z};m["h"]:{[x;y;z]string .z.h};m["i"]:{[x;y;z]string .z.i};m["d"]:{[x;y;z]string .z.d};m["D"]:{[x;y;z]string .z.D};m["t"]:{[x;y;z]string .z.t};m["T"]:{[x;y;z]string .z.T};m["z"]:{[x;y;z]string .z.z};m["w"]:{[x;y;z]w[]};
setLogLevel:{if[not x in key cmp;'"invalid component"];if[not y in lvs;'"invalid level"];if[x=app;x:key cmp];cmp[x]:y};getLogLevel:{[x;y]cmp[x]};
create:{if[x in key cmp;'"Log component already exists"];cmp[x]:sev;name:$[x=app;app;` sv app,x];func:(`$string lower lvs),`setLogLevel`getLogLevel;func!.lg[func]@\:name};
(` sv' ``lg,/:fns) set' {if[{rnk[x]<rnk cmp y}.(x;y);:(::)];{@[.lg.h[x]x;y;{[h;e]'"lg - ", string[h]," exception:",e}[x]]}[;l[x;y] p z]@/:snk[x]}@/: key[snk];n:(::);
a[1;`SILENT`DEBUG`INFO`WARN];a[2;`ERROR`FATAL]; 
\d .

// create base app log
lg:.lg.create[.lg.app];
