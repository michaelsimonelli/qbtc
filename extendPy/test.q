
embedpyTest:{
  system "l p.q";
  .p.set[`i;x];
  if[not x~.p.py2q .p.pyget`i;'fail];
  exit 0};

@[embedpyTest;4;{exit 1}];
