import os
import tenjin

# create engine object
engine = tenjin.SafeEngine(path=[os.path.join(os.getcwd(), 'config')])
