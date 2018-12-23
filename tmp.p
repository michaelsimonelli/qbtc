class Bar:
    cvInt = 40
    cvData = dict(a=100,b=200)
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
    
    def instMethod(self):
        return self.prop, 'instance method called'
    
    def instFunc(self, x):
        return self.prop * x
    
    @classmethod
    def classMethod(cls):
        return cls.cvData, 'class method called'
    
    @staticmethod
    def staticMethod():
        return 'static method called'


class Foo:
    cvInt = 40
    cvEmpty = None
    """I'm the 'clsData' data."""
    
    def __init__(self, p):
        self._prop = p
    
    @property
    def prop(self):
        """I'm the 'x' property."""
        return self._prop
    
    
    def instMethod(self):
        return self._prop, 'instance method called', self
    
    @classmethod
    def classMethod(cls):
        return cls.cvEmpty, 'class method called', cls
    
    @staticmethod
    def staticMethod():
        return 'static method called'

lst = ['Provides access to Private Endpoints on the cbpro API.', '',
       "All requests default to the live `api_url`: 'https://api.pro.coinbase.com'.",
       'To test your application using the sandbox modify the `api_url`.', '', 'Attributes:',
       '    url (str): The api url for this client instance to use.',
       '    auth (CBProAuth): Custom authentication handler for each request.',
       '    session (requests.Session): Persistent HTTP connection object.']
ml = "Provides access to Private Endpoints on the cbpro API.\n\nAll requests default to the live `api_url`: 'https://api.pro.coinbase.com'.\nTo test your application using the sandbox modify the `api_url`.\n\nAttributes:\n    url (str): The api url for this client instance to use.\n    auth (CBProAuth): Custom authentication handler for each request.\n    session (requests.Session): Persistent HTTP connection object."


class Monster:
    """ Provides access to Private Endpoints on the cbpro API.
    All requests default to the live `api_url`: 'https://api.pro.coinbase.com'.
    To test your application using the sandbox modify the `api_url`.
    Attributes:
        url (str): The api url for this client instance to use.
        auth (CBProAuth): Custom authentication handler for each request.
        session (requests.Session): Persistent HTTP connection object.
    """
    
    def __init__(self, key, b64secret, password,
                 multi=1.5):
        """ Create an instance of the AuthenticatedClient class.
        Args:
            key (str): Your API key.
            b64secret (str): The secret key matching your API key.
            passphrase (str): Passphrase chosen when setting up key.
            multi (Optional[str]): API URL. Defaults to cbpro API.
        """
        self.multi = multi
        self.auth = (key, b64secret, password)
        self.session = dict(Session='session', auth=self.auth)
    
    def damage(self, caliber: int, power: int, distance: int = 100) -> float:
        """ Create an instance of the AuthenticatedClient class.
        Args:
            caliber (str): Bullet caliber.
            power (str): Gun power.
            distance (str): Fire distance.
        """
        return (caliber * power / distance) * self.multi
    
    def runner(self, gun: str, **kwargs) -> dict:
        """ Create an instance of the AuthenticatedClient class.
        Args:
            caliber (str): Bullet caliber.
            power (str): Gun power.
            distance (str): Fire distance.
        """
        run = {}
        for k, v in kwargs.items():
            run[k] = v
        return {gun: run}

def get_inst_attrs(inst):
    inst_vars = {}
    for key, val in inst.__dict__.items():
        if key.startswith('_'):
            continue
        ptyp = _get_name(type(val))
        inst_cxt = dict(pval=val, ptyp=ptyp)
        inst_vars.update({key: inst_cxt})
    return inst_vars