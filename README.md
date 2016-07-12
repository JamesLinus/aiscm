# AIscm [![GPLv3](https://img.shields.io/github/license/wedesoft/aiscm.png)](https://www.gnu.org/copyleft/gpl.html) [![Circle CI](https://img.shields.io/circleci/project/wedesoft/aiscm/master.png)](https://circleci.com/gh/wedesoft/aiscm) [![Travis CI](https://travis-ci.org/wedesoft/aiscm.png?branch=master)](https://travis-ci.org/wedesoft/aiscm) [![GitHub](https://img.shields.io/github/release/wedesoft/aiscm.png)](https://github.com/wedesoft/aiscm/releases) [![Guile 2.0.11](http://img.shields.io/badge/Guile-2.0.11-yellow.png)](http://www.gnu.org/software/guile) [![amd64](http://img.shields.io/badge/architecture-amd64-lightgrey.png)](https://en.wikipedia.org/wiki/X86-64) [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.57554.png)](http://dx.doi.org/10.5281/zenodo.57554)

[**AIscm**][1] is a **real-time computer vision extension** for the [**Guile programming language**][2].
Performance in Scheme is achieved by means of a JIT compiler.

![](doc/aiscm.gif "AIscm")

## Download

You can download and unpack the latest release like this

```Shell
wget `curl -s https://api.github.com/repos/wedesoft/aiscm/releases/latest | grep download | grep xz | cut -d '"' -f 4`
```

## Dependencies

The dependencies can be installed like this

```Shell
sudo aptitude install autoconf automake libtool colorgcc pandoc libswscale-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev libmagickcore-dev libmjpegtools-dev guile-2.0-dev libreadline-dev
```

## Installation

Finally you can install the software as follows

```Shell
tar xJf aiscm-*.tar.xz
cd aiscm-*
./configure CC=colorgcc
make -j
make check -j
sudo make install
```

## See also

* [AIscm homepage][1]
* [AIscm packages for Debian 8.0][3] (via [openSuSE build service][6])

## External links

* [Lush: large-scale numerical computing](http://lush.sourceforge.net/)
* [Torch: Scientific computing for LuaJIT](http://torch.ch/)
* [Theano: Python library for JIT compiled array operations](http://deeplearning.net/software/theano/)
* [Bergstra et al.: Theano: A CPU and GPU math compiler in Python][5]
* [Ceemple C++ OpenCV IDE](http://www.ceemple.com/)
* [PeachPy: Portable assembly for Python](https://github.com/Maratyszcza/PeachPy)
* [Guile manual](http://www.gnu.org/software/guile/manual/)
* [GOOPS: object-oriented extension to Guile](https://www.gnu.org/software/goops/)
* [COOPS: Chicken Scheme object system](http://wiki.call-cc.org/eggref/4/coops)
* [System V Application Binary Interface](http://www.x86-64.org/documentation/abi.pdf)
* [Intel® 64 and IA-32 Architectures Software Developer Manuals](http://www.intel.com/content/www/us/en/processors/architectures-software-developer-manuals.html)
* [CLASP: Lisp with LLVM Jit and C++ foreign interface](https://github.com/drmeister/clasp)

[1]: http://wedesoft.github.io/aiscm/ "AIscm"
[2]: http://www.gnu.org/software/guile/ "Guile programming language"
[3]: http://software.opensuse.org/download.html?project=home%3Awedesoft&package=aiscm "AIscm Debian package"
[4]: https://github.com/wedesoft/aiscm/releases "AIscm source releases"
[5]: http://www.iro.umontreal.ca/~lisa/pointeurs/theano_scipy2010.pdf "Theano paper"
[6]: https://build.opensuse.org/package/show/home:wedesoft/aiscm "openSuSE AIscm build"
