.app.process[`basic];

md:([sym:`symbol$()]bp:`float$();ap:`float$();tp:`float$();vwap:`float$());

quote:([] time:`datetime$();sym:`symbol$();bpx:`float$();apx:`float$());

trade:([] time:`datetime$();sym:`symbol$();price:`float$();bid:`float$();ask:`float$();side:`$();size:`float$();id:`long$());

book.bids.:(::);
book.asks.:(::);

.state.bids.:(::);
.state.asks.:(::);

.qb.fullBook:{[sym]
  b:`bids`bqty xcol book.bids[sym];
  a:`asks`aqty xcol book.asks[sym];
  (b,'a)};

.qb.viewBook:{[sym;depth] depth sublist .qb.fullBook[sym]};

.qb.vwapBook:{[sym;bs;depth] 
  side: (`buy`sell!`asks`bids)[bs];
  data: depth sublist book[side; sym];
  vwap: exec qty wavg price from data;
  vwap};

.state.rebalance:{[side;sym]
  .[`.state; (side; sym); {(where x=0)_x}];
  .[`.state; (side; sym); .state.sort[side]];
  upd: .state.upd[side; sym];
  upd};

.state.sort:{[side;data]
  sortF: $[`bids=side; desc; asc];
  sortD: 500 sublist (sortF[key data]#data);
  sortD};

.state.upd:{[side;sym]
  snap: flip `price`qty!25 sublist'(key; value)@\:.state[side; sym];
  if[upd:not book[side; sym]~snap;
    book[side; sym]:snap];
  upd};

.upd.state:{[sym;chg]
  price: chg 1; size: chg 2;
  side: (`buy`sell!`bids`asks)[chg 0];
  .state[side; sym; price]:size;
  upd: .state.rebalance[side; sym];
  upd};

.upd.md:{[s;time;updQuote];
  vwap: exec wavg[-5#size;-5#price] from trade where sym = s;
  evt: (max key .state.bids[s]; min key .state.asks[s]; vwap);
  if[any upd:where not evt=md[s; `bp`ap`vwap];
    .[`md; (s; `bp`ap`vwap[upd]); :; evt[upd]];
    if[updQuote; `quote upsert (time; s; evt 0; evt 1)];
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
  .[`md; (x`sym; `tp);: ; x`price];
  `trade upsert x;
  };

.msg.l2update:{
  x: "SSZ*"$x;
  sym: .Q.id x`product_id;
  change: "SFF"$/:x`changes;
  time: "p"$x`time;
  upd: .upd.state[sym] each change;
  if[any upd;
    .upd.md[sym; time; 0b]];
  };

.msg.snapshot:{
  x: "SSFF"$x;
  x: @[x; `product_id; .Q.id];
  x: @[x; `bids`asks; {(!/) flip x}];
  {.state[y; x`product_id]:500 sublist x y}[x] each `bids`asks;
  .state.rebalance[; x`product_id] each `bids`asks;
  .upd.md[x`product_id; `; 0b];
  };

.feed.upd:{
  e: .j.k x;
  t: `$e`type;
  if[t in key .msg;
    .msg[t]e];
  };

.feed.sub:{[h;p;c]
  p: .ut.enlist p;
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

.feed.products:`$("BTC-USD";"ETH-USD");
.feed.channels:`ticker`level2;

.feed.url:"wss://ws-feed.pro.coinbase.com";
.feed.handle:.ws.open[.feed.url; `.feed.upd];

.feed.sub[.feed.handle; .feed.products; .feed.channels];
