#####
Usage
#####

.. _usage_pymap-label:

Python Mapping
==============
Module mapping library for embedPy.

Recursive reflection module - traverses an imported python module mapping each class and all of its attributes to a respective q context or function library dictionary.

Source code at ``lib/py.q`` and ``lib/reflect.p``

Basics
******

The python mapper and cbpro python library are auto loaded with the base start up script.
Load interactive via:

.. code-block:: q

    \l lib/py.q
    .py.import[`cbpro];`
    .py.reflect[`cbpro];`

**NOTE:**

- All mapped modules can be found in the ``.pq`` namespace
- Module meta data can be found at ``.py.meta``

Meta Examples
-------------
Meta features: 

- displays a module's accessible classes and attributes
- stores class and attribute reference data and doc string where available
- provides functions signatures (parameter names, types, defaults, etc)

Display module classes

.. code-block:: q

    .py.meta.cbpro[`classes]`
                       | attributes                                                           
    -------------------| ------------------------------------------------------------------------------------------------------------...
    AuthenticatedClient| `data`properties`functions!(()!();()!();`__init__`buy`cancel_all`cancel_order`close_position`coinbase_deposi...
    CBProAuth          | `data`properties`functions!(()!();()!();(,`__init__)!+`kind`parameters`returns`doc!(,"init";,`api_key`secret...
    OrderBook          | `data`properties`functions!(()!();(,`product_id)!+`kind`getter`setter`deleter`doc!(,"property";,1b;,0b;,0b;,...
    PublicClient       | `data`properties`functions!(()!();()!();`__init__`get_currencies`get_product_24hr_stats`get_product_historic...
    WebsocketClient    | `data`properties`functions!(()!();()!();`__init__`close`on_close`on_error`on_message`on_open`start!+`kind`pa...

Display class doc string (or any attribute)

.. code-block:: q

    .py.meta.cbpro[`classes;`AuthenticatedClient;`doc]`
    "Provides access to Private Endpoints on the cbpro API."
    ""
    "All requests default to the live `api_url`: 'https://api.pro.coinbase.com'."
    "To test your application using the sandbox modify the `api_url`."
    ""
    "Attributes:"
    "    url (str): The api url for this client instance to use."
    "    auth (CBProAuth): Custom authentication handler for each request."
    "    session (requests.Session): Persistent HTTP connection object."

List class functions

.. code-block:: q

    .py.meta.cbpro[`classes;`AuthenticatedClient;`attributes;`functions]
                              | kind              parameters                                                                                                  
    --------                  | -----------------------------------------------------------------------------------------------------...
    __init__                  | "init"            `key`b64secret`passphrase`api_url!+`kind`ptyp`default`has_default`required`doc!(("p...
    buy                       | "instance_method" `product_id`order_type`kwargs!+`kind`ptyp`default`has_default`required`doc!(("posit...`
    cancel_all                | "instance_method" (,`product_id)!+`kind`ptyp`default`has_default`required`doc!(,"positional_or_keywor...`
    cancel_order              | "instance_method" (,`order_id)!+`kind`ptyp`default`has_default`required`doc!(,"positional_or_keyword"...`
    close_position            | "instance_method" (,`repay_only)!+`kind`ptyp`default`has_default`required`doc!(,"positional_or_keywor...`
    coinbase_deposit          | "instance_method" `amount`currency`coinbase_account_id!+`kind`ptyp`default`has_default`required`doc!(...`
    coinbase_withdraw         | "instance_method" `amount`currency`coinbase_account_id!+`kind`ptyp`default`has_default`required`doc!(...`

List function parameters

.. code-block:: q

    .py.meta.cbpro[`classes;`AuthenticatedClient;`attributes;`functions;`buy;`parameters]
              | kind                    ptyp  default has_default required doc                                                        
    ----------| ----------------------------------------------------------------------------------------------------------------------
    product_id| "positional_or_keyword" "str" ::      0           1        ,"Product to order (eg. 'BTC-USD')"                        
    order_type| "positional_or_keyword" "str" ::      0           1        ,"Order type ('limit', 'market', or 'stop')"               
    kwargs    | "var_keyword"           ""    ::      0           0        ("Represents a parameter in a function signature.";"";"Has


Mapped Examples
---------------
Mapped features:

- stores the callable python reference in a q context
- classes can be 'instantiated' directly in q
- instantiating a class creates return a function library
- class functions can be called natively in q (will try and return q type, wrappers will be needed when a function does not return a comparable type .e.g generators)
- doc strings are also available for reference
- python help can also be displayed via :.p.help pc.get_currencies

Rules:

- class init functions can accept positional args, keyword args, or  a combination of both as long as positional args proceed the keyword args
- class init args must be enlisted - the underlying function accepts one list as its argument, matching the above signature

Instantiate a class

.. code-block:: q

    // returns a function library
    pc:.pq.cbpro.PublicClient[]
    get_currencies            | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_24hr_stats    | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_historic_rates| code.[code[foreign]]`.p.q2pargsenlist`
    get_product_order_book    | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_ticker        | code.[code[foreign]]`.p.q2pargsenlist`
    get_product_trades        | code.[code[foreign]]`.p.q2pargsenlist`
    get_products              | code.[code[foreign]]`.p.q2pargsenlist`
    get_time                  | code.[code[foreign]]`.p.q2pargsenlist`
    url                       | `get`set!({[f;x]embedPy[f;x]}[foreign]enlist[`:url;];{[f;x]embedPy[f;x]}[foreign]enlist[:;`:url
    auth                      | `get`set!({[f;x]embedPy[f;x]}[foreign]enlist[`:auth;];{[f;x]embedPy[f;x]}[foreign]enlist[:;`:au
    session                   | `get`set!({[f;x]embedPy[f;x]}[foreign]enlist[`:session;];{[f;x]embedPy[f;x]}[foreign]enlist[:;`
    docs_                     | ``func`vars!(::;`get_currencies`get_product_24hr_stats`get_product_historic_rates`get_product_o

Call a function and return data

.. code-block:: q

    pc.get_currencies[]
    `id`name`min_size`status`message`details!("BTC";"Bitcoin";"0.00000001";"online";::;`type`symbol`network_confirmations`sort_order`...
    `id`name`min_size`status`message`details!("EUR";"Euro";"0.01000000";"online";::;`type`symbol`sort_order`push_payment_methods!("fi...
    `id`name`min_size`status`message`details!("LTC";"Litecoin";"0.00000001";"online";::;`type`symbol`network_confirmations`sort_order...
    `id`name`min_size`status`message`details!("GBP";"British Pound";"0.01000000";"online";::;`type`symbol`sort_order`push_payment_met...
    `id`name`min_size`status`message`details`convertible_to!("USD";"United States Dollar";"0.01000000";"online";::;`type`symbol`sort_...
    `id`name`min_size`status`message`details!("ETH";"Ether";"0.00000001";"online";::;`type`symbol`network_confirmations`sort_order`cr...

Function with argument

.. code-block:: q

    pc.get_product_ticker[`$"BTC-USD"]
    trade_id| 58344642
    price   | "3503.45000000"
    size    | "8.56298791"
    time    | "2019-01-28T01:55:15.462Z"
    bid     | "3503"
    ask     | "3503.01"
    volume  | "4540.00797716"

Get and set instance variables

.. code-block:: q

    .cb.client.url.get`
    "https://api.pro.coinbase.com"
    .cb.client.url.set["testUrl"]
    .cb.client.url.get`
    "testUrl"

If function returns generater - use next,list to access

.. code-block:: q

    l:pc.get_product_trades[`$"BTC-USD"]
    foreign
    .pq.builtins.next[l]
    time    | "2019-01-28T01:56:05.307Z"
    trade_id| 58344816
    price   | "3507.76000000"
    size    | "0.00100000"
    side    | "sell"

Complex class init
    
.. code-block:: q
    
    // key, secret, passpharse are treated as positional args
    // api_url is treated a keyword arg
    ac:.pq.cbpro.AuthenticatedClient[("key";"secret";"passpharse";(,`api_url)!+(,`api_url)!,,"https://api.pro.coinbase.com"];
    buy                       | code.[code[foreign]]`.p.q2pargsenlist
    cancel_all                | code.[code[foreign]]`.p.q2pargsenlist
    cancel_order              | code.[code[foreign]]`.p.q2pargsenlist
    close_position            | code.[code[foreign]]`.p.q2pargsenlist
    coinbase_deposit          | code.[code[foreign]]`.p.q2pargsenlist
    coinbase_withdraw         | code.[code[foreign]]`.p.q2pargsenlist
    create_report             | code.[code[foreign]]`.p.q2pargsenlist
    crypto_withdraw           | code.[code[foreign]]`.p.q2pargsenlist
    deposit                   | code.[code[foreign]]`.p.q2pargsenlist
    get_account               | code.[code[foreign]]`.p.q2pargsenlist
    get_account_history       | code.[code[foreign]]`.p.q2pargsenlist
    get_account_holds         | code.[code[foreign]]`.p.q2pargsenlist
    get_accounts              | code.[code[foreign]]`.p.q2pargsenlist