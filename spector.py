from inspect import *


def is_bound(obj):
    _self = getattr(obj, '__self__', None)
    return _self is not None


def is_prop(obj):
    return isinstance(obj, property)


def obj_cls(obj):
    if is_prop(obj):
        cls = _qual_cls(obj.fget)
        if cls:
            return cls
    if is_bound(obj):
        cls = _qual_cls(obj.__func__)
        if cls:
            return cls
    if ismethod(obj):
        for cls in getmro(obj.__self__.__class__):
            if cls.__dict__.get(obj.__name__) is obj:
                return cls
        obj = obj.__func__  # fallback to __qualname__ parsing
    cls = _qual_cls(obj)
    if cls:
        return cls
    return getattr(obj, '__objclass__', None)  # handle special descriptor objects


def _qual_cls(obj):
    if isfunction(obj):
        cls = getattr(getmodule(obj),
                      obj.__qualname__.split('.<locals>', 1)[0].rsplit('.', 1)[0])
        if isinstance(cls, type):
            return cls


