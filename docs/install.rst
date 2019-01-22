######################
Setup and Installation
######################

Setup and installation guide.

Setup
=====

Environment setup and configuration

Requirements
------------
- EmbedPy >= 1.3.1
- Coinbase Pro Account (sandbox mode strongly suggested)

Suggested
---------
- kdb+ 3.6
- Linux OS
- Anaconda Python

.. note::
    For best results, follow suggested environment.

    Cross platform/version compatibility may require some tweaking.

    *See environment.yml for dependencies*

Install
=======

Step by step installation guide.

Anaconda
--------
**Step 1** Clone or download the `repo <https://github.com/michaelsimonelli/cbproQ>`_ 

**Step 2** Create conda environment. In terminal run:

.. code:: bash

    conda env create -f environment.yml -n env_name

.. note::
    The conda environment will download and install all required dependencies, including its own 64-bit kdb/q installation.
    
    | The first time you run q from this environment, you will be prompted by a standard license agreement message 
    | and will be asked to enter some personal details such as Name and email address. 
    | Make sure to enter a valid email address because you will be asked to confirm your email address within 72 hours or your license will expire. 
    | If you already have a kdb+ license associated with your email address then kdb will just use that license after you enter that email address.

Configuration
-------------
The Coinbase Pro API key is required to run cbproQ
The API key is provided to kdb via the following envrinment variables:

- CBPRO_PRIV_KEY
- CBPRO_PRIV_SECRET
- CBPRO_PRIV_PASSPHRASE

An example startup script is included to provide your API key and launch cbproQ.
Please reference *startup_example* for details


**SANDBOX MODE STRONGLY RECOMMENDED. LIVE TRADES CAN BE EXCUTED VIA THIS API.**

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
