
******
cbproQ
******

Coinbase Pro API and execution.

A versatile, high-performance example trading application.
Leverages the embedPy interface for python integration to seamlessly import and map an existing library API natively into Q.
This POC is meant to be an introduction into the world of electronic trading, while also exploring the versatility and high-performance capabilities of q.

SANDBOX MODE STRONGLY RECOMMENDED. LIVE TRADES CAN BE EXCUTED VIA THIS API.

This paper's primary focus is the structure and interaction with the trading environment, with topics ranging from:

* application configuration
* data feed subscription and dissemination
* order book engine/market data consumption
* API execution and interaction
 
Setup
=====

Requirements
------------
- Anaconda Python
- Coinbase Pro account (sandbox strongly suggested)
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

**Step 2** Initialze KDB.  In terminal run:

.. code:: bash

    ./startup_example


safe check yadda ydasdf 


.. code-block:: q
  
  /# @function list Wrapper around .p.import
  .py.list:.py.builtin[`:list;<];

  list:builtin[`:list;<];

  list:builtin[`:list;<];

  /# @function import Wrapper around .p.import
  /#  Auto-maps the python module to native kdb functions
  /#  Auto-generates module metadata reference dictionary
  /# @param module (sym) module argument
  .py.import:{[module] 
    if[module in key .py.imp;
      -1"Module already imported";
      :(::)];
  
    imported:@[.py.import0; module; .py.failed[module]];
    if[imported;
      modFmt:"'",string[module],"'";
      -1"Imported python module ", modFmt];
    };

  .py.import0:{[module]
    import:.py.imp[module]:.p.import module;
    reflect:.py.reflect[import];
    classes:reflect[module;`classes];
  
    .py.ref[module]:classes;
  
    mapping:` sv (`.py.mod; module);
    mapping set .ut.eachKV[classes; .py.map[import]];
    1b};


some text break

.. code-block:: q

  Some q code

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

    
.. code:: python

  def setup(sphinx):
      sys.path.insert(0, os.path.abspath('.'))
      from qlex import KdbLexer
      sphinx.add_lexer('q', KdbLexer())


temp check: