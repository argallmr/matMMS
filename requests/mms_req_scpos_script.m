%
% Name
%   mms_req_scpos
%
% Purpose
%   Request for Project SMART students.
%
%   Script to run mms_req_scpos on multiple dates and spacecraft.
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-05-16      Written by Matthew Argall
%-----------------------------------------------------------------------------------------

sc     = 'mms1';

dates = {'2015-04-11', ...
         '2015-06-07', ...
         '2015-06-22', ...
         '2015-06-23', ...
         '2015-06-25', ...
         '2015-06-26', ...
         '2015-06-27', ...
         '2015-07-04', ...
         '2015-07-05', ...
         '2015-07-06'};

tstart_mms1 = {'T08:15:06', ...
               'T21:24:51', ...
               'T18:33:56', ...
               'T03:24:14', ...
               'T07:13:33', ...
               'T01:25:41', ...
               'T00:16:36', ...
               'T19:05:34', ...
               'T00:03:27', ...
               'T11:39:50'};

tstart_mms2 = {'T08:15:01', ...
               'T21:24:56', ...
               'T18:34:01', ...
               'T03:24:24', ...
               'T07:14:30', ...
               'T01:25:41', ...
               'T00:16:36', ...
               'T19:05:22', ...
               'T00:04:44', ...
               'T11:39:58'};

tstart_mms3 = {'T08:15:03', ...
               'T21:24:54', ...
               'T18:34:06', ...
               'T03:24:14', ...
               'T07:14:56', ...
               'T01:25:41', ...
               'T00:14:14', ...
               'T19:05:22', ...
               'T00:04:44', ...
               'T11:40:11'};

tstart_mms4 = {'T08:15:00', ...
               '', ...
               '', ...
               'T03:24:24', ...
               'T07:14:04', ...
               'T01:25:41', ...
               'T00:16:10', ...
               'T19:05:22', ...
               'T00:04:44', ...
               'T11:40:11'};

% Allocate memory
nTimes   = length(dates);
pos_mms1 = zeros(3, nTimes);
pos_mms2 = zeros(3, nTimes);
pos_mms3 = zeros(3, nTimes);
pos_mms4 = zeros(3, nTimes);

% Find position
for ii = 1 : length(dates)
	pos_mms1(:, ii) = mms_req_scpos('mms1', [dates{ii} tstart_mms1{ii}]);
end
for ii = 1 : length(dates)
	pos_mms2(:, ii) = mms_req_scpos('mms2', [dates{ii} tstart_mms2{ii}]);
end
for ii = 1 : length(dates)
	pos_mms3(:, ii) = mms_req_scpos('mms3', [dates{ii} tstart_mms3{ii}]);
end
for ii = 1 : length(dates)
	if ~isempty(tstart_mms4{ii})
		pos_mms4(:, ii) = mms_req_scpos('mms4', [dates{ii} tstart_mms4{ii}]);
	end
end



















