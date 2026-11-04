%-----------------------------------------------------------------------------------------------------------------------
% TO RUN THIS EXAMPLE, THE FOLLOWING FILES ARE REQUIRED:
%
% Abaqus 'example_02.odb' database (finite element results); download it from the following link:
% https://drive.google.com/file/d/15dvI8rpDyTU15hoO3aUVJGplbIkwFdCx
%
% If *.odb to *.odbz conversion fails (e.g., because Abaqus is not installed), you may download the *.odbz database
% directly from the following link:
% https://drive.google.com/file/d/1phN6M4rcYvo92cFf0mvFrlh-UwvYqFLz
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
db = odblab.load("example_02.odb");

% extract the numerical forms of the modes
[z, v] = db.get(["COORD.COOR3", "U.U2"], "nodes", "Region", "BEAM-1.LATERAL_NODES");
[z, i] = sort(z(:, 2)); v = v(i, 2:2:10); % extract first five bending modes

% plot the numerical modes of the beam
figure, plot(z/max(z), v);
xlabel("Normalized position")
ylabel("Normalized modal amplitude")
legend("Mode " + (1:size(v, 2)));

% import the experimental data
example_02_exp_data

% read the modal shapes at the accelerometer nodes
[zAccNum, vAccNum] = db.get(["COORD.COOR3", "U.U2"], "nodes", "Region", "BEAM-1.ACELEROMETERS");
[zAccNum, j] = sort(zAccNum(:, 2)); vAccNum = vAccNum(j, 2:2:10); % first five flexion modes

% compute MAC (Modal Assurance Criterion)
modes1 = flip(vAccNum); modes2 = vAccExp;
mac = abs(modes1'*modes2).^2./(sum(modes1.^2)'*sum(modes2.^2));

% plot MAC
figure, b = bar3(mac); colormap("turbo"), colorbar
arrayfun(@(x) set(x, "CData", x.ZData, "FaceColor", "interp"), b); clim([0, 1])
xlabel("Exp. modes"), ylabel("Num. modes"), ylabel(colorbar, "MAC")
