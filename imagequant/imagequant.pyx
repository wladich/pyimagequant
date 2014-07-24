# -*- coding: utf-8 -*-
from Imaging cimport Imaging
from libimagequant cimport  *
from libc.string cimport memcpy
from cpython cimport array
from array import array

def quantize_image(im, colors, speed):
    cdef: 
        Imaging im_props
        array.array out_img
        array.array out_palette
        size_t palette_size
        size_t width, height, pixels_n
        double quantization_quality, quantization_error
    im.load()
    im = im.convert('RGBA')
    im_props = <Imaging><Py_ssize_t>im.im.id
    width = im_props.xsize
    height = im_props.ysize
    pixels_n = width * height
    out_img = array('B', [])
    array.resize(out_img, pixels_n)
    out_palette = array('B', [])
    array.resize(out_palette, 1024)
    _quantize_image(colors, speed, im_props.block, width, height,
                    out_img.data.as_voidptr, pixels_n, out_palette.data.as_voidptr, &palette_size,
                    &quantization_error, &quantization_quality)
    array.resize(out_palette, palette_size * 4)
    return {'image': out_img, 
            'palette': out_palette, 
            'quantization_error': quantization_error, 
            'quantization_quality': quantization_quality,
            'size': (width, height)
            }
    
cdef check_error(liq_error er, function):
    if er != LIQ_OK:
        if er == LIQ_QUALITY_TOO_LOW: 
            msg = 'LIQ_QUALITY_TOO_LOW'
        elif er == LIQ_VALUE_OUT_OF_RANGE: 
            msg = 'LIQ_VALUE_OUT_OF_RANGE'
        elif er == LIQ_OUT_OF_MEMORY: 
            msg = 'LIQ_OUT_OF_MEMORY'
        elif er == LIQ_NOT_READY: 
            msg = 'LIQ_NOT_READY'
        elif er == LIQ_BITMAP_NOT_AVAILABLE: 
            msg = 'LIQ_BITMAP_NOT_AVAILABLE'
        elif er == LIQ_BUFFER_TOO_SMALL: 
            msg = 'LIQ_BUFFER_TOO_SMALL'
        elif er == LIQ_INVALID_POINTER: 
            msg = 'LIQ_INVALID_POINTER'
        else:
            msg = bytes('Unknown error %d' % er)
        raise Exception('Error in function %s in libimagequant: %s' % (function, msg))

cdef check_not_null(void *p):
    if p is NULL:
        raise Exception('libimagequant returned null pointer')

cdef _quantize_image(int colors_n, int speed, void *bitmap, int width, int height,
                     void *out_buf, size_t out_buf_size, void *palette, size_t *palette_size,
                     double *quantization_error, double *quantization_quality):
    cdef: 
        liq_attr *attr
        liq_image *image
        liq_result *res
        liq_palette *pal
    attr = liq_attr_create()
    check_not_null(attr)
    check_error(liq_set_max_colors(attr, colors_n), 'liq_set_max_colors')
    check_error(liq_set_speed(attr, speed), 'liq_set_speed')

    image = liq_image_create_rgba(attr, bitmap, width, height, 0)
    check_not_null(image)
    res = liq_quantize_image(attr, image)
    check_not_null(res)
    check_error(liq_write_remapped_image(res, image, out_buf, out_buf_size), 'liq_write_remapped_image')
    pal = liq_get_palette(res)
    check_not_null(pal)
    memcpy(palette, &pal.entries[0], 1024)
    palette_size[0] = pal.count
    quantization_error[0] = liq_get_quantization_error(res)
    quantization_quality[0] = liq_get_quantization_quality(res)
    liq_attr_destroy(attr)
    liq_image_destroy(image)
    liq_result_destroy(res)