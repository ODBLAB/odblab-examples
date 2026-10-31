%-----------------------------------------------------------------------------------------------------------------------
% TO RUN THIS EXAMPLE, YOU MUST FIRST RUN ONE OF THE FOLLOWING EXAMPLES:
%   example_01_fip_ansys (*.m or *.py version)
%   example_01_fip_abaqus (*.m or *.py version)
% THE EXAMPLES ABOVE WILL GENERATE THE ODBZ (ABAQUS) OR RSTZ (ANSYS) DATABASE TO USE IN THIS EXAMPLE!
%-----------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2026, Carlos Souto and Diego Salamanca
% Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
% License: https://spdx.org/licenses/GPL-3.0-only.html
%-----------------------------------------------------------------------------------------------------------------------
% optional: reset matlab workspace
clear, clc, close all

% optional: select virtual python environment (may require restarting matlab)
pyenv("Version", ".venv\Scripts\pythonw.exe")

% load previous database
db = odblab.load("example_01.odbz");

% get previously computed FIP
swt = db.get("FIP.Smith-Watson-Topper", "nodes");
mask = ~isnan(swt);

% define material constants and residual function
E = 210e3;
sigma_f = 1057;
epsilon_f = 0.3439;
b = -0.1120;
c = -0.5512;
residuals = @(n, s) (((sigma_f^2/E)*(2*n)^(2*b) + sigma_f*epsilon_f*(2*n)^(b + c) - s)^2);

% compute fatigue life
N_f = nan(size(mask));
N_f(mask) = (arrayfun(@(s) fminbnd(@(n) residuals(n, s), 1e2, 1e8), swt(mask)));
N_f(N_f > 5e6) = 5e6; % run-out criterion

% add results to the database and visualize them
db.add({"Smith-Watson-Topper life", N_f}, "nodes")
odblab.view(db)
