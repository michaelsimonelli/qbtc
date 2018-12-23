import io, sys
import inspect
import pyment

from dataclasses import dataclass,field



@dataclass
class PyDox:
    name: str = None
    raw: str = None
    desc: str = None
    params: dict = field(default_factory=dict)
    returns: dict = field(default_factory=dict)
    rtype: list = field(default_factory=list)
    types: list = field(default_factory=list)
    raises: list = field(default_factory=list)


def get_doc_info(obj):
    _predicates = [inspect.iscode,
                   inspect.isclass,
                   inspect.isframe,
                   inspect.ismethod,
                   inspect.isfunction,
                   inspect.istraceback]
    
    if not any(p(obj) for p in _predicates):
        return
    
    src = inspect.getsource(obj)
    stream = io.StringIO(src)
    sys.stdin = stream
    
    pyc = pyment.PyComment('-')
    pyc.docs_init_to_class()
    
    sys.stdin = sys.__stdin__
    
    docs = pyc.docs_list[0]['docs']
    elem = docs.element
    name = elem['name']
    
    info = docs.docs['in']
    info.pop('doctests')
    
    params = {}
    returns = {}
    for p in info.pop('params'):
        de = [DocEntry(*p)]
        for d in de:
            x = {d.key: d}
            params.update(x)
    
    _returns = info.pop('return')
    if _returns:
        if len(_returns) > 0:
            de = DocEntry(*_returns[0])
            returns.update(de.__dict__)
    
    return DocInfo(name=name, params=params, returns=returns, **info)


@dataclass
class PyCent:
    key: str = None
    desc: str = None
    py_typ: str = None


