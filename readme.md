# EGLproxy
EGLproxy is a wrapper translating EGL calls to GLX and WGL.
It was originally written by [Egor Artemov](https://github.com/souryogurt).

## Fork
This fork uses Make as the build system (the original version used CMake)
and makes it easy to cross-compile under Linux using MinGW.

## Nota Bene
For technical reasons it is not possible to statically compile a program
using EGLproxy, you have no other choice but to link the library's DLL.
