import types
from inspect import *
from collections import namedtuple

IMember = namedtuple('IMember', 'name obj')


class Dot(dict):
    """dot.notation access to dictionary attributes"""
    __getattr__ = dict.get
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__


predicates = Dot()
predicates.code = ['istraceback', 'isframe', 'iscode']
predicates.part = ['isabstract', 'isclass', 'ismodule']
predicates.desc = ['isdatadescriptor', 'isgetsetdescriptor', 'ismemberdescriptor']
predicates.func = ['isroutine', 'isbuiltin', 'isfunction', 'ismethod', 'ismethoddescriptor']
predicates.ops = ['isawaitable', 'iscoroutine', 'isgenerator', 'isasyncgen', 'isasyncgenfunction',
                  'iscoroutinefunction', 'isgeneratorfunction']
predicates.all = [i for s in list(predicates.values()) for i in s]


def show(arr):
    for i, a in enumerate(arr):
        print(i, a)


def get_name(obj):
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


def get_obj_cls(obj):
    if is_prop(obj):
        cls = get_obj_qual_cls(obj.fget)
        if cls:
            return cls
    if is_bound(obj):
        cls = get_obj_qual_cls(obj.__func__)
        if cls:
            return cls
    if ismethod(obj):
        for cls in getmro(obj.__self__.__class__):
            if cls.__dict__.get(obj.__name__) is obj:
                return cls
        obj = obj.__func__  # fallback to __qualname__ parsing
    cls = get_obj_qual_cls(obj)
    if cls:
        return cls
    return getattr(obj, '__objclass__', None)  # handle special descriptor objects


def get_obj_qual_cls(obj):
    if isfunction(obj):
        cls = getattr(getmodule(obj),
                      obj.__qualname__.split('.<locals>', 1)[0].rsplit('.', 1)[0])
        if isinstance(cls, type):
            return cls


def is_bound(obj):
    _self = getattr(obj, '__self__', None)
    return _self is not None


def is_prop(obj):
    return isinstance(obj, property)


def get_members(obj, predicate):
    return [IMember(*m) for m in getmembers(obj, predicate)]


def chk_obj_pred(x):
    if isinstance(x, Attribute):
        obj = x.object
        name = x.name
        kind = x.kind
        typ = type(obj)
    else:
        obj = x
        name = get_name(x)
        kind = type(obj)
        typ = type(kind)
    
    valid = []
    for p in predicates.all:
        pc = eval(p)
        pv = pc(obj)
        if pv:
            valid.append(p)
    if valid:
        print(f"name:{name}, kind:{kind}, type:{typ},")
        show(valid)


def categorize_obj(obj):
    cat = Dot()
    for p in predicates.all:
        pv = eval(p)
        mem = getmembers(obj, pv)
        dtm = Dot({p: mem})
        cat.update(dtm)
    return cat



def func_info(func):
    base = _obj_cls(func)
    name = _obj_name(func)
    if name.startswith('_') and name is not '__init__':
        return
    _mod = getmodule(func)
    if base in [types.BuiltinFunctionType,types.BuiltinMethodType]:
        if _mod:
            base = _mod
    dict_obj = base.__dict__[name] if _mod else func
    if isbuiltin(func):
        kind = "builtin method"
    # Classify the object or its descriptor.
    elif isinstance(dict_obj, (staticmethod, types.BuiltinMethodType)):
        kind = "static method"
        func = dict_obj
    elif isinstance(dict_obj, (classmethod, types.ClassMethodDescriptorType)):
        kind = "class method"
        func = dict_obj
    elif isinstance(dict_obj, property):
        kind = "property"
        func = dict_obj
    elif isroutine(func):
        kind = "method"
    else:
        kind = "data"
    res = Attribute(name, kind, base, func)
    return res
