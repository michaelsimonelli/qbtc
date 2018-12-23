.. code:: kdb

  rootFunctionOneLine:{[arg1] :`symbol; };

  rootFunctionMultiLine:{[arg1]
    :`symbol;
   };
  
  .namespace.function.oneLine:{[arg1] :`symbol; };
  
  .namespace.function.multiLine:{[arg1]
    :symbol;
   };

  select col1, col2 from tab where arg = 40
  select from tab where arg = 40