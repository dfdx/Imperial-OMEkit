%> @ingroup UserInterfaceControllers
classdef ic_OPTtools_omero_data_manager < handle 
    
    % Copyright (C) 2013 Imperial College London.
    % All rights reserved.
    %and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation; either version 2 of the
    % This program is free software; you can redistribute it  License, or
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
       
    properties(SetObservable = true)
        
        omero_logon_filename = 'omero_logon.xml';        
        logon;
        client;     
        session;    
        dataset;    
        %
        image;
        %
        userid;       

    end
        
    methods
        
        function obj = ic_OPTtools_omero_data_manager(varargin)            
            handles = args2struct(varargin);
            assign_handles(obj,handles);
            
        end
                                        
        function delete(obj)
        end
                  
        %------------------------------------------------------------------                
        function infostring = Set_Dataset(obj,~,~)
            %
            infostring = [];            
            %
            chooser = OMEuiUtils.OMEROImageChooser(obj.client, obj.userid, int32(1));
            Dataset = chooser.getSelectedDataset();
            %
            if isempty(Dataset), return, end;
            %
            obj.dataset = Dataset;
            %            
            dName = char(java.lang.String(obj.dataset.getName().getValue()));                    
            dIdName = num2str(obj.dataset.getId().getValue());                       
            infostring = [ 'Dataset "' dName '" [' dIdName ']' ];
            %
        end                

        %------------------------------------------------------------------                
        function infostring = Set_Images(obj,data_controller,~)
            %
            infostring = [];            
            %
            chooser = OMEuiUtils.OMEROImageChooser(obj.client, obj.userid, true);
            Images = chooser.getSelectedImages();
            %
            if isempty(Images), return, end;
            %
            data_controller.omero_Image_IDs = Images;
            I1_name = char(java.lang.String(Images(1).getName().getValue()));
            infostring = [ 'Selected Images: "' I1_name '" et all' ];
            %
        end                
                
        %------------------------------------------------------------------                
        function Omero_logon(obj,~) 
            
            settings = [];
            
            % look in FLIMfit/dev for logon file
            folder = getapplicationdatadir('FLIMfit',true,true);
            subfolder = [folder filesep 'Dev']; 
            if exist(subfolder,'dir')
                logon_filename = [ subfolder filesep obj.omero_logon_filename ];
                if exist(logon_filename,'file') 
                    [ settings, ~ ] = xml_read (logon_filename);    
                    obj.logon = settings.logon;
                end
                
            end
            
            keeptrying = true;
           
            while keeptrying 
                
            if ~ispref('ic_OPTtoolsFrontEnd','OMEROlogin')
                neverTriedLog = true;       % set flag if the OMERO dialog login has never been called on this machine
            else
                neverTriedLog = false;
            end
                
            
            % if no logon file then user must login
            if isempty(settings)
                obj.logon = OMERO_logon();
            end
                        
            try
           if isempty(obj.logon{4})
               if neverTriedLog == true
                   ret_string = questdlg('Respond "Yes" ONLY if you intend NEVER to use OMEkit with OMERO on this machine!');
                   if strcmp(ret_string,'Yes')
                        addpref('ic_OPTtoolsFrontEnd','NeverOMERO','On');
                   end
               end
               return
           end
            catch
            end
            
                keeptrying = false;     % only try again in the event of failure to logon
                
                try 
                    port = obj.logon{2};
                    if ischar(port), port = str2num(port); end;
                    obj.client = loadOmero(obj.logon{1},port);                                    
                    obj.session = obj.client.createSession(obj.logon{3},obj.logon{4});
                catch err
                    display(err.message);
                    obj.client = [];
                    obj.session = [];
                    % Construct a questdlg with three options
                    choice = questdlg('OMERO logon failed!', ...
                    'Logon Failure!', ...
                    'Try again to logon','Run OMEkit in non-OMERO mode','Launch OMEkit in non-OMERO mode');
                    % Handle response
                    switch choice
                        case 'Try again to logon'
                            keeptrying = true;                                                  
                        case 'Run OMEkit in non-OMERO mode'
                            % no action keeptrying is already false                       
                    end    % end switch           
                end   % end catch
                if ~isempty(obj.session)
                    obj.client.enableKeepAlive(60); % Calls session.keepAlive() every 60 seconds
                    obj.userid = obj.session.getAdminService().getEventContext().userId;                    
                end
            end     % end while                        
            
        end
       %------------------------------------------------------------------        
       function Omero_logon_forced(obj,~) 
                        
            keeptrying = true;
           
            while keeptrying 
            
            obj.logon = OMERO_logon();
                                    
           if isempty(obj.logon)
               return
           end
            
                keeptrying = false;     % only try again in the event of failure to logon
          
                try 
                    port = obj.logon{2};
                    if ischar(port), port = str2num(port); end;
                    obj.client = loadOmero(obj.logon{1},port);                                    
                    obj.session = obj.client.createSession(obj.logon{3},obj.logon{4});
                catch err
                    display(err.message);
                    obj.client = [];
                    obj.session = [];
                    % Construct a questdlg with three options
                    choice = questdlg('OMERO logon failed!', ...
                    'Logon Failure!', ...
                    'Try again to logon','Run OMEkit in non-OMERO mode','Run OMEkit in non-OMERO mode');
                    % Handle response
                    switch choice
                        case 'Try again to logon'
                            keeptrying = true;                                                  
                        case 'Run OMEkit in non-OMERO mode'
                            % no action keeptrying is already false                       
                    end    % end switch           
                end   % end catch
                if ~isempty(obj.session)
                    obj.client.enableKeepAlive(60); % Calls session.keepAlive() every 60 seconds
                    obj.userid = obj.session.getAdminService().getEventContext().userId;                                        
                end
            end     % end while     
            
       end
                       
        %------------------------------------------------------------------
        function Select_Another_User(obj,~)
                   
            ec = obj.session.getAdminService().getEventContext();
            AdminServicePrx = obj.session.getAdminService();            
                        
            groupids = toMatlabList(ec.memberOfGroups);                  
            gid = groupids(1); %default - first group is the current?                                   
            experimenter_list_g = AdminServicePrx.containedExperimenters(gid);
                                    
            z = 0;
            for exp = 0:experimenter_list_g.size()-1
                exp_g = experimenter_list_g.get(exp);
                z = z + 1;
                nme = [num2str(exp_g.getId.getValue) ' @ ' char(java.lang.String(exp_g.getOmeName().getValue()))];
                str(z,1:length(nme)) = nme;                                                
            end                
                        
            strcell_sorted = sort_nat(unique(cellstr(str)));
            str = char(strcell_sorted);
                                    
            EXPID = [];
            prompt = 'Please choose the user';
            [s,v] = listdlg('PromptString',prompt,...
                                        'SelectionMode','single',...
                                        'ListSize',[300 300],...                                        
                                        'ListString',str);                        
            if(v)
                expname = str(s,:);
                expnamesplit = split('@',expname);
                EXPID = str2num(char(expnamesplit(1)));
            end;                                            

            if ~isempty(EXPID) 
                obj.userid = EXPID;
            else
                obj.userid = obj.session.getAdminService().getEventContext().userId;                
            end                                                                     
            %
            obj.dataset = [];
            %
        end         
        
    end
end

