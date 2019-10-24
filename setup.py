from setuptools import setup, Extension
from Cython.Build import cythonize
from glob import glob

ext = Extension('imagequant', ['imagequant/imagequant.pyx'] +
                              glob('pngquant/lib/*.c'), 
                include_dirs=['pngquant/lib'],
                extra_compile_args=['-std=c99'])

setup(
  name = 'imagequant',
  ext_modules = cythonize(ext),
  install_requires = [
    'Cython>=0.29']
)
