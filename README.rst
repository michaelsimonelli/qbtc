
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
- Coinbase Pro account (live or sandbox)
- *All testing performed on Ubuntu 18.04*

Install
-------
**Step 1** Clone or download the repo

**Step 2** Create conda environment. In terminal run:

Install the package (or add it to your ``requirements.txt`` file):

.. code:: bash

    pip install sphinx_rtd_theme

.. code:: bash

    conda create env -f environment.yml
