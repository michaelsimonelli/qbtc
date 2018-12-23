
class Bar:
    cv_x = 40
    cv_data = dict(a=100, b=200)
    """I'm the 'clsData' data."""
    
    def __init__(self, p):
        self._prop = p
    
    @property
    def prop(self):
        """I'm the 'x' property."""
        return self._prop
    
    @prop.setter
    def prop(self, value):
        self._prop = value
    
    @prop.deleter
    def prop(self):
        del self._prop
    
    def instance_method(self):
        return self.prop * self.cv_x, 'instance method called'
    
    @classmethod
    def class_method(cls, arg_z):
        return cls.cv_data, 'class method called', arg_z
    
    @staticmethod
    def static_method(arg_a, arg_b):
        return arg_a, arg_b, 'static method called'


b = Bar(100)

bar_parts = [Bar.cv_x, Bar.cv_data, Bar.prop, Bar.instance_method, Bar.class_method, Bar.static_method]

bar_live = [b.cv_x, b.cv_data, b.prop, b.instance_method, b.class_method, b.static_method]


class Baz:
    cvInt = 40
    cvData = dict(a=100, b=200)
    """I'm the 'clsData' data."""
    
    def __init__(self, p):
        self._prop = p
    
    @property
    def prop(self):
        """I'm the 'x' property."""
        return self._prop
    
    @prop.setter
    def prop(self, value):
        self._prop = value
    
    @prop.deleter
    def prop(self):
        del self._prop
    
    def instance_method(self):
        return self.prop * self.cvInt, 'instance method called'
    
    def instFunc(self, x):
        return self.prop * x
    
    def instCV(self, x):
        return self.prop * self.cvInt * x
    
    @classmethod
    def class_method(cls):
        return cls.cvData, 'class method called'
    
    @staticmethod
    def static_method():
        return 'static method called'


class Monster:
    def __init__(self, key, b64secret, passphrase,
                 api_url="https://api.pro.coinbase.com"):
        """ Create an instance of the AuthenticatedClient class.
        Args:
            key (str): Your API key.
            b64secret (str): The secret key matching your API key.
            passphrase (str): Passphrase chosen when setting up key.
            api_url (Optional[str]): API URL. Defaults to cbpro API.
        """
        
        self.auth = (key, b64secret, passphrase)
        self.session = 'Session1'
    
    def get_account_history(self, account_id, **kwargs):
        """ List account activity. Account activity either increases or
        decreases your account balance.
        Entry type indicates the reason for the account change.
        * transfer:	Funds moved to/from Coinbase to cbpro
        * match:	Funds moved as a result of a trade
        * fee:	    Fee as a result of a trade
        * rebate:   Fee rebate as per our fee schedule
        If an entry is the result of a trade (match, fee), the details
        field will contain additional information about the trade.
        Args:
            account_id (str): Account id to get history of.
            kwargs (dict): Additional HTTP request parameters.
        Returns:
            list: History information for the account. Example::
                [
                    {
                        "id": "100",
                        "created_at": "2014-11-07T08:19:27.028459Z",
                        "amount": "0.001",
                        "balance": "239.669",
                        "type": "fee",
                        "details": {
                            "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
                            "trade_id": "74",
                            "product_id": "BTC-USD"
                        }
                    },
                    {
                        ...
                    }
                ]
        """
        endpoint = '/accounts/{}/ledger'.format(account_id)
        return endpoint
    
    def get_account_holds(self, account_id, **kwargs):
        """ Get holds on an account.
        This method returns a generator which may make multiple HTTP requests
        while iterating through it.
        Holds are placed on an account for active orders or
        pending withdraw requests.
        As an order is filled, the hold amount is updated. If an order
        is canceled, any remaining hold is removed. For a withdraw, once
        it is completed, the hold is removed.
        The `type` field will indicate why the hold exists. The hold
        type is 'order' for holds related to open orders and 'transfer'
        for holds related to a withdraw.
        The `ref` field contains the id of the order or transfer which
        created the hold.
        Args:
            account_id (str): Account id to get holds of.
            kwargs (dict): Additional HTTP request parameters.
        Returns:
            generator(list): Hold information for the account. Example::
                [
                    {
                        "id": "82dcd140-c3c7-4507-8de4-2c529cd1a28f",
                        "account_id": "e0b3f39a-183d-453e-b754-0c13e5bab0b3",
                        "created_at": "2014-11-06T10:34:47.123456Z",
                        "updated_at": "2014-11-06T10:40:47.123456Z",
                        "amount": "4.23",
                        "type": "order",
                        "ref": "0a205de4-dd35-4370-a285-fe8fc375a273",
                    },
                    {
                    ...
                    }
                ]
        """
        endpoint = f'{self.session}/accounts/{account_id}/holds'
        return endpoint
    
    def place_order(self, product_id, side, order_type, **kwargs):
        """ Place an order.
        The three order types (limit, market, and stop) can be placed using this
        method. Specific methods are provided for each order type, but if a
        more generic interface is desired this method is available.
        Args:
            product_id (str): Product to order (eg. 'BTC-USD')
            side (str): Order side ('buy' or 'sell)
            order_type (str): Order type ('limit', 'market', or 'stop')
            **client_oid (str): Order ID selected by you to identify your order.
                This should be a UUID, which will be broadcast in the public
                feed for `received` messages.
            **stp (str): Self-trade prevention flag. cbpro doesn't allow self-
                trading. This behavior can be modified with this flag.
                Options:
                'dc'	Decrease and Cancel (default)
                'co'	Cancel oldest
                'cn'	Cancel newest
                'cb'	Cancel both
            **overdraft_enabled (Optional[bool]): If true funding above and
                beyond the account balance will be provided by margin, as
                necessary.
            **funding_amount (Optional[Decimal]): Amount of margin funding to be
                provided for the order. Mutually exclusive with
                `overdraft_enabled`.
            **kwargs: Additional arguments can be specified for different order
                types. See the limit/market/stop order methods for details.
        Returns:
            dict: Order details. Example::
            {
                "id": "d0c5340b-6d6c-49d9-b567-48c4bfca13d2",
                "price": "0.10000000",
                "size": "0.01000000",
                "product_id": "BTC-USD",
                "side": "buy",
                "stp": "dc",
                "type": "limit",
                "time_in_force": "GTC",
                "post_only": false,
                "created_at": "2016-12-08T20:02:28.53864Z",
                "fill_fees": "0.0000000000000000",
                "filled_size": "0.00000000",
                "executed_value": "0.0000000000000000",
                "status": "pending",
                "settled": false
            }
        """
        # Margin parameter checks
        if kwargs.get('overdraft_enabled') is not None and \
                kwargs.get('funding_amount') is not None:
            raise ValueError('Margin funding must be specified through use of '
                             'overdraft or by setting a funding amount, but not'
                             ' both')
        
        # Limit order checks
        if order_type == 'limit':
            if kwargs.get('cancel_after') is not None and \
                    kwargs.get('time_in_force') != 'GTT':
                raise ValueError('May only specify a cancel period when time '
                                 'in_force is `GTT`')
            if kwargs.get('post_only') is not None and kwargs.get('time_in_force') in \
                    ['IOC', 'FOK']:
                raise ValueError('post_only is invalid when time in force is '
                                 '`IOC` or `FOK`')
        
        # Market and stop order checks
        if order_type == 'market' or order_type == 'stop':
            if not (kwargs.get('size') is None) ^ (kwargs.get('funds') is None):
                raise ValueError('Either `size` or `funds` must be specified '
                                 'for market/stop orders (but not both).')
        
        # Build params dict
        params = {'product_id': product_id,
                  'side':       side,
                  'type':       order_type,
                  'session':    self.session}
        params.update(kwargs)
        return params
    
    def annotate_order(self, product_id: str, side: str, order_type: str, kwargs: dict) -> dict:
        """ Place an order.
        The three order types (limit, market, and stop) can be placed using this
        method. Specific methods are provided for each order type, but if a
        more generic interface is desired this method is available.
        Args:
            product_id (str): Product to order (eg. 'BTC-USD')
            side (str): Order side ('buy' or 'sell)
            order_type (str): Order type ('limit', 'market', or 'stop')
            **client_oid (str): Order ID selected by you to identify your order.
                This should be a UUID, which will be broadcast in the public
                feed for `received` messages.
            **stp (str): Self-trade prevention flag. cbpro doesn't allow self-
                trading. This behavior can be modified with this flag.
                Options:
                'dc'	Decrease and Cancel (default)
                'co'	Cancel oldest
                'cn'	Cancel newest
                'cb'	Cancel both
            **overdraft_enabled (Optional[bool]): If true funding above and
                beyond the account balance will be provided by margin, as
                necessary.
            **funding_amount (Optional[Decimal]): Amount of margin funding to be
                provided for the order. Mutually exclusive with
                `overdraft_enabled`.
            **kwargs: Additional arguments can be specified for different order
                types. See the limit/market/stop order methods for details.
        Returns:
            dict: Order details. Example::
            {
                "id": "d0c5340b-6d6c-49d9-b567-48c4bfca13d2",
                "price": "0.10000000",
                "size": "0.01000000",
                "product_id": "BTC-USD",
                "side": "buy",
                "stp": "dc",
                "type": "limit",
                "time_in_force": "GTC",
                "post_only": false,
                "created_at": "2016-12-08T20:02:28.53864Z",
                "fill_fees": "0.0000000000000000",
                "filled_size": "0.00000000",
                "executed_value": "0.0000000000000000",
                "status": "pending",
                "settled": false
            }
        """
        # Margin parameter checks
        if kwargs.get('overdraft_enabled') is not None and \
                kwargs.get('funding_amount') is not None:
            raise ValueError('Margin funding must be specified through use of '
                             'overdraft or by setting a funding amount, but not'
                             ' both')
        
        # Limit order checks
        if order_type == 'limit':
            if kwargs.get('cancel_after') is not None and \
                    kwargs.get('time_in_force') != 'GTT':
                raise ValueError('May only specify a cancel period when time '
                                 'in_force is `GTT`')
            if kwargs.get('post_only') is not None and kwargs.get('time_in_force') in \
                    ['IOC', 'FOK']:
                raise ValueError('post_only is invalid when time in force is '
                                 '`IOC` or `FOK`')
        
        # Market and stop order checks
        if order_type == 'market' or order_type == 'stop':
            if not (kwargs.get('size') is None) ^ (kwargs.get('funds') is None):
                raise ValueError('Either `size` or `funds` must be specified '
                                 'for market/stop orders (but not both).')
        
        # Build params dict
        params = {'product_id': product_id,
                  'side':       side,
                  'type':       order_type,
                  'session':    self.session,
                  'annotate':   True}
        params.update(kwargs)
        return params
    
    def get_mine(self):
        return self.__class__.__name__
