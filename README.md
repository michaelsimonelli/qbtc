# cbproQ

## Introduction
Part 1 of a 2-part paper.

Part 1 – fully fledged trading API with real time data feeds.

Part 2 – automated trading strategies utilizing the API and data feeds.

```q
.ut.params.registerOptional:{[component;name;typ;default;combo;descr]
  param:enlist each `component`name`val`required`default`combo`descr!(component;name;`;0b;default;enlist combo;`$descr);
  .ut.params.registered,:2!flip param;
  .ut.params.updateFromEnv[component;name;typ];
  };
```
