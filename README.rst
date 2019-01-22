
******
cbproQ
******

Coinbase Pro API Engine.

| This is a POC application, with the goal to implement a q/kdb based trading engine/API.
| The app leverages fusion technology, the embedPy interface, to extend python libraries and map them natively in q.

**Core Components:**

- Data feed subscription and dissemination
- Order book engine/market data consumption
- API execution and interaction
- Application configuration

| With the fusion of python and q, operations that would have been difficult or complex in q alone, are easily executed with little overhead or development.
| Further, by incorporating such operations natively, the application can leverage the processing power and speed of the q server directly, and maintain API calls, data storage, and analysis, all in one process.

**SANDBOX MODE STRONGLY RECOMMENDED. LIVE TRADES CAN BE EXCUTED VIA THIS API.**
 
Setup
=====

Requirements
------------
- Anaconda Python
- Coinbase Pro account (sandbox mode strongly suggested)
- *All testing performed on Ubuntu 18.04*

Install
-------
**Step 1** Clone or download the repo

**Step 2** Create conda environment. In terminal run:

.. code:: bash

    conda create env -f environment.yml

**Note:** The conda environment will download and install all required dependencies, including its own 64-bit kdb/q installation.
The first time you run q from this environment, you will be prompted by a standard license agreement message and will be asked to enter some personal details such as Name and email address. Make sure to enter a valid email address because you will be asked to confirm your email address within 72 hours or your license will expire. If you already have a kdb+ license associated with your email address then kdb will just use that license after you enter that email address.

Configuration
-------------
The Coinbase Pro API key is required to run cbproQ
The API key is provided to kdb via the following envrinment variables:

- CBPRO_PRIV_KEY
- CBPRO_PRIV_SECRET
- CBPRO_PRIV_PASSPHRASE

An example startup script is included to provide your API key and launch cbproQ.
Please reference *startup_example* for details

Start
-----

**Step 1** Activate conda environment. In terminal run:

*Note:* Environment name can be changed via environment.yml, cbpro is the default.

.. code:: bash

    conda activate cbpro

**Step 2** Initialize KDB.  In terminal run:

.. code:: bash

    ./startup_example



safe check yadda ydasdf 


.. code-block:: q
  
  select col1 from tab where t=1
  select col1 from tab where t=1
  
  .py.reflect:{[module]
    import: .py.imp[module];
    mdinfo: .py.mod_info[import];

    .py.meta[module]:mdinfo;

    classes: mdinfo[`classes];
    reflect: (key classes)!.py.cxt[import; classes];

    .pq[module],:reflect;

    1b};

  rootFunctionOneLine:{[arg1] :`symbol; };
 
  rootFunctionMultiLine:{[arg1]
    :`symbol;
   };
  
  .namespace.function.oneLine:{[arg1] :`symbol; };
  
  .namespace.function.multiLine:{[arg1]
    :symbol;
   };

  .py.import:{[module] 
  if[module in key .py.imp;
    -1"Module already imported"; :(::)];

  imported: @[{.py.imp[x]:.p.import x;1b}; module; .py.importError[module]];

  if[imported;
    ns:` sv (`.pq; module);
    ns set (!/) enlist each (`;::);
    -1"Imported python module '",string[module],"'"];
  };