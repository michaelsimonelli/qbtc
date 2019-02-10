#####
Usage
#####

.. _usage-label:

Basic API
=========
There are three main clients included with the coinbase pro library:

- Public
- Authenticated
- WebSocket

The clients are essentially python classes that have been translated over to q.

As q has no concept of classes or instantiation, the 'classes' are stored as a projected functions in the ``qoinbase`` namespace/context.

To view available 'classes', execute the following in q:

.. code-block:: q

    q)key `.qoinbase`
    `AuthenticatedClient`CBProAuth`OrderBook`PublicClient`WebsocketClient`

For introduction purposes, we'll be focusing on the PublicClient.


Public Client
*************
The Public Client is essentially a public market data client.

To create ('initialize') a public client in q:

.. code-block:: q

    q).qb.PC:.qoinbase.PublicClient[]
    q).qb.PC
    get_currencies            | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_24hr_stats    | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_historic_rates| code.[code[foreign]]`.p.q2pargsenlist`
    get_product_order_book    | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_ticker        | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_trades        | code.[code[foreign]]`.p.q2pargsenlist`
    get_products              | code.[code[foreign]]`.p.q2pargsenlist`
    get_time                  | code.[code[foreign]]`.p.q2pargsenlist`
    url                       | {[acor;arg]
    auth                      | {[acor;arg]
    session                   | {[acor;arg]
    docs_                     | ``func`vars!(::;`get_currencies`get_product_24hr_stats...``


This is akin to calling python's '__init__' function when creating a new class.

If the underlying python class required arguments, they would be passed here as well.

However, args must be passed in list format, with positional arguments preceding keyword arguments.

If available, you can view a functions metadata, including parameter type, default, and if it's required, via:

.. code-block:: q

    q).py.meta[`cbpro;`classes;`PublicClient;`attributes;`functions;`$"__init__";`parameters]`
           | kind                    ptyp  default                        has_default required doc                               
    -------| --------------------------------------------------------------------------------------------------------------------
    api_url| "positional_or_keyword" "str" "https://api.pro.coinbase.com" 1           0        ,"API URL. Defaults to cbpro API."
    timeout| "positional_or_keyword" ""    30                             1           0        ("Represents a parameter in a func

A function library is created and stored in what ever variable you assign.

Variables
---------
Any instance variables or properties that would have been created with the traditional python class, are also mapped to the q context.

Variables are identified as the context entries that begin with: '{[acor;arg]'

This function acts as the getter and setter (if available) constructor.

To 'get' a variable or property value, call the function with no args:

.. code-block:: q

    q).qb.PC.url[]
    "https://api.pro.coinbase.com"

To 'set' a variable or property value, call the function with the desired value:

.. code-block:: q

    q).qb.PC.url["test_new_url"]
    q).qb.PC.url[]
    "test_new_url"

Functions
---------
Any methods that belong to the underlying python library are also mapped to the context.

Functions are identified as the context entries that begin with: 'code.[code[foreign]]`.p.q2pargsenlist'`

Functions are called via:

.. code-block:: q

    q).qb.PC.get_products[]
    id          base_currency quote_currency base_min_size base_max_size quote_increment display_name
    -------------------------------------------------------------------------------------------------
    "BCH-USD"   "BCH"         "USD"          "0.01"        "350"         "0.01"          "BCH/USD"   
    "BCH-BTC"   "BCH"         "BTC"          "0.01"        "200"         "0.00001"       "BCH/BTC"   
    "BTC-GBP"   "BTC"         "GBP"          "0.001"       "20"          "0.01"          "BTC/GBP"   
    "BTC-EUR"   "BTC"         "EUR"          "0.001"       "50"          "0.01"          "BTC/EUR"   
    "BCH-GBP"   "BCH"         "GBP"          "0.01"        "120"         "0.01"          "BCH/GBP"   
    "MKR-USDC"  "MKR"         "USDC"         "0.01"        "1000"        "0.01"          "MKR/USDC"  
    "BCH-EUR"   "BCH"         "EUR"          "0.01"        "120"         "0.01"          "BCH/EUR"   
    "BTC-USD"   "BTC"         "USD"          "0.001"       "70"          "0.01"          "BTC/USD"   
    "ZEC-USDC"  "ZEC"         "USDC"         "0.01"        "1000"        "0.01"          "ZEC/USDC"  
    "DNT-USDC"  "DNT"         "USDC"         ,"1"          "150000"      "0.000001"      "DNT/USDC"  
    "LOOM-USDC" "LOOM"        "USDC"         ,"1"          "150000"      "0.000001"      "LOOM/USDC" 


Functions with arguments are called via:

.. code-block:: q

    q).qb.PC.get_product_ticker["BTC-USD"]
    trade_id| 59046001
    price   | "3647.04000000"
    size    | "0.01418993"
    time    | "2019-02-10T23:37:19.124Z"
    bid     | "3647.03"
    ask     | "3647.04"
    volume  | "5133.61011523"

**NOTE** Typical embedPy execution applies to these functions. More information can be found at `embedPy <https://code.kx.com/q/ml/embedpy/>`_

Also, not all functions return native q types, some will return 'foreign'.
In this instance, the returned result is most likely a python generator, and can be accessed via list or next in .py.builtins.

To view examples of the basic mapped functions, wrapped with more useful implementations see ``code/core/base.q``
