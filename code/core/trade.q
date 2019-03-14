.api.getAccounts:{[]
  res: .qb.AC.get_accounts[];
  acc: "SSFFFS"$/:res;
  acc};

.api.getAccount:{[x]
  id: .ref.getAccID[x];
  res: .qb.AC.get_account[id];
  acc: "SSFFFS"$res;
  acc};

.api.getAccountHistory:{[x;t]
  id: .ref.getAccID[x];
  res: $[.ut.isNull t; .qb.AC.get_account_history id; .qb.AC.get_account_history[id; `type pykw t]];
  hst: .py.builtins.list[res];
  hst: "ZjFFS*"$/:hst;
  hst};

.api.getAccountHistoryDetails:{[x]
  res: .api.getAccountHistory[x;`];
  res: res where max =\:[`match`fee; (res`type)];
  dts: "SJS"$/:res`details;
  tds:(``details) _ res;
  tds,'dts};

.api.getFills:{[x]
  arg: $[.ut.isList x; (!/) enlist each @[x; 0; (`pid`oid`bef!`product_id`order_id`before)@];];
  
  .ut.assert[(.ut.isDict arg) and (any `product_id`order_id in key arg);
    "ProductID or OrderID required as (`arg;val) list or kwargs"];

  arg: @[arg; `product_id; .ref.getPID];
  res: .qb.AC.get_fills[pykwargs arg];
  tmp: .py.builtins.list res;
  tmp: "*jSSSS*FFFSbF"$/:tmp;
  fls: update .ut.iso2Q'[created_at], raze/[liquidity] from tmp;
  fls};