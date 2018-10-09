
.ws.conns:([handle:`int$()] hostname:`$(); callback:`$());

.z.ws:{value[.ws.conns[.z.w]`callback]x};
.z.wc:{0N!(.z.Z; "ws close"; x); delete from `.ws.conns where handle=x};

.ws.header.default:.ut.dict(
  ("Host"                  ; "");
  ("Origin"                ; "" );
  ("Upgrade"               ; "websocket");
  ("Connection"            ; "Upgrade");
  ("User-Agent"            ; "KDB WebSocket/",string .z.K);
  ("Sec-WebSocket-Version" ; "13"));

.ws.header.build:{[host;custom]
  header:.ws.header.default;
  header[("Host";"Origin")]:(host;host);
  if[not .ut.isNull custom; header,:custom];
  fields:(key header),\:": ";
  values:(value header),\:"\r\n";
  header:raze fields,'values;
  header};

.ws.open:{[url;callback;custom]
  part:.Q.hap url;
  host:part 2;
  endpoint:part 3;
  header:.ws.header.build[host;custom];
  request:"GET ",endpoint," HTTP/1.1\r\n",header,"\r\n";
  response:(hsym`$url) request;
  handle:response 0; / if needed, http message in response 1
  upsert[`.ws.conns;(handle;`$host; callback)];
  0N!(.z.Z;"ws open";f);   
  neg handle};

