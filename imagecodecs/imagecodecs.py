# -*- coding: utf-8 -*-
# imagecodecs.py

# Copyright (c) 2008-2018, Christoph Gohlke
# Copyright (c) 2008-2018, The Regents of the University of California
# Produced at the Laboratory for Fluorescence Dynamics.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

"""Image transformation, compression, and decompression codecs.

This module implements limited functionality of the imagecodec Cython
extension using pure Python and 3rd party packages.

:Author:
  `Christoph Gohlke <https://www.lfd.uci.edu/~gohlke/>`_

:Organization:
  Laboratory for Fluorescence Dynamics. University of California, Irvine

:Version: 2018.10.22

Revisions
---------
2018.10.22
    Add blosc codec based in blosc package.
    Fix FutureWarning with numpy 1.15.
2018.10.18
    Use Pillow for decoding jpeg, png, j2k, and webp.
2018.10.17
    Add dummy jpeg0xc3 codec.
2018.10.10
    Add dummy png codec.
    Improve delta codecs.
2018.9.30
    Add lzf codec based on python-lzf package.
2018.9.22
    Add dummy webp codec.
2018.8.29
    Add floatpred, lzw, packbits, packints decoders from tifffile.py module.
    Use zlib, bz2, lzma, zstd, and lz4 modules for codecs.

"""

from __future__ import division, print_function

__version__ = '2018.10.21.py'
__docformat__ = 'restructuredtext en'

import sys
import struct
import warnings
import functools
import zlib
import io

import numpy

try:
    import lzma
except ImportError:
    try:
        from backports import lzma
    except ImportError:
        lzma = None

try:
    import bz2
except ImportError:
    bz2 = None

try:
    import zstd
except ImportError:
    zstd = None

try:
    import lz4
    import lz4.block
except ImportError:
    lz4 = None

try:
    import lzf
except ImportError:
    lzf = None

try:
    import blosc
except ImportError:
    blosc = None

try:
    import PIL
except ImportError:
    PIL = None


def notimplemented(arg=False):
    """Return function decorator that raises NotImplementedError if not arg.

    >>> @notimplemented
    ... def test(): pass
    >>> test()
    Traceback (most recent call last):
    ...
    NotImplementedError: test

    >>> @notimplemented(True)
    ... def test(): pass
    >>> test()

    """
    def wrapper(func):
        @functools.wraps(func)
        def notimplemented(*args, **kwargs):
            raise NotImplementedError(func.__name__)
        return notimplemented

    if callable(arg):
        return wrapper(arg)
    if not arg:
        return wrapper

    def nop(func):
        return func

    return nop


def version(astype=str):
    """Return detailed version information."""
    versions = (('imagecodecs', __version__),
                ('zlib', zlib.ZLIB_VERSION))
    if lzma:
        versions += (('lzma', getattr(lzma, '__version__', sys.version[:5])),)
    if zstd:
        versions += (('zstd', zstd.version()),)
    if lz4:
        versions += (('lz4', lz4.VERSION),)
    if astype is str:
        return ', '.join('%s-%s' % (k, v) for k, v in versions)
    if astype is dict:
        return dict(versions)
    return versions


def none_decode(data, axis=None, out=None):
    """Decode NOP."""
    return data


def none_encode(data, level=None, axis=None, out=None):
    """Encode NOP."""
    return data


def delta_encode(data, axis=-1, out=None):
    """Encode Delta."""
    if isinstance(data, (bytes, bytearray)):
        data = numpy.frombuffer(data, dtype='u1')
        diff = numpy.diff(data, axis=0)
        return numpy.insert(diff, 0, data[0]).tobytes()

    dtype = data.dtype
    if dtype.kind == 'f':
        data = data.view('u%i' % dtype.itemsize)

    diff = numpy.diff(data, axis=axis)
    key = [slice(None)] * data.ndim
    key[axis] = 0
    diff = numpy.insert(diff, 0, data[tuple(key)], axis=axis)

    if dtype.kind == 'f':
        return diff.view(dtype)
    return diff


def delta_decode(data, axis=-1, out=None):
    """Decode Delta."""
    if isinstance(data, (bytes, bytearray)):
        data = numpy.frombuffer(data, dtype='u1')
        return numpy.cumsum(data, axis=0, dtype='u1', out=out).tobytes()

    if data.dtype.kind == 'f':
        view = data.view('u%i' % data.dtype.itemsize)
        view = numpy.cumsum(view, axis=axis, dtype=view.dtype)
        return view.view(data.dtype)
    return numpy.cumsum(data, axis=axis, dtype=data.dtype, out=out)


def xor_encode(data, axis=-1, out=None):
    """Encode XOR delta."""
    if isinstance(data, (bytes, bytearray)):
        data = numpy.frombuffer(data, dtype='u1')
        xor = numpy.bitwise_xor(data[1:], data[:-1])
        return numpy.insert(xor, 0, data[0]).tobytes()

    dtype = data.dtype
    if dtype.kind == 'f':
        data = data.view('u%i' % dtype.itemsize)

    key = [slice(None)] * data.ndim
    key[axis] = 0
    key0 = [slice(None)] * data.ndim
    key0[axis] = slice(1, None, None)
    key1 = [slice(None)] * data.ndim
    key1[axis] = slice(0, -1, None)

    key = tuple(key)
    key0 = tuple(key0)
    key1 = tuple(key1)

    xor = numpy.bitwise_xor(data[key0], data[key1])
    xor = numpy.insert(xor, 0, data[key], axis=axis)

    if dtype.kind == 'f':
        return xor.view(dtype)
    return xor


def xor_decode(data, axis=-1, out=None):
    """Decode XOR delta."""
    if isinstance(data, (bytes, bytearray)):
        prev = data[0]
        b = [chr(prev)]
        for c in data[1:]:
            prev = c ^ prev
            b.append(chr(prev))
        return ''.join(b).encode('latin1')
    raise NotImplementedError()


def floatpred_decode(data, axis=-2, out=None):
    """Decode floating point horizontal differencing.

    The TIFF predictor type 3 reorders the bytes of the image values and
    applies horizontal byte differencing to improve compression of floating
    point images. The ordering of interleaved color channels is preserved.

    Parameters
    ----------
    data : numpy.ndarray
        The image to be decoded. The dtype must be a floating point.
        The shape must include the number of contiguous samples per pixel
        even if 1.

    """
    # warnings.warn('using numpy FloatPred decoder')
    if axis != -2:
        raise NotImplementedError('axis %i != -2' % axis)
    shape = data.shape
    dtype = data.dtype
    if len(shape) < 3:
        raise ValueError('invalid data shape')
    if dtype.char not in 'dfe':
        raise ValueError('not a floating point image')
    littleendian = data.dtype.byteorder == '<' or (
        sys.byteorder == 'little' and data.dtype.byteorder == '=')
    # undo horizontal byte differencing
    data = data.view('uint8')
    data.shape = shape[:-2] + (-1,) + shape[-1:]
    numpy.cumsum(data, axis=-2, dtype='uint8', out=data)
    # reorder bytes
    if littleendian:
        data.shape = shape[:-2] + (-1,) + shape[-2:]
    data = numpy.swapaxes(data, -3, -2)
    data = numpy.swapaxes(data, -2, -1)
    data = data[..., ::-1]
    # back to float
    data = numpy.ascontiguousarray(data)
    data = data.view(dtype)
    data.shape = shape
    return data


@notimplemented
def floatpred_encode(data, axis=-1, out=None):
    """Encode Floating Point Predictor."""
    pass


def bitorder_decode(data, out=None, _bitorder=[]):
    """Reverse bits in each byte of byte string or numpy array.

    Decode data where pixels with lower column values are stored in the
    lower-order bits of the bytes (TIFF FillOrder is LSB2MSB).

    Parameters
    ----------
    data : byte string or ndarray
        The data to be bit reversed. If byte string, a new bit-reversed byte
        string is returned. Numpy arrays are bit-reversed in-place.

    Examples
    --------
    >>> bitorder_decode(b'\\x01\\x64')
    b'\\x80&'
    >>> data = numpy.array([1, 666], dtype='uint16')
    >>> bitorder_decode(data)
    >>> data
    array([  128, 16473], dtype=uint16)

    """
    if not _bitorder:
        _bitorder.append(
            b'\x00\x80@\xc0 \xa0`\xe0\x10\x90P\xd00\xb0p\xf0\x08\x88H\xc8('
            b'\xa8h\xe8\x18\x98X\xd88\xb8x\xf8\x04\x84D\xc4$\xa4d\xe4\x14'
            b'\x94T\xd44\xb4t\xf4\x0c\x8cL\xcc,\xacl\xec\x1c\x9c\\\xdc<\xbc|'
            b'\xfc\x02\x82B\xc2"\xa2b\xe2\x12\x92R\xd22\xb2r\xf2\n\x8aJ\xca*'
            b'\xaaj\xea\x1a\x9aZ\xda:\xbaz\xfa\x06\x86F\xc6&\xa6f\xe6\x16'
            b'\x96V\xd66\xb6v\xf6\x0e\x8eN\xce.\xaen\xee\x1e\x9e^\xde>\xbe~'
            b'\xfe\x01\x81A\xc1!\xa1a\xe1\x11\x91Q\xd11\xb1q\xf1\t\x89I\xc9)'
            b'\xa9i\xe9\x19\x99Y\xd99\xb9y\xf9\x05\x85E\xc5%\xa5e\xe5\x15'
            b'\x95U\xd55\xb5u\xf5\r\x8dM\xcd-\xadm\xed\x1d\x9d]\xdd=\xbd}'
            b'\xfd\x03\x83C\xc3#\xa3c\xe3\x13\x93S\xd33\xb3s\xf3\x0b\x8bK'
            b'\xcb+\xabk\xeb\x1b\x9b[\xdb;\xbb{\xfb\x07\x87G\xc7\'\xa7g\xe7'
            b'\x17\x97W\xd77\xb7w\xf7\x0f\x8fO\xcf/\xafo\xef\x1f\x9f_'
            b'\xdf?\xbf\x7f\xff')
        _bitorder.append(numpy.frombuffer(_bitorder[0], dtype='uint8'))
    try:
        view = data.view('uint8')
        numpy.take(_bitorder[1], view, out=view)
    except AttributeError:
        return data.translate(_bitorder[0])
    except ValueError:
        raise NotImplementedError('slices of arrays not supported')


bitorder_encode = bitorder_decode


@notimplemented
def packbits_encode(data, level=None, out=None):
    """Compress PackBits."""
    pass


def packbits_decode(encoded, out=None):
    r"""Decompress PackBits encoded byte string.

    >>> packbits_decode(b'\x80\x80')  # NOP
    b''
    >>> packbits_decode(b'\x02123')
    b'123'
    >>> packbits_decode(
    ...   b'\xfe\xaa\x02\x80\x00\x2a\xfd\xaa\x03\x80\x00\x2a\x22\xf7\xaa')[:-4]
    b'\xaa\xaa\xaa\x80\x00*\xaa\xaa\xaa\xaa\x80\x00*"\xaa\xaa\xaa\xaa\xaa\xaa'

    """
    # warnings.warn('using pure Python PackBits decoder')
    out = []
    out_extend = out.extend
    i = 0
    try:
        while True:
            n = ord(encoded[i:i+1]) + 1
            i += 1
            if n > 129:
                # replicate
                out_extend(encoded[i:i+1] * (258 - n))
                i += 1
            elif n < 129:
                # literal
                out_extend(encoded[i:i+n])
                i += n
    except TypeError:
        pass
    return b''.join(out) if sys.version[0] == '2' else bytes(out)


@notimplemented
def lzw_encode(data, level=None, out=None):
    """Compress LZW."""
    pass


def lzw_decode(encoded, buffersize=0, out=None):
    r"""Decompress LZW (Lempel-Ziv-Welch) encoded TIFF strip (byte string).

    The strip must begin with a CLEAR code and end with an EOI code.

    This implementation of the LZW decoding algorithm is described in (1) and
    is not compatible with old style LZW compressed files like quad-lzw.tif.

    >>> lzw_decode(b'\x80\x1c\xcc\'\x91\x01\xa0\xc2m6\x99NB\x03\xc9\xbe\x0b'
    ...            b'\x07\x84\xc2\xcd\xa68|"\x14 3\xc3\xa0\xd1c\x94\x02\x02')
    b'say hammer yo hammer mc hammer go hammer'

    """
    # warnings.warn('using pure Python LZW decoder')
    len_encoded = len(encoded)
    bitcount_max = len_encoded * 8
    unpack = struct.unpack

    if sys.version[0] == '2':
        newtable = [chr(i) for i in range(256)]
    else:
        newtable = [bytes([i]) for i in range(256)]
    newtable.extend((0, 0))

    def next_code():
        """Return integer of 'bitw' bits at 'bitcount' position in encoded."""
        start = bitcount // 8
        s = encoded[start:start+4]
        try:
            code = unpack('>I', s)[0]
        except Exception:
            code = unpack('>I', s + b'\x00'*(4-len(s)))[0]
        code <<= bitcount % 8
        code &= mask
        return code >> shr

    switchbits = {  # code: bit-width, shr-bits, bit-mask
        255: (9, 23, int(9*'1'+'0'*23, 2)),
        511: (10, 22, int(10*'1'+'0'*22, 2)),
        1023: (11, 21, int(11*'1'+'0'*21, 2)),
        2047: (12, 20, int(12*'1'+'0'*20, 2)), }
    bitw, shr, mask = switchbits[255]
    bitcount = 0

    if len_encoded < 4:
        raise ValueError('strip must be at least 4 characters long')

    if next_code() != 256:
        raise ValueError('strip must begin with CLEAR code')

    code = 0
    oldcode = 0
    result = []
    result_append = result.append
    while True:
        code = next_code()  # ~5% faster when inlining this function
        bitcount += bitw
        if code == 257 or bitcount >= bitcount_max:  # EOI
            break
        if code == 256:  # CLEAR
            table = newtable[:]
            table_append = table.append
            lentable = 258
            bitw, shr, mask = switchbits[255]
            code = next_code()
            bitcount += bitw
            if code == 257:  # EOI
                break
            result_append(table[code])
        else:
            if code < lentable:
                decoded = table[code]
                newcode = table[oldcode] + decoded[:1]
            else:
                newcode = table[oldcode]
                newcode += newcode[:1]
                decoded = newcode
            result_append(decoded)
            table_append(newcode)
            lentable += 1
        oldcode = code
        if lentable in switchbits:
            bitw, shr, mask = switchbits[lentable]

    if code != 257:
        warnings.warn('unexpected end of LZW stream (code %i)' % code)

    return b''.join(result)


@notimplemented
def packints_encode(*args, **kwargs):
    """Pack integers."""
    pass


def packints_decode(data, dtype, numbits, runlen=0, out=None):
    """Decompress byte string to array of integers of any bit size <= 32.

    This Python implementation is slow and only handles itemsizes 1, 2, 4, 8,
    16, 32, and 64.

    Parameters
    ----------
    data : byte str
        Data to decompress.
    dtype : numpy.dtype or str
        A numpy boolean or integer type.
    numbits : int
        Number of bits per integer.
    runlen : int
        Number of consecutive integers, after which to start at next byte.

    Examples
    --------
    >>> packints_decode(b'a', 'B', 1)
    array([0, 1, 1, 0, 0, 0, 0, 1], dtype=uint8)
    >>> packints_decode(b'ab', 'B', 2)
    array([1, 2, 0, 1, 1, 2, 0, 2], dtype=uint8)

    """
    # warnings.warn('using pure Python PackInts decoder')
    if numbits == 1:  # bitarray
        data = numpy.frombuffer(data, '|B')
        data = numpy.unpackbits(data)
        if runlen % 8:
            data = data.reshape(-1, runlen + (8 - runlen % 8))
            data = data[:, :runlen].reshape(-1)
        return data.astype(dtype)

    dtype = numpy.dtype(dtype)
    if numbits in (8, 16, 32, 64):
        return numpy.frombuffer(data, dtype)
    if numbits not in (1, 2, 4, 8, 16, 32):
        raise ValueError('itemsize not supported: %i' % numbits)
    if dtype.kind not in 'biu':
        raise ValueError('invalid dtype')

    itembytes = next(i for i in (1, 2, 4, 8) if 8 * i >= numbits)
    if itembytes != dtype.itemsize:
        raise ValueError('dtype.itemsize too small')
    if runlen == 0:
        runlen = (8 * len(data)) // numbits
    skipbits = runlen * numbits % 8
    if skipbits:
        skipbits = 8 - skipbits
    shrbits = itembytes*8 - numbits
    bitmask = int(numbits*'1'+'0'*shrbits, 2)
    dtypestr = '>' + dtype.char  # dtype always big-endian?

    unpack = struct.unpack
    size = runlen * (len(data)*8 // (runlen*numbits + skipbits))
    result = numpy.empty((size,), dtype)
    bitcount = 0
    for i in range(size):
        start = bitcount // 8
        s = data[start:start+itembytes]
        try:
            code = unpack(dtypestr, s)[0]
        except Exception:
            code = unpack(dtypestr, s + b'\x00'*(itembytes-len(s)))[0]
        code <<= bitcount % 8
        code &= bitmask
        result[i] = code >> shrbits
        bitcount += numbits
        if (i+1) % runlen == 0:
            bitcount += skipbits
    return result


def zlib_encode(data, level=6, out=None):
    """Compress Zlib DEFLATE."""
    return zlib.compress(data, level)


def zlib_decode(data, out=None):
    """Decompress Zlib DEFLATE."""
    return zlib.decompress(data)


@notimplemented(bz2)
def bz2_encode(data, level=9, out=None):
    """Compress BZ2."""
    return bz2.compress(data, level)


@notimplemented(bz2)
def bz2_decode(data, out=None):
    """Decompress BZ2."""
    return bz2.decompress(data)


@notimplemented(blosc)
def blosc_encode(data, level=None, compressor='blosclz', numthreads=1,
                 typesize=8, blocksize=0, shuffle=None, out=None):
    """Compress Blosc."""
    if shuffle is None:
        shuffle = blosc.SHUFFLE
    if level is None:
        level = 9
    return blosc.compress(data, typesize=typesize, clevel=level,
                          shuffle=shuffle, cname=compressor)


@notimplemented(blosc)
def blosc_decode(data, out=None):
    """Decompress Blosc."""
    return blosc.decompress(data)


@notimplemented(lzma)
def lzma_encode(data, level=5, out=None):
    """Compress LZMA."""
    return lzma.compress(data, level)


@notimplemented(lzma)
def lzma_decode(data, out=None):
    """Decompress LZMA."""
    return lzma.decompress(data)


@notimplemented(zstd)
def zstd_encode(data, level=5, out=None):
    """Compress ZStandard."""
    return zstd.compress(data, level)


@notimplemented(zstd)
def zstd_decode(data, out=None):
    """Decompress ZStandard."""
    return zstd.decompress(data)


@notimplemented(lzf)
def lzf_encode(data, level=None, header=False, out=None):
    """Compress LZF."""
    return lzf.compress(data)


@notimplemented(lzf)
def lzf_decode(data, header=False, out=None):
    """Decompress LZF."""
    return lzf.decompress(data)


@notimplemented(lz4)
def lz4_encode(data, level=1, header=False, out=None):
    """Compress LZ4."""
    return lz4.block.compress(data, store_size=header)


@notimplemented(lz4)
def lz4_decode(data, header=False, out=None):
    """Decompress LZ4."""
    if header:
        return lz4.block.decompress(data)
    if isinstance(out, int):
        return lz4.block.decompress(data, uncompressed_size=out)
    outsize = max(24, 24 + 255 * (len(data) - 10))  # ugh
    return lz4.block.decompress(data, uncompressed_size=outsize)


@notimplemented(PIL)
def pil_decode(data, out=None):
    """Decode image data using PIL."""
    return numpy.asarray(PIL.Image.open(io.BytesIO(data)))


@notimplemented(PIL)
def jpeg_decode(data, bitspersample=None, tables=None, colorspace=None,
                outcolorspace=None, out=None):
    """Decode JPEG."""
    if tables or colorspace or outcolorspace:
        raise NotImplementedError(
            'JPEG tables, colorspace, and outcolorspace otions not supported')
    return pil_decode(data)


@notimplemented
def jpeg_encode(*args, **kwargs):
    """Encode JPEG."""
    pass


@notimplemented(PIL)
def jpeg8_decode(data, tables=None, colorspace=None, outcolorspace=None,
                 out=None):
    """Decode JPEG 8-bit."""
    if tables or colorspace or outcolorspace:
        raise NotImplementedError(
            'JPEG tables, colorspace, and outcolorspace otions not supported')
    return pil_decode(data)


@notimplemented
def jpeg8_encode(*args, **kwargs):
    """Encode JPEG 8-bit."""
    pass


@notimplemented
def jpeg12_decode(*args, **kwargs):
    """Decode JPEG 12-bit."""
    pass


@notimplemented
def jpeg12_encode(*args, **kwargs):
    """Encode JPEG 12-bit."""
    pass


@notimplemented
def jpeg0xc3_decode(*args, **kwargs):
    """Decode JPEG SOF=0xC3."""
    pass


@notimplemented
def jpeg0xc3_encode(*args, **kwargs):
    """Encode JPEG SOF=0xC3."""
    pass


@notimplemented(PIL)
def j2k_decode(data, verbose=0, out=None):
    """Decode JPEG 2000."""
    return pil_decode(data)


@notimplemented
def j2k_encode(*args, **kwargs):
    """Encode JPEG 2000."""
    pass


@notimplemented
def jxr_decode(*args, **kwargs):
    """Decode JPEG XR."""
    pass


@notimplemented
def jxr_encode(*args, **kwargs):
    """Encode JPEG XR."""
    pass


@notimplemented(PIL)
def webp_decode(data, out=None):
    """Decode WebP."""
    return pil_decode(data)


@notimplemented
def webp_encode(*args, **kwargs):
    """Encode WebP."""
    pass


@notimplemented(PIL)
def png_decode(data, out=None):
    """Decode PNG."""
    return pil_decode(data)


@notimplemented
def png_encode(*args, **kwargs):
    """Encode PNG."""
    pass


if __name__ == '__main__':
    import doctest
    print(version())
    numpy.set_printoptions(suppress=True, precision=2)
    doctest.testmod()
