#!/usr/bin/env python

import sys, gtk

cb = gtk.Clipboard()
image = cb.wait_for_image()
if image == None:
    print "No image on clipboard!"
    sys.exit(1)

image.save("downloaded.png", "png")
cb.set_text("YOUR URL HERE")
cb.store()
gtk.main()
