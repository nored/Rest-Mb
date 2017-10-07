#!/usr/bin/python2

# Further modified version of mandelbrot fractal from:
# http://code.activestate.com/recipes/577111-mandelbrot-fractal-using-pil/
#
# Copyright (C) 2017 Klaus Schwarz <schwarz[aet]posteo[dot]de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# FB - 201003151
# Modified Andrew Lewis 2010/04/06

from PIL import Image
import sys

imgx = int(sys.argv[1])
imgy = int(sys.argv[2])
maxIt = int(sys.argv[3])
name = sys.argv[4]

# drawing area (xa < xb and ya < yb)
xa = -2.0
xb = 1.0
ya = -1.5
yb = 1.5
#maxIt = 256 # iterations
# image size
#imgx = 512
#imgy = 512

#create mtx for optimized access
image = Image.new("RGB", (imgx, imgy))
mtx = image.load()

#optimizations
lutx = [j * (xb-xa) / (imgx - 1) + xa for j in xrange(imgx)]

for y in xrange(imgy):
    cy = y * (yb - ya) / (imgy - 1)  + ya
    for x in xrange(imgx):
        c = complex(lutx[x], cy)
        z = 0
        for i in xrange(maxIt):
            if abs(z) > 2.0: break 
            z = z * z + c 
        r = i % 4 * 64
        g = i % 8 * 32
        b = i % 16 * 16
        mtx[x, y] =  r,g,b

image.save("mandel-" + name + ".png", "PNG")
