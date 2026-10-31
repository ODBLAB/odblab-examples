#-----------------------------------------------------------------------------------------------------------------------
# TO RUN THIS EXAMPLE, YOU MUST FIRST RUN ONE OF THE FOLLOWING EXAMPLES:
#   example_01_fip_ansys (*.m or *.py version)
#   example_01_fip_abaqus (*.m or *.py version)
# THE EXAMPLES ABOVE WILL GENERATE THE ODBZ (ABAQUS) OR RSTZ (ANSYS) DATABASE TO USE IN THIS EXAMPLE!
#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2026, Carlos Souto and Diego Salamanca
# Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
# License: https://spdx.org/licenses/GPL-3.0-only.html
#-----------------------------------------------------------------------------------------------------------------------
import odblab
import numpy as np
from scipy.optimize import newton

# load previous database
db = odblab.load("example_01.odbz")

# get previously computed FIP
swt = db.get("FIP.Smith-Watson-Topper", "nodes")
mask = ~np.isnan(swt)

# define material constants and residual function
E = 210e3
sigma_f = 1057
epsilon_f = 0.3439
b = -0.1120
c = -0.5512
residual = lambda N_f: sigma_f**2/E*(2*N_f)**(2*b) + sigma_f*epsilon_f*(2*N_f)**(b + c) - swt[mask]

# compute fatigue life
N_f = np.full_like(swt, np.nan)
N_f[mask] = newton(residual, x0=np.full_like(swt[mask], 1e3))
N_f[N_f > 5e6] = 5e6 # run-out limit

# add results to the database and visualize them
db.add({"Fatigue Life (SWT)": N_f}, "nodes")
odblab.view(db)
