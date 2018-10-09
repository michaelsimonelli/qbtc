
\l ut.q
\l ws.q
\l py.q


.data.md:([sym:`symbol$()]bp:`float$();ap:`float$();tp:`float$();vwap:`float$());

.data.quote:([] time:`timestamp$();sym:`symbol$();bpx:`float$();apx:`float$());

.data.trade:([] time:`timestamp$();sym:`symbol$();price:`float$();bid:`float$();ask:`float$();side:`$();size:`float$();id:`long$());

.api.url:"https://api-public.sandbox.pro.coinbase.com";
/`CBRPO_PRIV_KEY setenv .api.priv.key:"d7d381cdbb3d0de770cea8a637aa0379";
/`CBRPO_PRIV_SECRET setenv .api.priv.secret:`$"AnXRvi7fgsF7mCcRIibJB4tx2DSoxN1ovcusZcviJggkwYMzMFSekW82Y94CzJScUArSiBe6uOMkafDpWs/cpw==";
/`CBRPO_PRIV_PASSPHRASE setenv .api.priv.passphrase:`$"ue37tvk07q9";

.feed.url:"wss://ws-feed-public.sandbox.pro.coinbase.com";
.feed.url:"wss://ws-feed.pro.coinbase.com";
.feed.products:`$("BTC-USD";"ETH-USD";"ETH-BTC");
.feed.channels:(`level2`ticker);

.book.symbols:.Q.id each .feed.products;
.book.depth:25;

.state.depth:.book.depth*5;

.book.init:{[]
  .state,:.ut.repeat[`bids`asks;.ut.repeat[.book.symbols;enlist(`float$())!`float$()]];
  emptyBook:(enlist `bids)!enlist .ut.repeat[.book.symbols;([]bids:`float$();bqty:`float$())];
  emptyBook,:(enlist `asks)!enlist .ut.repeat[.book.symbols;([]asks:`float$();aqty:`float$())];
  .book,:emptyBook;
  };

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
  sortD:.state.depth sublist (sortF[key data]#data);
  sortD};

.state.updBook:{[side;sym]
  head:side,$[side=`bids;`bqty;`aqty];
  book:flip head!.book.depth sublist'(key;value)@\:.state[side;sym];
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
  {.state[y;x`product_id]:.state.depth sublist x y}[x]'[`bids`asks];
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
  p:.ut.safeEnlist p;
  c:c union `heartbeat;
  s:.j.j (`type`product_ids`channels)!("subscribe"; p; c);
  h[s];
  };

.feed.usub:{[h;p;c]
  p:.ut.safeEnlist p;
  c:.ut.safeEnlist c;
  s:.j.j (`type`product_ids`channels)!("unsubscribe"; p; c);
  h[s];
  };  
