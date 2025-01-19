import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from src.main import add

def test_add():
    assert add(3, 3) == 6
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
