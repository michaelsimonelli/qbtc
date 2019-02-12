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
The Public Client interacts with the Market Data API.

The Market Data API is an unauthenticated set of endpoints for retrieving market data. These endpoints provide snapshots of market data.

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

Functions are identified as the context entries that begin with: *code.[code[foreign]]`.p.q2pargsenlist'`*

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

.. note::
    Typical embedPy execution applies to these functions. 
    
    More information can be found at `embedPy <https://code.kx.com/q/ml/embedpy/>`_

| Also, not all functions return native q types, some will return 'foreign'.
| In this instance, the returned result is most likely a python generator, and can be accessed via list or next in .py.builtins.

Example
-------
This is a simple example to highlight how the basic API calls can be wrapped to provide a more useful implementation.

.. code-block:: q

    // create wrapper function to get historic rates
    q)getProductHistoricRates:{[pid;start;end;granularity];
        kwargs: `start`end`granularity!(3#.py.none);
        switch: not .ut.isNull each (start; end; granularity);
        if[switch 0;
          kwargs[`start]:.ut.q2ISO start];
        if[switch 1;
          kwargs[`end]:.ut.q2ISO end];
        if[switch 2;
          kwargs[`granularity]:granularity];
        res: .qb.PC.get_product_historic_rates[pid; pykwargs kwargs];
        rates: `time`low`high`open`close`volume!flip "zfffff"$/:.[res; (::; 0); .ut.epoch2Q];
        flip rates};

    // called via
    q)getProductHistoricRates["BTC-USD"; 2018.04.01T08:00:00.000; 2018.04.01T09:00:00.000; 60]
    time                    low     high    open    close   volume   
    -----------------------------------------------------------------
    2018.04.01T08:59:00.000 6716    6716.01 6716    6716    2.113382 
    2018.04.01T08:58:00.000 6716    6716.01 6716    6716    2.167807 
    2018.04.01T08:57:00.000 6716    6716.01 6716.01 6716.01 0.4722202
    2018.04.01T08:56:00.000 6716    6720    6720    6716.01 1.913693 
    2018.04.01T08:55:00.000 6720    6723.06 6723.06 6720.01 0.686152 
    2018.04.01T08:54:00.000 6717.47 6724.29 6719.01 6723.06 9.784839 
    2018.04.01T08:53:00.000 6719    6724.01 6724.01 6719    3.328452 
    2018.04.01T08:52:00.000 6724    6724.01 6724    6724.01 3.423826 
    2018.04.01T08:51:00.000 6724    6725    6725    6724    2.958372 
    2018.04.01T08:50:00.000 6725    6737    6736.99 6725.01 4.761949 
    2018.04.01T08:49:00.000 6723    6737    6723    6737    29.7673 

Load all example wrappers with:

.. code:: bash

    ./startup_example basic

`source <https://github.com/michaelsimonelli/qoinbase-q/blob/master/code/core/basic.q>`_

Websocket Feed
==============
The Websocket Feed provides real-time market data updates for orders and trades.

The feed uses a bidirectional protocol, which encodes all messages as JSON objects.
All messages have a **type** attribute to identify the message and handle accordingly.

To begin receiving messages, open a socket connection, and send a **subscribe** message to the server 
indicating which *products* and *channels* to receive.

While the python library provides a websocket client, this guide connects to the feed natively.
This helps to reduce the number of data hops, type conversion, and takes advantage of q's speed and processing power.

More information on the websocket feed can be found `here <https://docs.pro.coinbase.com/#websocket-feed>`_

| The Websocket Feed drives the data portion of the application. 
| It's an integral component of several key operations:

* market data
* order book engine
* data analysis (under development)
* trade signals (under development)
* order execution (under development)

See websocket feed in action with:

.. code:: bash

    ./startup_example feed

`source <https://github.com/michaelsimonelli/qoinbase-q/blob/master/code/core/feed.q>`_

Open Connection
***************
The connection is created via kdb's websocket `protocol <https://code.kx.com/q/cookbook/websockets/>`_

**Key Components**

- The system callback `.z.ws <https://code.kx.com/q/ref/dotz/#zws-websockets>`_ must be defined.
- An entrypoint callback (message router) must be created.
- Open socket wrapper (recommended)

.. note::
    Most websockets will utilize SSL to encrypt connections.

    This repo comes packaged with OpenSSL 1.0.2. (later versions will not work)
    
    For more information `visit <https://code.kx.com/q/cookbook/ssl/>`_

.. code-block:: q

    // system callback
    q).z.ws:{value[.ws.W[.z.w]`cb]x};  // .ws.W is a dict to store connections 
    // entrypoint callback / message router
    q).feed.upd:{
        e: .j.k x;          // cast to q object
        t: `$e`type;        // get message type
        if[t in key .msg;   // check handler exists for this message type
          .msg[t]e];        // handle message
        };
    // open socket wrapper
    q).ws.open:{[url;cb]
        u: `prot`user`host`endp!.ws.hap url;  // breaksdown the url
        k: ("Host"; "Origin"; "Upgrade"; "Connection"; "Sec-WebSocket-Version");
        v: (u`host; u`host; "websocket"; "Upgrade"; "13");
        d: ("\r\n" sv ": " sv/: flip (k;v)),"\r\n\r\n";  // builds http request header
        r: "GET ",u[`endp]," HTTP/1.1\r\n",d;            // builds full get request
        h: first (hsym `$raze u`prot`host) r;            // sends request to url endpoint
        .ws.W[h]: (`$u`host; cb);
        0N!(.z.Z; "ws open"; h);   
        neg h};

**.ws.open** is called with:

*url*
    The service address (ip, host:port, url) to point the connection at.

*cb*
    The entrypoint callback function to route/handle messages on this specific connection.

Subscription
------------
Subscription function to send a subscribe message to the server 
indicating which *products* and *channels* to receive.

.. code-block:: q

    // subscription function
    q).feed.sub:{[h;p;c]
        p: .ut.enlist p;
        c: c union `heartbeat;
        s: .j.j (`type`product_ids`channels)!("subscribe"; p; c);
        h[s];
        };
    // create socket via .ws.open function
    q).feed.handle:.ws.open["wss://ws-feed.pro.coinbase.com"; `.feed.upd];
    // create subscrition with socket handle
    q).feed.sub[.feed.handle; `$("BTC-USD";"ETH-USD"); `ticker`level2];

Now the process will begin recieving messages for the ticker and level2 channel

Message Handler
---------------
After a message is received by the entrypoint callback, it will be routed to the appropriate message handler.

Depending on which ch

Ticker channel
^^^^^^^^^^^^^^
The ticker channel provides real-time price updates every time a match happens.

Each of these updates will be evaluated by the ticker message handler, processed, and upserted into the trade table.

.. code-block:: q

    // create tables to store updates
    q)md:([sym:`symbol$()]bp:`float$();ap:`float$();tp:`float$();vwap:`float$());
    q)trade:([] time:`datetime$();sym:`symbol$();price:`float$();bid:`float$();ask:`float$();side:`$();size:`float$();id:`long$());
    // create ticker message handler
    q).msg.ticker:{
        // checks message format is valid
        if[not any `trade_id`time in key x; :(::)];
        if[.ut.isNull x`time; :(::)];
        // extract desired fields and cast
        x: "SFFFSZjF"$`product_id`price`best_bid`best_ask`side`time`trade_id`last_size#x;
        // rename fields and transform data
        x: `sym`price`bid`ask`side`time`id`size!value x;
        x: @[x; `sym; .Q.id];
        x: @[x; `time; "z"$];
        if[.ut.isNull x`id; x[`id]:0N];
        // update md (market data) table with latest trade price
        .[`md; (x`sym; `tp);: ; x`price];
        // upsert update into trade table
        `trade upsert x;
        };

Level2 channel
^^^^^^^^^^^^^^
On origin, the level2 channel sends a full book snapshot, subsequent messages contain book updates (side, price, size).

The level message handler is a bit more complex, please see source code at ``code/core/feed.q``

Ultimately, the channel provides data to build and maintain a real-time order book.

**Book Functions**

.. code-block:: q

    // view order book for symbol at depth
    q).qb.viewBook[`BTCUSD;5]
    bids    bqty       asks    aqty     
    ------------------------------------
    3582.28 0.203      3582.29 0.8844963
    3582.07 0.008      3583.25 0.01     
    3582.06 1          3583.26 4.998927 
    3581.89 6.968      3583.43 17.7     
    3581.86 0.00107475 3583.66 1
    
    // view vwap for symbol, by side, at depth
    q).qb.vwapBook[`BTCUSD;`buy;5]
    3583.364