import io
import sys
import pyment
import inspect
from enum import IntEnum
from collections import namedtuple, OrderedDict


# Python q reflection functions.
#
# Utility module for py.q embedPy framework.
# Provides metadata and type information for imported python modules


# Python q reflection functions.
#
# Utility module for py.q embedPy framework.
# Provides metadata and type information for imported python modules


def reflect(module):
    # Returns member info for an imported python module.
    
    # Multilevel nested dictionary:
    #   - module
    #   -- classes
    #   --- attributes
    #   ----- properties
    
    mi = MemberInfo(module)
    classes = {}
    for cls in mi.get_members(inspect.isclass):
        attributes = OrderedDict()
        attributes['data'] = {x.name: x.cxt() for x in cls.get_data()}
        attributes['properties'] = {x.name: x.cxt() for x in cls.get_properties()}
        attributes['functions'] = {x.name: x.cxt() for x in cls.get_functions()}
        attr_cxt = dict(attributes=attributes, doc=cls.doc)
        classes.update({cls.name: attr_cxt})
    
    class_cxt = dict(classes=classes)
    return {mi.name: class_cxt}


def get_inst_attrs(inst):
    inst_vars = {}
    for key, val in inst.__dict__.items():
        if key.startswith('_'):
            continue
        ptyp = _get_name(type(val))
        inst_cxt = dict(pval=val, ptyp=ptyp)
        inst_vars.update({key: inst_cxt})
    return inst_vars


#############################
# Internal Functions - not to be used in kdb
#############################


def _is_pub(name):
    return not name.startswith('_') or name is '__init__'


def _get_name(obj):
    for i in range(0, 4):
        if i == 0:
            pass
        elif i == 1:
            if hasattr(obj, '__func__'):
                obj = obj.__func__
        elif i == 2:
            if isinstance(obj, property):
                obj = obj.fget
        elif i == 3:
            obj = type(obj)
        if hasattr(obj, '__name__'):
            return obj.__name__


def _get_doc(obj):
    _doc = inspect.getdoc(obj)
    return _doc.splitlines() if isinstance(_doc, str) else ''


def _doc_str_meta(obj):
    src = inspect.getsource(obj)
    stream = io.StringIO(src)
    
    sys.stdin = stream
    pyc = pyment.PyComment('-')
    pyc.docs_init_to_class()
    sys.stdin = sys.__stdin__
    
    doc_list = pyc.docs_list[0]['docs']
    doc_index = doc_list.docs['in']
    
    meta_key = ['params', 'return']
    meta_sub = {k: doc_index[k] for k in meta_key}
    meta_cxt = dict.fromkeys(meta_key, {})
    
    for key, lst in meta_sub.items():
        if lst:
            meta_cxt[key] = {i[0]: DocStrElem(*i) for i in lst}
    
    return meta_cxt


DocStrElem = namedtuple('DocStrElem', 'name desc ptyp')


class AttrType(IntEnum):
    INIT = 0,
    CLASS_VAR = 1,
    PROPERTY = 2,
    INSTANCE_METHOD = 3,
    CLASS_METHOD = 4,
    STATIC_METHOD = 5


class MemberInfo:
    def __init__(self, obj, name=None):
        self.obj = obj
        self.name = name
        if not self.name:
            self.name = _get_name(obj)
        self.doc = _get_doc(self.obj)
        self.py_type = type(self.obj)
    
    def get_members(self, predicate):
        return [MemberInfo(m[1], m[0]) for m in inspect.getmembers(self.obj, predicate)]
    
    def get_data(self):
        data_info = [DataInfo(a) for a in inspect.classify_class_attrs(self.obj)
                     if _is_pub(a.name) and a.kind is 'data']
        return data_info
    
    def get_functions(self):
        method_info = [FuncInfo(a) for a in inspect.classify_class_attrs(self.obj)
                       if _is_pub(a.name) and 'method' in a.kind]
        return method_info
    
    def get_properties(self):
        property_info = [PropertyInfo(a) for a in inspect.classify_class_attrs(self.obj)
                         if _is_pub(a.name) and a.kind is 'property']
        return property_info


class AttrInfo(MemberInfo):
    _kind_map = {
        'static method': AttrType.STATIC_METHOD,
        'class method':  AttrType.CLASS_METHOD,
        'property':      AttrType.PROPERTY,
        'method':        AttrType.INSTANCE_METHOD,
        'data':          AttrType.CLASS_VAR
    }
    
    def __init__(self, attr: inspect.Attribute):
        super().__init__(attr.object, attr.name)
        self.def_class = attr.defining_class
        self.attr_kind = attr.kind
        
        if attr.name is '__init__':
            _attr_type = AttrType.INIT
        else:
            _attr_type = self._kind_map[attr.kind]
            if attr.name.startswith('_'):
                self.exposed = False
        
        self.attr_type = _attr_type
        self.properties = {}
    
    def cxt(self):
        kind = self.attr_type.name.lower()
        meta = {'kind': kind, **self.properties, 'doc': self.doc}
        return meta


class DataInfo(AttrInfo):
    def __init__(self, attr: inspect.Attribute):
        super().__init__(attr)
        self.pval = self.obj
        self.ptyp = _get_name(type(self.pval))
        self.properties = dict(pval=self.pval, ptyp=self.ptyp)


class PropertyInfo(AttrInfo):
    def __init__(self, attr: inspect.Attribute):
        super().__init__(attr)
        prop = self.obj
        accessors = dict(getter='fget', setter='fset', deleter='fdel')
        self.properties = {k: not not getattr(prop, v) for k, v in accessors.items()}


class FuncInfo(AttrInfo):
    def __init__(self, attr: inspect.Attribute):
        super().__init__(attr)
        print(attr)
        func = self.obj if self.attr_type not in [4, 5] else self.obj.__func__
        self.signature = inspect.signature(func)
        self.doc_meta = _doc_str_meta(func)
        
        _parameters = {}
        param_meta = self.doc_meta.get('params', None)
        for param in self.signature.parameters.values():
            if param.name is 'self':
                continue
            
            param_info = ParamInfo(param)
            if param_meta and param.name in param_meta:
                data = param_meta[param.name]
                param_info.doc = data.desc.splitlines()
                param_info.ptyp = data.ptyp
            
            param_cxt = param_info.cxt()
            _parameters.update(param_cxt)
        
        _returns = {}
        return_meta = self.doc_meta.get('return', None)
        if return_meta:
            data = [*return_meta.values()][0]
            doc = data.desc.splitlines()
            ptyp = data.ptyp
            _returns = dict(doc=doc, ptyp=ptyp)
        
        self.parameters = _parameters
        self.returns = _returns
        self.properties = dict(parameters=self.parameters, returns=self.returns)


emptyParam = inspect.Parameter.empty


class ParamInfo(MemberInfo):
    def __init__(self, param: inspect.Parameter):
        super().__init__(param, param.name)
        self.ptyp = ''
        self.default = param.default
        self.param_kind = param.kind
        self.has_default = param.default is not emptyParam
        self._variadic = self.param_kind in [2, 4]
        self.required = not self._variadic and not self.has_default
    
    def cxt(self):
        kind = self.param_kind.name.lower()
        ptyp = self.ptyp.replace('Optional', '').strip('[]')
        cxt = dict(kind=kind, ptyp=ptyp,
                   default=self.default, has_default=self.has_default,
                   required=self.required, doc=self.doc)
        return {self.name: cxt}
