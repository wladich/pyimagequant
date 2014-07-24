# -*- coding: utf-8 -*-
import Image
import imagequant

def save_pil_png(filename, img, size, palette):
    im = Image.frombuffer('P', size, img, 'raw', 'P', 0, 1)
    palette = list(palette)
    del palette[3::4]
    im.putpalette(palette)
    im.save(filename, format='PNG')
#    im.show()
    

def get_sample_image():
    im = Image.new('RGB', (300, 500))
    pix = im.load()
    for y in xrange(im.size[1]):
        for x in xrange(im.size[0]):
            r = x % 256
            g = y % 256
            b = (x*y) % 256
            pix[x, y] = (r, g, b)
    return im

im = get_sample_image()
quantized = imagequant.quantize_image(im, 10, 1)
print quantized['quantization_error']
print quantized['quantization_quality']
save_pil_png('export.png', quantized['image'], quantized['size'], quantized['palette'])

