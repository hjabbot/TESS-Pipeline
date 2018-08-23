import sys
import numpy as np
import K2fov.fov as fov
# C8
#ra_deg = 16.3379975
#dec_deg = 5.2623459
#scRoll_deg = -157.3538761
# C10
ra_deg = 186.7794430
dec_deg = -4.0271572
scRoll_deg = 157.6280500

fovRoll_deg = fov.getFovAngleFromSpacecraftRoll(scRoll_deg)
k = fov.KeplerFov(ra_deg, dec_deg, fovRoll_deg)
raDec = k.getCoordsOfChannelCorners()
np.savetxt('ccdCenters.txt',raDec,fmt='%5i %5i %5i %10.6f %10.6f')
