import io
import sys
import pyment
import inspect
import types
from dataclasses import dataclass
from dataclasses import field
from dataclasses import InitVar
from collections import namedtuple
from typing import Dict
from typing import TypeVar
from typing import Any
from enum import Enum
import cbpro

T = TypeVar('T')

def reflect(module):
    name = _get_name(module)
    reflect_info = _reflect(module)
    return {name: reflect_info}