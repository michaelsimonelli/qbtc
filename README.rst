
******
cbproQ
******

Example trading environment.

A fully fledged, q based trading API with real time, integrated websocket feeds, and order book engine.

Uses embedPy to map a python Coinbase Pro API libaray natively in Q.

The interface utilizes embedPy to map a python coinbase package natively into kdb.

Easy to use functionality to interact with all levels of the coinbase API: Execute trades, view trade history, account details, and more.

Provides a subscription model to stream and save data for selected products.

Order book engine for storing and sorting top of book and book depth for selected products.


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

    $conda create env -f environment.yml

**Note:** The conda environment will download and install all required dependencies, including its own 64-bit kdb/q installation.
The first time you run q from this environment, you will be prompted by a standard license agreement message and will be asked to enter some personal details such as Name and email address. Make sure to enter a valid email address because you will be asked to confirm your email address within 72 hours or your license will expire. If you already have a kdb+ license associated with your email address then kdb will just use that license after you enter that email address.

Configuration
-------------
The Coinbase Pro API key is required to run cbproQ
The API key is provided to kdb via the following envrinment variables
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

	$conda activate cbpro

**Step 2** Initialze KDB.  In terminal run:

.. code:: bash

	$./startup_example
