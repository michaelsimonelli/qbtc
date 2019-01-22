CoinbasePro-Q Documentation
===========================

Overview
--------

Q/kdb engine for the Coinbase Pro API (formerly known as the GDAX)

| This is a POC application, with the goal to implement a q/kdb based trading engine/API.
| The app leverages fusion technology, the embedPy interface, to extend python libraries and map them natively in q.

**Core Components:**

- Data feed subscription and dissemination
- Order book engine/market data consumption
- API execution and interaction
- Application configuration

| With the fusion of python and q, operations that would have been difficult or complex in q alone, are easily executed with little overhead or development.
| Further, by incorporating such operations natively, the application can leverage the processing power and speed of the q server directly, and maintain API calls, data storage, and analysis, all in one process.


Get the code
------------

The `source <https://github.com/michaelsimonelli/cbproQ>`_ is available on Github. 

Contents
--------

.. toctree::
   :maxdepth: 2

   install
