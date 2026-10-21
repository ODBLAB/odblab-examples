%-----------------------------------------------------------------------------------------------------------------------
% Fatemi-Socie (FS) fatigue indicator parameter (FIP).
%-----------------------------------------------------------------------------------------------------------------------
% Input:
%   `stress` (1-by-3 cell array): Projected stress histories on the candidate planes, containing normal stress, shear
%       stress along the first in-plane direction, and shear stress along the second in-plane direction, respectively.
%       Each `stress{i}` is a real matrix with rows corresponding to output time frames and columns corresponding to
%       candidate planes.
%   `strain` (1-by-3 cell array): Analogous to `stress`. Shear strains are expressed as tensor shear strains.
%   `p` (struct): Material parameters containing:
%       `k_FS` (scalar): Fatemi-Socie normal stress sensitivity coefficient.
%       `sigma_y` (scalar): Yield strength, in the same stress units as `stress`.
%-----------------------------------------------------------------------------------------------------------------------
% Output:
%   `fip` (vector): Fatemi-Socie FIP for each candidate plane.
%-----------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2026, Carlos Souto and Diego Salamanca
% Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
% License: https://spdx.org/licenses/GPL-3.0-only.html
%-----------------------------------------------------------------------------------------------------------------------
function fip = fipFatemiSocie(stress, strain, p)

    % retrieve dimensions
    [frameCount, planeCount] = size(stress{1});

    % compute the euclidean distance for the shear strain components
    gamma12 = 2*strain{2};
    gamma13 = 2*strain{3};
    deltaGamma12 = reshape(gamma12, frameCount, 1, planeCount) - reshape(gamma12, 1, frameCount, planeCount);
    deltaGamma13 = reshape(gamma13, frameCount, 1, planeCount) - reshape(gamma13, 1, frameCount, planeCount);
    deltaGamma = sqrt(deltaGamma12.^2 + deltaGamma13.^2);

    % extract the maximum engineering shear strain range for each candidate plane
    deltaGammaMax = reshape(max(deltaGamma, [], [1, 2]), 1, planeCount);

    % compute Fatemi-Socie FIP
    sigma11 = stress{1};
    fip = (deltaGammaMax/2).*(1 + p.k_FS*max(sigma11)/p.sigma_y);
    fip(fip < 0) = 0;

end
