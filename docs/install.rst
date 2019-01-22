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
    
    ``64-bit kdb requires license file``

    The first time you run q from this environment, you will be prompted by a standard license agreement message. 
     
    Make sure to enter a valid email address because you will be asked to confirm within 72 hours or your license will expire. 
    If you already have a kdb+ license associated with your email address then kdb will just use that license after you enter that email address.


Configuration
-------------
The Coinbase Pro API key is required to run cbproQ
The API key is provided to kdb via the following environment variables:

- CBPRO_ENV
- CBPRO_PRIV_KEY
- CBPRO_PRIV_SECRET
- CBPRO_PRIV_PASSPHRASE

An example startup script is included to provide your API key and launch cbproQ.
Please reference *startup_example* for details

**SANDBOX MODE STRONGLY RECOMMENDED. LIVE TRADES CAN BE EXCUTED VIA THIS API.**