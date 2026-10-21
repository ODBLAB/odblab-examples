%-----------------------------------------------------------------------------------------------------------------------
% Smith-Watson-Topper (SWT) fatigue indicator parameter (FIP).
%-----------------------------------------------------------------------------------------------------------------------
% Input:
%   `stress` (1-by-3 cell array): Projected stress histories on the candidate planes, containing normal stress, shear
%       stress along the first in-plane direction, and shear stress along the second in-plane direction, respectively.
%       Each `stress{i}` is a real matrix with rows corresponding to output time frames and columns corresponding to
%       candidate planes.
%   `strain` (1-by-3 cell array): Analogous to `stress`. Shear strains are expressed as tensor shear strains.
%   `~`: Unused argument, included for consistency with the FIP function interface.
%-----------------------------------------------------------------------------------------------------------------------
% Output:
%   `fip` (vector): Smith-Watson-Topper FIP for each candidate plane.
%-----------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2026, Carlos Souto and Diego Salamanca
% Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
% License: https://spdx.org/licenses/GPL-3.0-only.html
%-----------------------------------------------------------------------------------------------------------------------
function fip = fipSmithWatsonTopper(stress, strain, ~)
    s11 = stress{1};
    e11 = strain{1};
    fip = max(s11).*(max(e11) - min(e11))/2;
    fip(fip < 0) = 0;
end
