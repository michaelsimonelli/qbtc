import inspect


# Python q reflection functions.
#
# Utility module for py.q embedPy framework.
# Provides metadata and type information for imported python modules


def get_mod_info(py_mod):
    return _get_module_info(py_mod)


def get_inst_attr(py_inst):
    return _get_instance_attributes(py_inst)


def get_type(py_obj):
    obj_type = type(py_obj)
    type_name = obj_type.__name__
    return type_name


#############################
# Internal Functions - not to be used in kdb
#############################


def _get_module_info(module):
    """Returns member info for an imported python module.

    Multilevel nested dictionary:
        - classes
        - functions
        - parameters
        - properties
        - doc strings"""

    module_info = {}

    for cls in [c for n, c in inspect.getmembers(module, inspect.isclass)]:
        class_info = _get_class_info(cls)
        module_info.update(class_info)

    return module_info


def _get_class_info(cls):
    class_name = cls.__name__
    class_meta = {}

    for data in sorted([x for x in inspect.getmembers(cls)], key=lambda x: str(x[1])):
        name = data[0]
        member = data[1]

        if (name.startswith('_')) & (name != '__init__'):
            continue

        member_info = _get_member_info(member)
        if member_info is not None:
            class_meta.update(member_info)

    class_attr = _get_class_attributes(cls)
    if class_attr is not None:
        class_meta.update(class_attr)

    class_info = {class_name: _sort_class_meta(class_meta)}

    return class_info


def _get_member_info(member):
    if inspect.isroutine(member):
        member_info = _get_function_info(member)
        return member_info
    elif _is_property(member):
        member_info = _get_property_info(member)
        return member_info
    else:
        return


def _get_function_info(func):
    if _is_irregular_method(func):
        func = func.__func__
    name = func.__name__
    doc = func.__doc__

    if doc is not None:
        doc = doc.split('\n')
    else:
        doc = ""

    py_class = _get_class_that_defined_component(func)
    method = type(py_class.__dict__[name]).__name__
    method = method.replace('method', 'Method')

    if name == '__init__':
        method = 'initialize'
    elif method == 'function':
        method = 'instanceMethod'

    args = []
    values = []
    default = []

    sig = inspect.signature(func)

    for k, v in sig.parameters.items():

        if k == 'self':
            continue

        args.append(k)

        if v.default is not inspect.Parameter.empty:
            default.append(v.name)
            values.append(v.default)

    required = [a for a in args if a not in default]

    meta = _comp_meta(method=method, args=args, default=default, values=values, required=required, doc=doc)
    info = {name: meta}

    return info


def _get_class_attributes(cls):
    class_attr = {}
    for k, v in cls.__dict__.items():
        if not inspect.isroutine(v):
            if k.startswith('_'):
                continue
            if isinstance(v, property):
                continue

            method = 'classAttribute'
            args = v
            attr_info = {k: _comp_meta(method=method, args=args)}
            class_attr.update(attr_info)
    return class_attr


def _get_instance_attributes(inst):
    inst_attr = {}
    for k, v in inst.__dict__.items():
        method = 'instanceAttribute'
        args = v
        attr_info = {k: _comp_meta(method=method, args=args)}
        inst_attr.update(attr_info)
    return inst_attr


def _get_property_info(prop):
    getter = prop.fget.__name__
    setter = prop.fset.__name__ if prop.fset is not None else 'no_setter'
    deleter = prop.fdel.__name__ if prop.fdel is not None else 'no_deleter'
    doc = prop.__doc__

    method = 'property'
    args = ['getter', 'setter', 'deleter']
    values = [getter, setter, deleter]
    name = _get_component_name(prop)

    info = {name: _comp_meta(method=method, args=args, values=values, doc=doc)}
    return info


def _get_class_that_defined_component(component):
    if _is_irregular_method(component):
        component = component.__func__

    if inspect.ismethod(component):
        for py_class in inspect.getmro(component.__self__.__class__):
            if py_class.__dict__.get(component.__name__) is component:
                return py_class
        component = component.__func__  # fallback to __qualname__ parsing

    if inspect.isfunction(component) | _is_property(component):
        if _is_property(component):
            component = component.fget

        py_class = getattr(inspect.getmodule(component),
                           component.__qualname__.split('.<locals>', 1)[0].rsplit('.', 1)[0])

        if isinstance(py_class, type):
            return py_class

    return None  # not required since None would have been implicitly returned anyway


def _get_component_name(component):
    if hasattr(component, '__name__'):
        return component.__name__

    py_class = _get_class_that_defined_component(component)
    for k, v in py_class.__dict__.items():
        if component == v:
            return k


def _is_property(component):
    if not inspect.isroutine(component):
        if isinstance(component, property):
            return True
    return False


def _is_regular_method(method):
    if inspect.isroutine(method):
        if not _is_static_method(method) \
                and not _is_class_method(method):
            return True

    return False


def _is_irregular_method(method):
    if isinstance(method, classmethod) | isinstance(method, staticmethod):
        return True

    return False


def _is_class_method(method):
    if inspect.isroutine(method):
        if isinstance(method, classmethod):
            return True

        name = method.__name__
        py_class = _get_class_that_defined_component(method)
        if name in py_class.__dict__:
            bind_value = py_class.__dict__[name]
            if isinstance(bind_value, classmethod):
                return True

    return False


def _is_static_method(method):
    if inspect.isroutine(method):
        if isinstance(method, staticmethod):
            return True

        name = method.__name__
        py_class = _get_class_that_defined_component(method)
        if name in py_class.__dict__:
            bind_value = py_class.__dict__[name]
            if isinstance(bind_value, staticmethod):
                return True

    return False


def _comp_meta(method="", args=None, default=None, values=None, required=None, doc=""):
    meta_dict = locals()
    for k, v in meta_dict.items():
        if v is None:
            meta_dict[k] = []

    return meta_dict


def _sort_class_meta(class_meta):
    new = []
    idx = []
    for k, v in class_meta.items():
        m = v['method']
        i = _sort_map[m]
        d = {k: v}
        new.append(d)
        idx.append(i)

    sort_meta_list = [x for _, x in sorted(zip(idx, new), key=lambda pair: pair[0])]
    sort_meta_dict = {k: v for d in sort_meta_list for k, v in d.items()}
    return sort_meta_dict


_sort_map = dict(initialize=0, classAttribute=1, classMethod=2, staticMethod=3, property=4, instanceMethod=5)