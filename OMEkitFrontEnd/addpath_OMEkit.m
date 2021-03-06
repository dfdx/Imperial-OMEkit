function addpath_OMEkit()

% Copyright (C) 2013 Imperial College London.
% All rights reserved.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
% This software tool was developed with support from the UK 
% Engineering and Physical Sciences Council 
% through  a studentship from the Institute of Chemical Biology 
% and The Wellcome Trust through a grant entitled 
% "The Open Microscopy Environment: Image Informatics for Biological Sciences" (Ref: 095931).

% Author : Sean Warren

    if ~isdeployed
        
        thisdir = fileparts( mfilename( 'fullpath' ) );
        addpath( thisdir,...
                [thisdir filesep 'Classes'],...      
                [thisdir filesep 'GUIDEInterfaces'],... 
                [thisdir filesep 'GeneratedFiles'],...                
                [thisdir filesep 'InternalHelperFunctions'],...
                [thisdir filesep 'InternalHelperFunctions' filesep 'RawDataFunctions'],...
                [thisdir filesep 'HelperFunctions'],...
                [thisdir filesep 'HelperFunctions' filesep 'GUILayout'],...
                [thisdir filesep 'HelperFunctions' filesep 'GUILayout' filesep 'Patch'],...
                [thisdir filesep 'HelperFunctions' filesep 'GUILayout' filesep 'layoutHelp'],...
                [thisdir filesep 'HelperFunctions' filesep 'xml_io_toos'],...
                [thisdir filesep 'BFMatlab'],...
                [thisdir filesep 'OMEROUtilities'],...
                [thisdir filesep 'ICUtilities'],...
                [thisdir filesep 'TwIST_OPT'],...
                [thisdir filesep 'OMEuiUtils'],...                                
                [matlabroot filesep 'toolbox' filesep 'images' filesep 'images']);
            
            addpath( ...
                [thisdir filesep 'OMEROMatlab'],... 
                [thisdir filesep 'OMEROMatlab' filesep 'helper'],... 
                [thisdir filesep 'OMEROMatlab' filesep 'io'],... 
                [thisdir filesep 'OMEROMatlab' filesep 'libs'],... 
                [thisdir filesep 'OMEROMatlab' filesep 'roi']);
                
            addpath( ...
                [thisdir filesep 'ICY_Matlab' filesep 'matlabcommunicator'],... 
                [thisdir filesep 'ICY_Matlab' filesep 'matlabxserver']);                                                
            
        % Test genops
        genops(1);

        a = ones(10,10);
        b = ones(10,1);

        try 
            c = a.*b;
            if ~all(size(c)==[10,10])
                makegenops;
                genops(1);    
            end
        catch
            makegenops;
            genops(1);
        end
                        
    end

end