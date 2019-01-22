
// callback to process websocket messages
.z.ws:{value[.ws.W[.z.w]`cb]x};

.z.wc:{0N!(.z.Z; "ws close"; x); delete from `.ws.W where fd=x};

.ws.W:([fd:`int$()] hn:`$(); cb:`$());

.ws.hap:{[url]
  if[not 10h = type url; '"URL must string"];
  .Q.hap $[.z.K<3.6;hsym `$;]url};

.ws.open:{[url;cb]
  u: `prot`user`host`endp!.ws.hap url;
  k: ("Host"; "Origin"; "Upgrade"; "Connection"; "Sec-WebSocket-Version");
  v: (u`host; u`host; "websocket"; "Upgrade"; "13");
  d: ("\r\n" sv ": " sv/: flip (k;v)),"\r\n\r\n";
  r: "GET ",u[`endp]," HTTP/1.1\r\n",d;
  h: first (hsym `$raze u`prot`host) r;
  .ws.W[h]: (`$u`host; cb);
  0N!(.z.Z; "ws open"; h);   
  neg h};