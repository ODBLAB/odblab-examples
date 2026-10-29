%-----------------------------------------------------------------------------------------------------------------------
% TO RUN THIS EXAMPLE, THE FOLLOWING FILES ARE REQUIRED:
%
% Abaqus 'example_01.odb' database (finite element results); download it from the following link:
% https://drive.google.com/file/d/1PUsL5iLUFwk56MT9T-shUXFgbMhzTiRx
%
% If *.odb to *.odbz conversion fails (e.g., because Abaqus is not installed), you may download the *.odbz database
% directly from the following link:
% https://drive.google.com/file/d/1pQnk25UFEXCMAckiytI_rophHxSpi6Sr
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
db = odblab.load("example_01.odb");

% select region and output time frames of interest
region = "PLATE.CRITICAL_PLATE_SURFACE";
frames = (db.times >= 3.0) & (db.times <= 4.0);

% get all stress and strain components
stress = db.get(["S.S11", "S.S22", "S.S33", "S.S12", "S.S13", "S.S23"], "nodes", ...
    "Region", region, "Frames", frames);
strain = db.get(["LE.LE11", "LE.LE22", "LE.LE33", "LE.LE12", "LE.LE13", "LE.LE23"], "nodes", ...
    "Region", region, "Frames", frames);

% compute FIP (Fatigue Indicator Parameter)
fipA = solveCriticalPlane(stress, strain, 5, @fipSmithWatsonTopper);
fipB = solveCriticalPlane(stress, strain, 5, @fipFatemiSocie, {"k_FS", 0.5, "sigma_y", 400});
fipC = solveCriticalPlane(stress, strain, 5, @fipMcDiarmid, {"deltaSigma0", 500, "sigma_u", 690});

% add results to the database
db.add({"FIP.Smith-Watson-Topper", fipA, "FIP.Fatemi-Socie", fipB, "FIP.McDiarmid", fipC}, "nodes", ...
    "region", region, "Frames", db.times == 4.0)
db.save()

% visualize results in the viewer app
odblab.view(db)
