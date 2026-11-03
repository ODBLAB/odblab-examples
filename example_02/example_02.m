%-----------------------------------------------------------------------------------------------------------------------
% TO RUN THIS EXAMPLE, THE FOLLOWING FILES ARE REQUIRED:
%
% Abaqus 'example_02.odb' database (finite element results); download it from the following link:
% TO BE INCLUDED BY CARLOS!
%
% If *.odb to *.odbz conversion fails (e.g., because Abaqus is not installed), you may download the *.odbz database
% directly from the following link:
% TO BE INCLUDED BY CARLOS!
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
pyenv("Version", ".venv\Scripts\pythonw.exe")

% load database into memory
db = odblab.load("example_02.odb");

% extract the numerical forms of the modes
[allNodesCoords, allNodesModes] = db.get(["COORD.COOR3" "U.U2"], "nodes", "Region", "BEAM-1.LATERAL_NODES");
[allNodesCoords, idx] = sort(allNodesCoords(:, 2)); 
allNodesModes = allNodesModes(idx, 2:2:10); % first five bending modes!

% plot the numerical modes of the beam
figure; 
plot(allNodesCoords, allNodesModes, "LineWidth", 1.5);
xlabel("Position (m)"), ylabel("Normalized modal amplitude"); legend("Mode " + (1:size(allNodesModes, 2)));

% import the experimental data
load("exp_data_example_02.mat");

% read the modal shapes at the accelerometer nodes
[accNumCoords, accNumModes] = db.get(["COORD.COOR3" "U.U2"], "nodes", "Region", "BEAM-1.ACELEROMETERS"); 
[accNumCoords, idxAcc] = sort(accNumCoords(:, 2)); 
accNumModes = accNumModes(idxAcc, 2:2:10); % first five flexion modes!

% compute MAC (Modal Assurance Criterion)
modes1 = flip(accNumModes); modes2 = accExpModes; 
mac = abs(modes1'*modes2).^2./(sum(modes1.^2)'*sum(modes2.^2));

% plot MAC
figure; b = bar3(mac); colormap("turbo"); colorbar; 
arrayfun(@(x) set(x, 'CData', x.ZData, 'FaceColor', 'interp'), b); clim([0 1]);
xlabel('Exp. modes'); ylabel('Num. modes'); ylabel(colorbar, 'MAC');
