 function [ Dataset, Project ] = select_Dataset(session, userId, prompt)

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

            if isempty(userId)
                userId = session.getAdminService().getEventContext().userId;
            end;
            %
            Dataset = [];
            Project = [];            
            %
            proxy = session.getContainerService();
            %
            param = omero.sys.ParametersI();
                                  
            param.exp(omero.rtypes.rlong(userId));
            projectsList = proxy.loadContainerHierarchy('omero.model.Project', [], param);
            %
            alldatasetsList = proxy.loadContainerHierarchy('omero.model.Dataset', [], param);
            %                        
            did = zeros(1,alldatasetsList.size());            
                for i = 0:alldatasetsList.size()-1,
                    d = alldatasetsList.get(i);
                    dName = char(java.lang.String(d.getName().getValue()));                    
                    pName = 'NO PROJECT!';
                        for j = 0:projectsList.size()-1,
                            p = projectsList.get(j);
                                datasetsList = p.linkedDatasetList;
                                for m = 0:datasetsList.size()-1,
                                    pd = datasetsList.get(m);
                                    if pd.getId().getValue() == d.getId().getValue()
                                        pName = char(java.lang.String(p.getName().getValue()));
                                        break;
                                    end;
                                end;                            
                        end;            
                    dnme = [ pName ' @ ' dName ];
                    str(i+1,1:length(dnme)) = dnme;
                    did(i+1) = java.lang.Long(d.getId().getValue());                    
                end
            %
            if ~exist('str','var')
                errordlg('Sorry no datasets available for this user', 'Dataset error!');
                return; 
            end
            %
            % to sort by project etc. - start
            strcell_sorted = sort_nat(cellstr(str));
            strcell_unsorted = cellstr(str);
            did_sorted = zeros(1,alldatasetsList.size()); % to fill..
            %
            for d = 1:alldatasetsList.size()
                for dd = 1:alldatasetsList.size()
                    if strcmp(char(strcell_sorted(d)),char(strcell_unsorted(dd)))
                        did_sorted(d) = did(dd);
                        break;
                    end
                end
            end
            str = char(strcell_sorted);
            did = did_sorted;    
            % to sort by project etc. - end
            
            % request a Dataset using the "str" list
            [s,v] = listdlg('PromptString',prompt,...
                            'SelectionMode','single',...
                            'ListSize',[300 300],...
                            'ListString',str);            
            if(v) % find Project and Dataset by pre-recorded Id's
                    for i = 0:alldatasetsList.size()-1,
                        d = alldatasetsList.get(i);
                        if java.lang.Long(d.getId().getValue()) == did(s)
                            Dataset = d;
                                for j = 0:projectsList.size()-1,
                                    p = projectsList.get(j);
                                        datasetsList = p.linkedDatasetList;
                                        for m = 0:datasetsList.size()-1,
                                            pd = datasetsList.get(m);
                                            if pd.getId().getValue() == d.getId().getValue()
                                                Project = p;
                                                break;
                                            end;
                                        end;                            
                                end; 
                        return;
                        end                    
                    end                                                            
            end;
                    
 end