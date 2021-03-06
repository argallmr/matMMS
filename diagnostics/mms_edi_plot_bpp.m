%
% Name
%   mms_edi_plot_bpp
%
% Purpose
%   Plot all EDI beams in the given time interval in BPP using the average
%   magnetic field for that interval. All beams are projected into the same
%   BPP.
%
% See Also
%   mms_edi_view
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-14      Written by Matthew Argall
%

get_data = true;
quality  = 3;

% Inputs
if get_data
	edi_data_dir = '/Users/argall/Documents/Work/Data/MMS/EDI/';
	dfg_data_dir = '/Users/argall/Documents/Work/Data/MMS/DFG/';
	fg_cal_dir   = '/Users/argall/Documents/Work/Data/MMS/FG_Cal/';
	att_dir      = '/Users/argall/Documents/Work/Data/MMS/Attitude/';
	sunpulse_dir = '/Users/argall/Documents/Work/Data/MMS/HK/';
	sc           = 'mms4';
	instr        = 'edi';
	mode         = 'slow';
	level        = 'l1a_efield';
	tstart       = '2015-04-22T17:03:15';
	tend         = '2015-04-22T17:03:30';
	
	%------------------------------------%
	% Get DFG and EDI Data in DSL        %
	%------------------------------------%
	% Read DFG data in DSL
	[t, ~, b_dmpa] = mms_fg_gse(sc, 'dfg', 'f128', tstart, tend, ...
	                           'CalDir',      fg_cal_dir, ...
	                           'SunPulseDir', sunpulse_dir, ...
	                           'DataDir',     dfg_data_dir);
	
	% Read EDI data in DSL
	[gd12_dmpa, gd21_dmpa] = mms_edi_gse(sc, 'edi', 'slow', 'l1a_efield', tstart, tend, ...
	                                    'SunPulseDir', sunpulse_dir, ...
	                                    'DataDir',     edi_data_dir, ...
	                                    'Quality',     quality);
end

%------------------------------------%
% View in Bavg Plane                 %
%------------------------------------%
% Average magnetic field
b_avg = mean(b_dmpa, 2);
b_std = std(b_dmpa, 0, 2);

% Create a single transformation matrix for all beams
xyz2bpp_bavg = mms_edi_xxyz2bpp(b_avg);

% Rotate firing vectors and gun positions into bpp
fv_gd12_bpp  = mrvector_rotate(xyz2bpp_bavg, gd12_dmpa.fv_gd12_dmpa);
pos_gun1_bpp = mrvector_rotate(xyz2bpp_bavg, gd12_dmpa.gun1_dmpa);

fv_gd21_bpp  = mrvector_rotate(xyz2bpp_bavg, gd21_dmpa.fv_gd21_dmpa);
pos_gun2_bpp = mrvector_rotate(xyz2bpp_bavg, gd21_dmpa.gun2_dmpa);

%------------------------------------%
% Spacecraft Coordinates             %
%------------------------------------%

% Create the spacecraft
sc_radius   = mms_instr_origins_instr('EDI1_GUN', 'EDI2_DETECTOR');
sc_radius   = sqrt( sum( sc_radius.^2 ) );
sc_npts     = 100;
sc_sph      = zeros(3, sc_npts);
sc_sph(3,:) = sc_radius;
sc_sph(1,:) = 2 * pi * (1:1:sc_npts) / sc_npts;
[sc_x, sc_y, sc_z]  = sph2cart(sc_sph(1,:), sc_sph(2,:), sc_sph(3,:));
sc_xyz = [sc_x; sc_y; sc_z];

% Rotate the spacecraft into BPP
sc_bpp = mrvector_rotate( xyz2bpp_bavg, sc_xyz );

% Clear temporary variables
clear sc_radius sc_nps sc_sph sc_x sc_y sc_z

%------------------------------------%
% Firing Vectors                     %
%------------------------------------%

range = [-22.5, 22.5];

% Remove NaNs

iGood        = find( ~isnan(fv_gd12_bpp(1,:)) );
nGood_gd12   = length(iGood);
fv_gd12_bpp  = fv_gd12_bpp(:,iGood);
pos_gun1_bpp = pos_gun1_bpp(:,iGood);

iGood        = find( ~isnan(fv_gd21_bpp(1,:)) );
nGood_gd21   = length(iGood);
fv_gd21_bpp  = fv_gd21_bpp(:,iGood);
pos_gun2_bpp = pos_gun2_bpp(:,iGood);

% Skip this round
if nGood_gd12 == 0 && nGood_gd21 == 0
	error('No beams found. Cannot plot.');
end

%
% Beam slope, y-intercept, (x1,x2) and (y1,y2)
%    - slope (m)       = rise / run
%    - y-intercept (b) = y1 - m * x1
%    - (x1,x2)         = range
%    - (y1,y2)         = m*x + b
%

% GD12
m_gd12 = fv_gd12_bpp(2,:) ./ fv_gd12_bpp(1,:);
b_gd12 = pos_gun1_bpp(2,:) - pos_gun1_bpp(1,:) .* m_gd12;
x_gd12 = repmat( range', 1, nGood_gd12);
y_gd12 = [m_gd12 .* x_gd12(1,:) + b_gd12; ...
          m_gd12 .* x_gd12(2,:) + b_gd12];

% GD21
m_gd21 = fv_gd21_bpp(2,:) ./ fv_gd21_bpp(1,:);
b_gd21 = pos_gun2_bpp(2,:) - pos_gun2_bpp(1,:) .* m_gd21;
x_gd21 = repmat( range', 1, nGood_gd21);
y_gd21 = [m_gd21 .* x_gd21(1,:) + b_gd21; ...
          m_gd21 .* x_gd21(2,:) + b_gd21];

% Clear
clear b_gd21 m_gd21 b_gd12 m_gd12

%------------------------------------%
% Plot Spacecraft Outline            %
%------------------------------------%

% Title information
ttl_tstart = MrCDF_Epoch_Encode(t(1));
ttl_tend   = MrCDF_Epoch_Encode(t(end));
ttl_date   = ttl_tstart{1}(1:10);
ttl_tstart = ttl_tstart{1}(12:19);
ttl_tend   = ttl_tend{1}(12:19);
ttl = sprintf( ['EDI eField Mode\n' ...
                'Time Interval: %s  %s - %s\n' ...
                'nBeams: GD12 = %d, GD21 = %d\n' ...
                'Bavg = [%0.2f, %0.2f, %0.2f] +/- [%0.2f, %0.2f, %0.2f]'], ...
              ttl_date, ttl_tstart, ttl_tend, nGood_gd12, nGood_gd21, ...
              b_avg, b_std );

% Append quality to title
if ~isempty(quality)
	ttl = sprintf('%s\nQuality = %d', ttl, quality);
end

% S/C Outline
plot( sc_bpp(1,:), sc_bpp(2,:) );
hold on
grid on;
title(ttl);
xlabel('x (m)');
ylabel('y (m)');

%---------------------------------------%
% Plot Gun Positions & Firing Vectors   %
%---------------------------------------%
% Create a scatter plot of gun positions
s_gd12 = scatter(pos_gun1_bpp(1,:), pos_gun1_bpp(2,:), [], 'blue');
s_gd21 = scatter(pos_gun2_bpp(1,:), pos_gun2_bpp(2,:), [], 'red');

% Create lines
l_gd12 = [];
l_gd21 = [];
for ii = 1 : nGood_gd12
	l_gd12 = line(x_gd12(:,ii), y_gd12(:,ii), 'Color', 'blue');
end
for ii = 1 : nGood_gd21
	l_gd21 = line(x_gd21(:,ii), y_gd21(:,ii), 'Color', 'red');
end
legend([l_gd12, l_gd21], 'GD12', 'GD21');

xlim(range)
ylim(range)
hold off
