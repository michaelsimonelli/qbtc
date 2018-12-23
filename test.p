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