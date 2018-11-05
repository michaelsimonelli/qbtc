
\l ws.q

.ut.params.registerOptional[`ob; `BOOK_DEPTH;  25;  `; "Book depth"];
.ut.params.registerOptional[`ob; `STATE_DEPTH; 500; `; "State depth"];

.data.md:([sym:`symbol$()]bp:`float$();ap:`float$();tp:`float$();vwap:`float$());

.data.quote:([] time:`timestamp$();sym:`symbol$();bpx:`float$();apx:`float$());

.data.trade:([] time:`timestamp$();sym:`symbol$();price:`float$();bid:`float$();ask:`float$();side:`$();size:`float$();id:`long$());

.api.url:"https://api-public.sandbox.pro.coinbase.com";

.feed.url:"wss://ws-feed-public.sandbox.pro.coinbase.com";
.feed.url:"wss://ws-feed.pro.coinbase.com";
.feed.products:`$("BTC-USD";"ETH-USD";"ETH-BTC");
.feed.channels:(`level2`ticker);



.book.bids.:(::);
.book.asks.:(::);

.state.bids.:(::);
.state.asks.:(::);

.book.cut:{x sublist y}[.ut.params.get[`ob]`BOOK_DEPTH];
.state.cut:{x sublist y}[.ut.params.get[`ob]`STATE_DEPTH];


.book.full:{[sym] (,'/).book[`bids`asks;sym]};

.book.view:{[sym;depth] depth sublist .book.full[sym]};

.book.vwap:{[sym;side;depth] 
  side:(`buy`sell!(`aqty`asks;`bqty`bids))[bs];
  book:.[.book.full;(sym;([]lvl:til depth);side)];
  vwap:.[wavg;] flip book;
  vwap};

.state.rebalance:{[side;sym]
  .[`.state;(side;sym);.state.expired];
  .[`.state;(side;sym);.state.sort[side]];
  updBK:.state.updBook[side;sym];
  updBK};

.state.expired:{(where x=0)_x};

.state.sort:{[side;data]
  sortF:$[`bids=side;desc;asc];
  sortD:.state.cut (sortF[key data]#data);
  sortD};

.state.updBook:{[side;sym]
  head:side,$[side=`bids;`bqty;`aqty];
  book:flip head!.book.cut'(key;value)@\:.state[side;sym];
  if[updBK:not .book[side;sym]~book;
    .book[side;sym]:book];
  updBK};

.upd.state:{[sym;chg]
  price:chg 1; size:chg 2;
  side:$[not chg[0] in `buy`sell;'badSide;`buy=chg[0];`bids;`asks];
  .state[side;sym;price]:size;
  updBK:.state.rebalance[side;sym];
  updBK};

.upd.md:{[sym;time;updQuote];
  bp:max key .state.bids[sym];
  ap:min key .state.asks[sym];
  mdEvt:(bp;ap); mdSym:`bp`ap;
  if[any updMD:where not mdEvt=.data.md[sym;mdSym];
    .[`.data.md;(sym;mdSym[updMD]);:;mdEvt[updMD]];
    if[updQuote;`.data.quote upsert (time;sym;bp;ap)];
  ];
  };

.evt.ticker:{
  if[not any `trade_id`time in key x;:(::)];
  if[.ut.isNull x`time;:(::)];
  x:"SFFFSZjF"$`product_id`price`best_bid`best_ask`side`time`trade_id`last_size#x;
  x:`sym`price`bid`ask`side`time`id`size!value x;
  x:@[x;`sym;.Q.id];
  x:@[x;`time;"p"$];
  if[.ut.isNull x`id; x[`id]:0N];
  .[`.data.md;(x`sym;`tp);:;x`price];
  `.data.trade upsert x;
  };

.evt.l2update:{
  x:"SSZ*"$x;
  sym:.Q.id x`product_id;
  change:"SFF"$/:x`changes;
  time:"p"$x`time;
  updBK:.upd.state[sym] each change;
  if[any updBK;
    .upd.md[sym;time;0b]];
  };

.evt.snapshot:{
  x:"SSFF"$x;
  x:@[x;`product_id;.Q.id];
  x:@[x;`bids`asks;{(!/) flip x}];
  {.state[y;x`product_id]:.state.cut x y}[x] each `bids`asks;
  .state.rebalance[;x`product_id] each `bids`asks;
  .upd.md[x`product_id;`;0b];
  };

.feed.upd:{
  e:.j.k x;
  t:`$e`type;
  if[t in key .evt;
    .evt[t]e];
  };

.feed.sub:{[h;p;c]
  p:.ut.enlist p;
  c:c union `heartbeat;
  s:.j.j (`type`product_ids`channels)!("subscribe"; p; c);
  h[s];
  };

.feed.usub:{[h;p;c]
  p:.ut.enlist p;
  c:.ut.enlist c;
  s:.j.j (`type`product_ids`channels)!("unsubscribe"; p; c);
  h[s];
  };  
