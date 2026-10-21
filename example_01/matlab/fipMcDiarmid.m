%-----------------------------------------------------------------------------------------------------------------------
% McDiarmid (McD) fatigue indicator parameter (FIP).
%-----------------------------------------------------------------------------------------------------------------------
% Input:
%   `stress` (1-by-3 cell array): Projected stress histories on the candidate planes, containing normal stress, shear
%       stress along the first in-plane direction, and shear stress along the second in-plane direction, respectively.
%       Each `stress{i}` is a real matrix with rows corresponding to output time frames and columns corresponding to
%       candidate planes.
%   `~`: Unused argument, included for consistency with the FIP function interface.
%   `p` (struct): Material parameters containing:
%       `deltaSigma0` (scalar): Fatigue limit, in the same stress units as `stress`.
%       `sigma_u` (scalar): Ultimate tensile strength, in the same stress units as `stress`.
%-----------------------------------------------------------------------------------------------------------------------
% Output:
%   `fip` (vector): McDiarmid FIP for each candidate plane.
%-----------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2026, Carlos Souto and Diego Salamanca
% Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
% License: https://spdx.org/licenses/GPL-3.0-only.html
%-----------------------------------------------------------------------------------------------------------------------
function fip = fipMcDiarmid(stress, ~, p)

    % retrieve dimensions
    [frameCount, planeCount] = size(stress{1});

    % compute the euclidean distance for the shear stress components
    tau12 = stress{2};
    tau13 = stress{3};
    deltaTau12 = reshape(tau12, frameCount, 1, planeCount) - reshape(tau12, 1, frameCount, planeCount);
    deltaTau13 = reshape(tau13, frameCount, 1, planeCount) - reshape(tau13, 1, frameCount, planeCount);
    deltaTau = sqrt(deltaTau12.^2 + deltaTau13.^2);

    % extract the maximum shear stress range for each candidate plane
    deltaTauMax = reshape(max(deltaTau, [], [1, 2]), 1, planeCount);

    % compute McDiarmid FIP
    sigma11 = stress{1};
    fip = deltaTauMax/2 + (p.deltaSigma0/(2*sqrt(2)*p.sigma_u))*max(sigma11);
    fip(fip < 0) = 0;

end
