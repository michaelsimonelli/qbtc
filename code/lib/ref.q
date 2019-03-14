
.cb.import[`mkt];

// Currency data
.ref.ccy:();

// Product data
.ref.products:();

///
// Gets correct productID format
//
// parameters:
// x [symbol/string] - ccy pair/product
//  (`BTCUSD; "BTCUSD"; `$"BTC-USD"; "BTC-USD")
//
// returns:
// x [symbol] - formatted productID (`BTC-USD)
.ref.getPID:{s:.Q.id $[.ut.isStr x; `$; ]x; .ref.products[s; `id]};

///
// Resolves accountID by currency or ID
//
// parameters:
// x [symbol/string] - ccy or accountID
.ref.getAccID:{[x]
  id: $[.ut.isSym x;
        (x; ?[.ref.accounts; enlist(=; `currency; enlist x); (); ()]`id)(x in .ref.ccyList);
          .ut.isStr x; x; string x];
  id};

.ref.products: .mkt.getProducts[];

.ref.currencies: .mkt.getCurrencies[];

.ref.ccyList: exec id from .ref.currencies;

.ref.symList: exec sym from .ref.products;

.ref.pidList: exec id from .ref.products;
