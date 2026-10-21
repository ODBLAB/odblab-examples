%-----------------------------------------------------------------------------------------------------------------------
% Critical plane FIP (Fatigue Indicator Parameter) computation kernel -- Evaluates a user-defined FIP over a discretized
% set of candidate planes and returns the maximum FIP at each spatial position.
%-----------------------------------------------------------------------------------------------------------------------
% Input:
%   `stress` (1-by-6 cell array): The stress tensor components in the following order: 1-S11, 2-S22, 3-S33, 4-S12,
%       5-S13, 6-S23. Each `stress{i}` is a real matrix with rows corresponding to spatial positions (nodes or
%       centroids) and columns corresponding to output time frames.
%   `strain` (1-by-6 cell array): The strain tensor components following the same ordering and matrix dimensions as
%       `stress`. Shear components must be provided as engineering shear strains.
%   `inc` (scalar): Angular increment, in degrees, used to discretize candidate plane orientations. Must divide 180
%       evenly so that angular ranges include their endpoints.
%   `fip` (function handle): User-defined FIP function, which receives the projected stress and strain histories and
%       returns one FIP value per candidate plane.
%   `params` (1-by-2*N cell array): Cell array containing N extra parameters (e.g., material properties), specified as
%       name-value pairs, which may by required by the user-defined FIP function.
%-----------------------------------------------------------------------------------------------------------------------
% Output:
%   `results` (vector): Maximum FIP across all candidate planes at each spatial position.
%-----------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2026, Carlos Souto and Diego Salamanca
% Contact: csouto@fe.up.pt; diazsdiego@uniovi.es
% License: https://spdx.org/licenses/GPL-3.0-only.html
%-----------------------------------------------------------------------------------------------------------------------
function results = solveCriticalPlane(stress, strain, inc, fip, params)
    if nargin < 5, params = {}; end
    params = struct(params{:});

    % transform engineering shear strain to tensor shear strain
    strain(4:6) = cellfun(@(x) x/2, strain(4:6), "UniformOutput", false);

    % generate set of candidate planes
    [phi, theta] = meshgrid(0:inc:180, 0:inc:180);
    planeCount = numel(phi);

    % direction cosines of the plane normals and in-plane basis vectors
    nX = reshape(sind(theta).*cosd(phi), 1, planeCount);
    nY = reshape(sind(theta).*sind(phi), 1, planeCount);
    nZ = reshape(cosd(theta), 1, planeCount);
    s1X = reshape(cosd(theta).*cosd(phi), 1, planeCount);
    s1Y = reshape(cosd(theta).*sind(phi), 1, planeCount);
    s1Z = reshape(-sind(theta), 1, planeCount);
    s2X = reshape(-sind(phi), 1, planeCount);
    s2Y = reshape(cosd(phi), 1, planeCount);
    s2Z = zeros(1, planeCount);
    nXX = nX.*nX; nYY = nY.*nY; nZZ = nZ.*nZ;
    nXY = nX.*nY; nXZ = nX.*nZ; nYZ = nY.*nZ;

    % anonymous function definitions for tensor projection onto the critical planes
    proj11 = @(t, i) t{1}(i, :)'.*nXX + t{2}(i, :)'.*nYY + t{3}(i, :)'.*nZZ + ...
        2*t{4}(i, :)'.*nXY + 2*t{5}(i, :)'.*nXZ + 2*t{6}(i, :)'.*nYZ;
    proj12 = @(t, i) t{1}(i, :)'.*(nX.*s1X) + t{2}(i, :)'.*(nY.*s1Y) + t{3}(i, :)'.*(nZ.*s1Z) + ...
        t{4}(i, :)'.*(nX.*s1Y + nY.*s1X) + t{5}(i, :)'.*(nX.*s1Z + nZ.*s1X) + t{6}(i, :)'.*(nY.*s1Z + nZ.*s1Y);
    proj13 = @(t, i) t{1}(i, :)'.*(nX.*s2X) + t{2}(i, :)'.*(nY.*s2Y) + t{3}(i, :)'.*(nZ.*s2Z) + ...
        t{4}(i, :)'.*(nX.*s2Y + nY.*s2X) + t{5}(i, :)'.*(nX.*s2Z + nZ.*s2X) + t{6}(i, :)'.*(nY.*s2Z + nZ.*s2Y);

    % max FIP computation across each spatial positions
    positionCount = size(stress{1}, 1);
    results = zeros(positionCount, 1);
    for i = 1 : 1 : positionCount

        % project tensors
        s11 = proj11(stress, i);
        s12 = proj12(stress, i);
        s13 = proj13(stress, i);
        e11 = proj11(strain, i);
        e12 = proj12(strain, i);
        e13 = proj13(strain, i);

        % store max FIP across all candidate planes
        results(i) = max(fip({s11, s12, s13}, {e11, e12, e13}, params));

    end

end
