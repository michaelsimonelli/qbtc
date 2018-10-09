import inspect

sort_map = dict(initialize=0, classAttribute=1, classMethod=2, staticMethod=3, property=4, instanceMethod=5)

def pq_list(x):
    return list(x)

def meta_dict_sort(md):
    new = []
    idx = []
    for k, v in md.items():
        m = v['method']
        i = sort_map[m]
        d = {k: v}
        new.append(d)
        idx.append(i)

    sort_list = [x for _, x in sorted(zip(idx, new), key=lambda pair: pair[0])]
    sort_dict = {k: v for d in sort_list for k, v in d.items()}
    return sort_dict


def get_module_info(mod):
    """Returns member info for an imported python module.

    Multilevel nested dictionary:
        - classes
        - functions
        - parameters
        - properties
        - doc strings"""

    module_info = {}

    for klass in [c for n, c in inspect.getmembers(mod, inspect.isclass)]:
        class_info = get_class_info(klass)
        module_info.update(class_info)

    return module_info


def get_class_info(klass):
    class_name = klass.__name__
    class_info = {}

    for component in sorted([x for x in inspect.getmembers(klass)], key=lambda x: str(x[1])):
   # for component in sorted([x for x in klass.__dict__.items()], key=lambda x: str(x[1])):
        name = component[0]
        value = component[1]

        if (name.startswith('_')) & (name != '__init__'):
            continue

        component_info = get_component_info(value)
        if component_info is not None:
            class_info.update(component_info)

    class_attr = get_class_attributes(klass)
    if class_attr is not None:
        class_info.update(class_attr)

    class_meta = {class_name: meta_dict_sort(class_info)}

    return class_meta


def get_component_info(component):
    if inspect.isroutine(component):
        member_info = get_func_info(component)
        return member_info
    elif is_property(component):
        member_info = get_prop_info(component)
        return member_info
    else:
        return


def get_func_info(func):
    if is_irregular_method(func):
        func = func.__func__
    name = func.__name__
    doc = func.__doc__

    if doc is not None:
        doc = doc.split('\n')
    else:
        doc = ""

    klass = get_class_that_defined_component(func)
    method = type(klass.__dict__[name]).__name__
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

    meta = q_meta(method=method, args=args, default=default, values=values, required=required, doc=doc)
    info = {name: meta}

    return info


def get_class_attributes(klass):
    class_attr = {}
    for k, v in klass.__dict__.items():
        if not inspect.isroutine(v):
            if k.startswith('_'):
                continue
            if isinstance(v, property):
                continue

            method = 'classAttribute'
            args = v
            attr_info = {k: q_meta(method=method, args=args)}
            class_attr.update(attr_info)
    return class_attr


def get_inst_attributes(inst):
    inst_attr = {}
    for k, v in inst.__dict__.items():
        method = 'instanceAttribute'
        args = v
        attr_info = {k: q_meta(method=method, args=args)}
        inst_attr.update(attr_info)
    return inst_attr


def get_prop_info(prop):
    getter = prop.fget.__name__
    setter = prop.fset.__name__ if prop.fset is not None else 'no_setter'
    deleter = prop.fdel.__name__ if prop.fdel is not None else 'no_deleter'
    doc = prop.__doc__

    method = 'property'
    args = ['getter', 'setter', 'deleter']
    values = [getter, setter, deleter]
    name = get_component_name(prop)

    info = {name: q_meta(method=method, args=args, values=values, doc=doc)}
    return info


def get_class_that_defined_component(component):
    if is_irregular_method(component):
        component = component.__func__

    if inspect.ismethod(component):
        for klass in inspect.getmro(component.__self__.__class__):
            if klass.__dict__.get(component.__name__) is component:
                return klass
        component = component.__func__  # fallback to __qualname__ parsing
    if inspect.isfunction(component) | is_property(component):
        if is_property(component):
            component = component.fget
        klass = getattr(inspect.getmodule(component),
                        component.__qualname__.split('.<locals>', 1)[0].rsplit('.', 1)[0])
        if isinstance(klass, type):
            return klass
    return None  # not required since None would have been implicitly returned anyway


def get_component_name(component):
    if hasattr(component, '__name__'):
        return component.__name__

    klass = get_class_that_defined_component(component)
    for k, v in klass.__dict__.items():
        if component == v:
            return k


def is_property(component):
    if not inspect.isroutine(component):
        if isinstance(component, property):
            return True
    return False


def is_regular_method(method):
    if inspect.isroutine(method):
        if not is_static_method(method) \
                and not is_class_method(method):
            return True

    return False


def is_irregular_method(method):
    if isinstance(method, classmethod) | isinstance(method, staticmethod):
        return True

    return False


def is_class_method(method):
    if inspect.isroutine(method):
        if isinstance(method, classmethod):
            return True

        name = method.__name__
        klass = get_class_that_defined_component(method)
        if name in klass.__dict__:
            binded_value = klass.__dict__[name]
            if isinstance(binded_value, classmethod):
                return True

    return False


def is_static_method(method):
    if inspect.isroutine(method):
        if isinstance(method, staticmethod):
            return True

        name = method.__name__
        klass = get_class_that_defined_component(method)
        if name in klass.__dict__:
            binded_value = klass.__dict__[name]
            if isinstance(binded_value, staticmethod):
                return True

    return False


def q_meta(method="", args=[], default=[], values=[], required=[], doc=""):
    q_info = dict(method=method, args=args, default=default, values=values, required=required, doc=doc)
    return q_info