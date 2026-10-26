#-----------------------------------------------------------------------------------------------------------------------
# TO RUN THIS EXAMPLE, THE FOLLOWING FILES ARE REQUIRED:
#
# Abaqus 'example_02.odb' database (finite element results); download it from the following link:
# TO BE INCLUDED BY CARLOS!
#
# If *.odb to *.odbz conversion fails (e.g., because Abaqus is not installed), you may download the *.odbz database
# directly from the following link:
# TO BE INCLUDED BY CARLOS!
#
# ODBLAB Matlab wrapper ('odblab.m'); download it from the following link:
# https://github.com/ODBLAB/odblab/blob/main/odblab-matlab/odblab.m
#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2026, Carlos Souto and Diego Salamanca
# Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
# License: https://spdx.org/licenses/GPL-3.0-only.html
#-----------------------------------------------------------------------------------------------------------------------
# import libraies
import odblab
import numpy as np

# load database into memory
db = odblab.load("example_02.odb");

# experimental frequency results
expFreq = np.array([11.3, 76.4, 216.8, 417.6, 647.6,])

# get the numerical frequency results
numFreq = db.times[[1, 3, 5, 7, 9]]

# compute the selected criterion (natural frequencies relative percentage error)
freqError = (abs(expFreq - numFreq)/expFreq)*100

# visualize results in the viewer app
odblab.view(db)