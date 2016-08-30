%--------------------------------------------------------------------------
% NAME
%   mms_fsm_l2plus_write
%
% PURPOSE
%   Write L2Plus merged magnetometer data to a file.
%
% CALLING SEQUENCE:
%   mms_fsm_l2plus_write( FSM_QL )
%       Write merged magnetic field data to a file. Data is contained in
%       FSM_QL and is returned by mms_fsm_create_ql.m.
%
% History:
%  2015-12-08  - Written by Matthew Argall
%  2016-04-01  - Updated metadata. - MRA
%--------------------------------------------------------------------------
function fname_fsm = mms_fsm_l2plus_write( parents, fsm_l2plus )

%------------------------------------%
% Gather Metadata                    %
%------------------------------------%
	% Find an FSM parent file
	isParent = ~isempty( regexp(parents, 'scm') );
	scm_file = parents{ isParent };

	% Dissect the file name
	[sc, ~, mode, ~, tstart] = mms_dissect_filename( [scm_file '.cdf'] );
	if ~strmatch(mode, 'brst')
		mode = 'srvy';
	end
	
	% Constants
	instr   = 'dfg-scm';
	level   = 'l2plus';
	optdesc = 'fsm-split';
	outdir  = fullfile('/nfs', 'fsm', 'temp');

%------------------------------------%
% Create CDF File Name               %
%------------------------------------%

	% Describe the modifications to each version
	version = 'v0.0.0';
	mods    = {  'v0.0.0 -- First version.' ...
	          };

	% Create the output filename
	fname_fsm = mms_construct_filename(sc, instr, mode, level, ...
	                                   'Directory', outdir,    ...
	                                   'OptDesc',   optdesc,   ...
	                                   'TStart',    tstart,    ...
	                                   'Version',   version);

%------------------------------------------------------
% Global Attributes                                   |
%------------------------------------------------------
	if isempty(optdesc)
		data_type      = [mode '_' level];
		logical_source = [instr '_' mode '_' level];
	else
		data_type      = [mode '_' level '_' optdesc];
		logical_source = [instr '_' mode '_' level '_' optdesc];
	end
	[~, logical_file_id, ext] = fileparts(fname_fsm);
	logical_file_id = [logical_file_id ext];
	
	%   - Instrument Type (1+)
	%           Electric Fields (space)
	%           Magnetic Fields (space)
	%           Particles (space)
	%           Plasma and Solar Wind
	%           Spacecraft Potential Control
	global_attrs = struct( 'Data_type',                  data_type, ...
	                       'Data_version',               version, ...
	                       'Descriptor',                 instr, ...
	                       'Discipline',                 'Space Physics>Magnetospheric Science', ...
	                       'Generation_date',            datestr(now(), 'yyyymmdd'), ...
	                       'Instrument_type',            'Magnetic Fields (space)', ...
	                       'Logical_file_id',            logical_file_id, ...
	                       'Logical_source',             logical_source, ...
	                       'Logical_source_description', ' ', ...
	                       'Mission_group',              'MMS', ...
	                       'PI_affiliation',             'SWRI, UNH', ...
	                       'PI_name',                    'R. Torbert, O. LeContel, C. Russell, R. Strangeway, W. Magnes', ...
	                       'Project',                    'STP>Solar Terrestrial Physics', ...
	                       'Source_name',                ['MMS' sc(4) '>MMS Satellite Number ' sc(4)], ...
	                       'TEXT',                       ['The merged magnetic field ' ...
	        'dataset is a combination of the DFG and SCM magnetometers. Merging is done in the ' ...
	        'frequency domain in the same step as data calibration. Instrument papers for DFG ' ...
	        'and SCM, as well as their data products guides, can be found at the following links: ' ...
	        'http://dx.doi.org/10.1007/s11214-014-0057-3, ' ...
	        'http://dx.doi.org/10.1007/s11214-014-0096-9, ' ...
	        'https://lasp.colorado.edu/mms/sdc/public/datasets/fields/'], ...
	                       'HTTP_LINK',                  { {'http://mms-fields.unh.edu/' ...
	                                                        'http://mms.gsfc.nasa.gov/index.html'} }, ...
	                       'LINK_TEXT',                  { {'UNH FIELDS Home Page', ...
	                                                        'NASA MMS Home'} }, ...
	                       'MODS',                       { mods }, ...
	                       'Acknowledgements',           ' ', ...
	                       'Generated_by',               'University of New Hampshire', ...
	                       'Parents',                    { parents }, ...
	                       'Skeleton_version',           ' ', ...
	                       'Rules_of_use',               ' ', ...
	                       'Time_resolution',            ' '  ...
	                     );

%------------------------------------------------------
% Variables                                           |
%------------------------------------------------------
	% Hyphens are not allowed invariable names
	vinstr = strrep(instr, '-', '_');

	% Variable naming convention
	%   scId_instrumentId_paramName_optionalDescriptor
	t_vname      = 'Epoch';
	b_bcs_vname  = mms_construct_varname(sc, vinstr, 'b', 'bcs');
	b_dmpa_vname = mms_construct_varname(sc, vinstr, 'b', 'dmpa');
	b_gse_vname  = mms_construct_varname(sc, vinstr, 'b', 'gse');
	b_gsm_vname  = mms_construct_varname(sc, vinstr, 'b', 'gsm');
	b_labl_vname = 'B_Labl_Ptr';

	% Variables
	var_list = { t_vname,      fsm_l2plus.tt2000, ...
	             b_bcs_vname,  fsm_l2plus.b_bcs,  ...
	             b_dmpa_vname, fsm_l2plus.b_dmpa, ...
	             b_gse_vname,  fsm_l2plus.b_gse,  ...
	             b_gsm_vname,  fsm_l2plus.b_gsm,  ...
	             b_labl_vname, {'Bx', 'By', 'Bz'} ...
	           };

	recbound = { t_vname,      ...
	             b_bcs_vname,  ...
	             b_dmpa_vname, ...
	             b_gse_vname,  ...
	             b_gsm_vname   ...
	           };

	% Variable data types
	vardatatypes = { t_vname,      'cdf_time_tt2000', ...
	                 b_bcs_vname,  'cdf_float',       ...
	                 b_dmpa_vname, 'cdf_float',       ...
	                 b_gse_vname,  'cdf_float',       ...
	                 b_gsm_vname,  'cdf_float',       ...
	                 b_labl_vname, 'cdf_char'         ...
	               };
	
	% Variable compression
	varcompress = { b_bcs_vname,  'gzip.6', ...
	                b_dmpa_vname, 'gzip.6', ...
	                b_gse_vname,  'gzip.6', ...
	                b_gsm_vname,  'gzip.6'  ...
	              };

%------------------------------------------------------
% Variable Attributes                                 |
%------------------------------------------------------
	%
	% This assignment fails because the cell arrays do not have the same
	% number of elements. Adding variable attributes will have to be done
	% with cdflib.
	%
	var_attrs = struct( 'CATDESC',       {  ...
	                                       { t_vname,      'Time variable', ...
	                                         b_bcs_vname,  'Three components of the magnetic field in BCS coordinates.', ...
	                                         b_dmpa_vname, 'Three components of the magnetic field in DMPA coordinates.', ...
	                                         b_gse_vname,  'Three components of the magnetic field in GSE coordinates.', ...
	                                         b_gsm_vname,  'Three components of the magnetic field in GSM coordinates.', ...
	                                         b_labl_vname  'Axis labels for magnetic field data.' } ...
	                                     }, ...
	                    'DEPEND_0',      {  ...
	                                       { b_bcs_vname,  t_vname, ...
	                                         b_dmpa_vname, t_vname, ...
	                                         b_gse_vname,  t_vname, ...
	                                         b_gsm_vname,  t_vname  ...
	                                       } ...
	                                     }, ...
	                    'DISPLAY_TYPE',  {  ... 
	                                       { b_bcs_vname,  'time_series', ...
	                                         b_dmpa_vname, 'time_series', ...
	                                         b_gse_vname,  'time_series', ...
	                                         b_gsm_vname,  'time_series'  ...
	                                       } ...
	                                     }, ...
	                    'FIELDNAM',      {  ...
	                                       { t_vname,      'Time', ...
	                                         b_bcs_vname,  'Merged Magnetic Field', ...
	                                         b_dmpa_vname, 'Merged Magnetic Field', ...
	                                         b_gse_vname,  'Merged Magnetic Field', ...
	                                         b_gsm_vname,  'Merged Magnetic Field', ...
	                                         b_labl_vname, 'Axis Labels'            ...
	                                       }
	                                     }, ...
	                    'FILLVAL',       {  ...
	                                       { t_vname,      -1.0E31, ...
	                                         b_bcs_vname,  single(-1.0E31), ...
	                                         b_dmpa_vname, single(-1.0e31), ...
	                                         b_gse_vname,  single(-1.0e31), ...
	                                         b_gsm_vname,  single(-1.0e31)  ...
	                                       } ...
	                                     }, ...
	                    'FORMAT',        {  ...
	                                       { t_vname,      'I16',   ...
	                                         b_bcs_vname,  'F12.6', ...
	                                         b_dmpa_vname, 'F12.6', ...
	                                         b_gse_vname,  'F12.6', ...
	                                         b_gsm_vname,  'F12.6'  ...
	                                       } ...
	                                     }, ...
	                    'LABLAXIS',      {  ...
	                                       { t_vname,      'UT' ...
	                                       } ...
	                                     }, ...
	                    'LABL_PTR_1',    {  ...
	                                       { b_bcs_vname,  b_labl_vname, ...
	                                         b_dmpa_vname, b_labl_vname, ...
	                                         b_gse_vname,  b_labl_vname, ...
	                                         b_gsm_vname,  b_labl_vname  ...
	                                       } ...
	                                     }, ...
	                    'SI_CONVERSION', {  ...
	                                       { t_vname,      '1e-9>seconds', ...
	                                         b_bcs_vname,  '1e-9>Tesla',   ...
	                                         b_dmpa_vname, '1e-9>Tesla',   ...
	                                         b_gse_vname,  '1e-9>Tesla',   ...
	                                         b_gsm_vname,  '1e-9>Tesla'    ...
	                                       } ...
	                                     }, ...
	                    'UNITS',         {  ...
	                                       { t_vname,      'ns', ...
	                                         b_bcs_vname,  'nT', ...
	                                         b_dmpa_vname, 'nT', ...
	                                         b_gse_vname,  'nT', ...
	                                         b_gsm_vname,  'nT'  ...
	                                       }
	                                     }, ...
	                    'VALIDMIN',      {  ...
	                                       { t_vname,      cdflib.computeEpoch([2015, 3, 1, 0, 0, 0, 0]), ...
	                                         b_bcs_vname,  single(-100000.0), ...
	                                         b_dmpa_vname, single(-100000.0), ...
	                                         b_gse_vname,  single(-100000.0), ...
	                                         b_gsm_vname,  single(-100000.0)  ...
	                                       } ...
	                                     }, ...
	                    'VALIDMAX',      {  ...
	                                       { t_vname,      cdflib.computeEpoch([2050, 3, 1, 0, 0, 0, 0]), ...
	                                         b_bcs_vname,  single(100000.0), ...
	                                         b_dmpa_vname, single(100000.0), ...
	                                         b_gse_vname,  single(100000.0), ...
	                                         b_gsm_vname,  single(100000.0)  ...
	                                       } ...
	                                     }, ...
	                    'VAR_TYPE',      {  ...
	                                       { t_vname,      'support_data', ...
	                                         b_bcs_vname,  'data',         ...
	                                         b_dmpa_vname, 'data',         ...
	                                         b_gse_vname,  'data',         ...
	                                         b_gsm_vname,  'data',         ...
	                                         b_labl_vname, 'metadata'      ...
	                                       } ...
	                                     } ...
	                  );

%------------------------------------------------------
% Write the File                                      |
%------------------------------------------------------
	spdfcdfwrite( fname_fsm, ...
	              var_list, ...
	              'GlobalAttributes',   global_attrs, ...
	              'RecordBound',        recbound,     ...
	              'VariableAttributes', var_attrs,    ...
	              'VarDatatypes',       vardatatypes, ...
	              'VarCompress',        varcompress   ...
	            );
	
	% If the file name is not output, print location to command window.
	if nargout == 0
		clear fname_fsm
		disp(['File written to ', fname_fsm]);
	end
end