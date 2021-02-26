#!/usr/bin/python

# Updated from https://github.com/ArchiveTeam/warrior-preseed/blob/master/splash/png2fb

import sys

try:
  infile = sys.argv[1]
  outfile = sys.argv[2]
except:
  print("Usage: %s <input> <output>" % ( sys.argv[0], ))
  print()
  print("    <input>: any existing image file, e.g. a PNG,")
  print("             preferably 640x480")
  print()
  print("   <output>: output filename - raw data to dump to")
  print("             /dev/fb/0, assuming you got the image")
  print("             dimensions right")
  print()
  sys.exit(1)

from PIL import Image
im = Image.open( infile )
im2 = im.convert( "RGB" )
data = im2.getdata()

fp = open( outfile, "wb" )
for (r,g,b) in data:
  assert r >= 0 and r <= 255
  assert g >= 0 and g <= 255
  assert b >= 0 and b <= 255
##r /= 8
##g /= 8
##b /= 8
##assert r >= 0 and r <= 31
##assert g >= 0 and g <= 31
##assert b >= 0 and b <= 31
##value = r*(32*32)+g*32+b
##assert value >= 0 and value <= 65535
  #fp.write(chr(b).encode( "ascii", errors="replace" )+chr(g).encode( "ascii", errors="replace" )+chr(r).encode( "ascii", errors="replace" )+chr(0).encode( "ascii", errors="replace" )) # https://stackoverflow.com/a/48958245
  fp.write(bytes([b])+bytes([g])+bytes([r])+bytes([0])) # https://stackoverflow.com/a/55164073