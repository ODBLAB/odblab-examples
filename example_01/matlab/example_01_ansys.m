%-----------------------------------------------------------------------------------------------------------------------
% TO RUN THIS EXAMPLE, THE FOLLOWING FILES ARE REQUIRED:
%
% Ansys 'example_01.rst' database (finite element results); download it from the following link:
% https://drive.google.com/file/d/1Eyi1Y6zfJrpVavCMETlBiWisFHXNBnpp
%
% If *.rst to *.rstz conversion fails (e.g., because Ansys is not installed), you may download the *.rstz database
% directly from the following link:
% https://drive.google.com/file/d/1RvDhEJaPb4Bi_fuJiAj522lSRBNxuELm
%
% ODBLAB Matlab wrapper ('odblab.m'); download it from the following link:
% https://github.com/ODBLAB/odblab/blob/main/odblab-matlab/odblab.m
%-----------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2026, Carlos Souto and Diego Salamanca
% Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
% License: https://spdx.org/licenses/GPL-3.0-only.html
%-----------------------------------------------------------------------------------------------------------------------

% optional: reset matlab workspace
clear, clc, close all

% optional: select virtual python environment (may require restarting matlab)
%pyenv("Version", ".venv\Scripts\pythonw.exe")

% load database into memory
db = odblab.load("example_01.rst");

% select region and output time frames of interest
region = "CRITICAL_PLATE_NODES";
frames = (db.times >= 3.0) & (db.times <= 4.0);

% get all stress and strain components
elasticStrain = db.get(["EPEL.EPEL11", "EPEL.EPEL22", "EPEL.EPEL33", ...
    "EPEL.EPEL12", "EPEL.EPEL13", "EPEL.EPEL23"], "nodes", "Region", region, "Frames", frames);
plasticStrain = db.get(["EPPL.EPPL11", "EPPL.EPPL22", "EPPL.EPPL33", ...
    "EPPL.EPPL12", "EPPL.EPPL13", "EPPL.EPPL23"], "nodes", "Region", region, "Frames", frames);
totalStrain = cellfun(@(a, b) a + b, elasticStrain, plasticStrain, "UniformOutput", false);
stress = db.get(["S.S11", "S.S22", "S.S33", "S.S12", "S.S13", "S.S23"], "nodes", "Region", region, "Frames", frames);
stress = cellfun(@(x) x*1e-6, stress, "UniformOutput", false); % Pa to MPa

% compute FIP (Fatigue Indicator Parameter)
fipA = solveCriticalPlane(stress, totalStrain, 5, @fipSmithWatsonTopper);
fipB = solveCriticalPlane(stress, totalStrain, 5, @fipFatemiSocie, {"k_FS", 0.5, "sigma_y", 400});
fipC = solveCriticalPlane(stress, totalStrain, 5, @fipMcDiarmid, {"deltaSigma0", 500, "sigma_u", 690});

% add results to the database
db.add({"FIP.Smith-Watson-Topper", fipA, "FIP.Fatemi-Socie", fipB, "FIP.McDiarmid", fipC}, "nodes", ...
    "region", region, "Frames", db.times == 4.0)

% visualize results in the viewer app
odblab.view(db)
