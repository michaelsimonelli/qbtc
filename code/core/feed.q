.cb.import[`ws];
.cb.import[`ref];

lst:()!();
bids.:(::);
asks.:(::);

depth: 10;  /book depth
stage: 500; /stage depth
 
// Process stage change
//c:first c
.stg.chg:{[s;c]
  d: c 0; / side
  p: c 1; / price
  z: c 2; / size
  / flow control by side
  i: d=`buy;
  t: `asks`bids i;
  r: (asc;desc) i;
  f: `$"ab"[i],'string `px`sz;
  / update, remove, sort stage
  .[t; (s; p); :; z];        
  @[t; s; {(where 0=x)_x}];  
  @[t; s; {stage sublist x[key y]#y}r];
  / build book snapshot and publish if needed
  b: f!depth sublist'(key;value)@\:t[s];
  if[not lst[s; f]~u:b[f];
    .feed.pub[`book; (t; s; u)]
    lst[s]:b;
    ];
  };




.msg.ticker:{
  if[not any `trade_id`time in key x; :(::)];
  if[.ut.isNull x`time; :(::)];

  x: "SFFFSZjF"$`product_id`price`best_bid`best_ask`side`time`trade_id`last_size#x;
  x: `sym`price`bid`ask`side`time`id`size!value x;
  x: @[x; `sym; .Q.id];
  x: @[x; `time; "z"$];

  if[.ut.isNull x`id; x[`id]:0N];
  .feed.pub[`trade; x];
  };

.msg.l2update:{
  x: "SSZ*"$x;
  t: "p"$x`time;
  c: "SFF"$/:x`changes;
  s: .Q.id x`product_id;
  .stg.chg[s] each c;
  };

.msg.snapshot:{
  x: "SSFF"$x;
  s: .Q.id x`product_id;

  bids[s]: sd sublist (!/) flip x`bids;
  asks[s]: sd sublist (!/) flip x`asks;

  if[not s in key lst;
    lst[s]:`bpx`bsz`apx`asz!()];
  };

.feed.upd:{
  m: .j.k x;
  t: `$m`type;
  if[t in key .msg;
    .feed.hdlr[t;m]];
  };

.feed.hdlr:{[t;m] @[.msg[t];m;.feed.err[t;m]]}

.feed.err:{[t;m;e]
  .feed.log.error "Message Handler Failed on [",string[t],"] update - with (",e,")";
  .feed.bad[t],:enlist m;
  };

.feed.sub0:{[h;p;c]
  p: .ut.enlist .ref.getPID'[p];
  c: c union `heartbeat;
  s: .j.j (`type`product_ids`channels)!("subscribe"; p; c);
  h[s];
  };

.feed.usub:{[h;p;c]
  p: .ut.enlist p;
  c: .ut.enlist c;
  s: .j.j (`type`product_ids`channels)!("unsubscribe"; p; c);
  h[s];
  };  

.feed.pub:{[t;d]
  h:.feed.w[t];
  h@\:(`.upd.msg; t; d);
  };

.feed.w:`trade`book!();

.feed.reg:{[t].feed.w[t],:neg .z.w};

.feed.url:"wss://ws-feed.pro.coinbase.com";
.feed.products:`BTCUSD`ETHUSD`LTCUSD;
.feed.channels:`ticker`level2;
.feed.handle:.ws.open[.feed.url; `.feed.upd];
.feed.sub[.feed.handle; .feed.products; .feed.channels];




