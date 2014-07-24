ctypedef unsigned char pix8
cdef struct pix32:
    unsigned char r, g, b, a

ctypedef pix8 **data8
ctypedef pix32 **data32

cdef struct ImagingMemoryInstance:
    #/* Format */
    char mode[4+1]	#/* Band names ("1", "L", "P", "RGB", "RGBA", "CMYK") */
    int type		#/* Data type (IMAGING_TYPE_*) */
    int depth		#/* Depth (ignored in this version) */
    int bands		#/* Number of bands (1, 2, 3, or 4) */
    int xsize		#/* Image dimension. */
    int ysize

    #/* Colour palette (for "P" images only) */
    char *palette_not_implemented

    #/* Data pointers */
    data8 image8	#/* Set for 8-bit images (pixelsize=1). */
    data32 image32	#/* Set for 32-bit images (pixelsize=4). */

    #/* Internals */
    char **image	#/* Actual raster data. */
    char *block	    #/* Set if data is allocated in a single block. */

    int pixelsize	#/* Size of a pixel, in bytes (1, 2 or 4) */
    int linesize	#/* Size of a line, in bytes (xsize * pixelsize) */

ctypedef ImagingMemoryInstance *Imaging
