function handles = setup_menu(obj,handles)

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
    
    pixel_downsampling = handles.data_controller.downsampling;
    angle_downsampling = handles.data_controller.angle_downsampling;
    
    %================================= file

    menu_file      = uimenu(obj.window,'Label','File');
    handles.menu_file_new_window = uimenu(menu_file,'Label','New Window','Accelerator','N');
    handles.menu_file_set_src_single = uimenu(menu_file,'Label','Load single file..','Separator','on');
    % handles.menu_file_set_src_dir = uimenu(menu_file,'Label','Set Src - multiple files (directory)');
    handles.menu_file_reset_previous = uimenu(menu_file,'Label','Reset to previous');    
    % handles.menu_file_set_dst_dir = uimenu(menu_file,'Label','Set Dst - directory','Separator','on');
    handles.menu_file_save_current_volume = uimenu(menu_file,'Label','Save current volume','Separator','on');
            
    %================================= OMERO
    
    menu_OMERO = uimenu(obj.window,'Label','OMERO');

    handles.menu_OMERO_login = uimenu(menu_OMERO,'Label','Log in to OMERO');
    handles.menu_OMERO_Working_Data_Info = uimenu(menu_OMERO,'Label','Working Data have not been set up','ForegroundColor','red','Enable','off');

    menu_OMERO_Set_Data = uimenu(menu_OMERO,'Label','Set Working Data');
    handles.menu_OMERO_Set_Dataset = uimenu(menu_OMERO_Set_Data,'Label','Dataset','Enable','off');
    handles.menu_OMERO_Switch_User = uimenu(menu_OMERO_Set_Data,'Label','Switch User...','Separator','on','Enable','off');    

    handles.menu_OMERO_Connect_To_Another_User = uimenu(menu_OMERO_Set_Data,'Label','Connect to another user...','Enable','off');    
    handles.menu_OMERO_Connect_To_Logon_User = uimenu(menu_OMERO_Set_Data,'Label','Connect to logon user...','Enable','off');    

    handles.menu_OMERO_Reset_Logon = uimenu(menu_OMERO_Set_Data,'Label','Restore Logon','Separator','on','Enable','off');                
    
    handles.menu_OMERO_set_single = uimenu(menu_OMERO,'Label','Load single Image','Separator','on','Enable','off');
    % handles.menu_OMERO_set_multiple = uimenu(menu_OMERO,'Label','Set Src - multiple Images','Enable','off');
    % handles.menu_OMERO_reset_previous = uimenu(menu_OMERO,'Label','Reset to previous','Enable','off');    
    
    %================================= settings
    
    menu_settings = uimenu(obj.window,'Label','Settings');
    menu_settings_Pixel_Downsampling = uimenu(menu_settings,'Label',['Pixel downsampling 1/' num2str(pixel_downsampling)]);
    % menu_settings_Angle_Downsampling = uimenu(menu_settings,'Label',['Angle downsampling 1/' num2str(angle_downsampling)]);

    handles.menu_settings_Pixel_Downsampling_1 = uimenu(menu_settings_Pixel_Downsampling,'Label','1/1');    
    handles.menu_settings_Pixel_Downsampling_2 = uimenu(menu_settings_Pixel_Downsampling,'Label','1/2');
    handles.menu_settings_Pixel_Downsampling_4 = uimenu(menu_settings_Pixel_Downsampling,'Label','1/4');
    handles.menu_settings_Pixel_Downsampling_8 = uimenu(menu_settings_Pixel_Downsampling,'Label','1/8');
    handles.menu_settings_Pixel_Downsampling_16 = uimenu(menu_settings_Pixel_Downsampling,'Label','1/16');

%     handles.menu_settings_Angle_Downsampling_1 = uimenu(menu_settings_Angle_Downsampling,'Label','1/1');    
%     handles.menu_settings_Angle_Downsampling_2 = uimenu(menu_settings_Angle_Downsampling,'Label','1/2');
%     handles.menu_settings_Angle_Downsampling_4 = uimenu(menu_settings_Angle_Downsampling,'Label','1/4');
%     handles.menu_settings_Angle_Downsampling_8 = uimenu(menu_settings_Angle_Downsampling,'Label','1/8');
    
    handles.menu_settings_Pixel_Downsampling = menu_settings_Pixel_Downsampling;
    
%     handles.menu_settings_Angle_Downsampling = menu_settings_Angle_Downsampling;
        
    %================================= reconstruction
    
    menu_reconstruction = uimenu(obj.window,'Label','Reconstruction');
    handles.menu_reconstruction_FBP = uimenu(menu_reconstruction,'Label','Standard FBP');    
    handles.menu_reconstruction_FBP_GPU = uimenu(menu_reconstruction,'Label','Standard FBP (GPU)');
        
    %================================= visualization
    
    menu_visualization = uimenu(obj.window,'Label','Visualization');
    menu_visualization_Icy_setup = uimenu(menu_visualization,'Label','Icy setup');        
    handles.menu_visualization_setup_Icy_directory = uimenu(menu_visualization_Icy_setup,'Label','Set Icy directory');    
    handles.menu_visualization_start_Icy = uimenu(menu_visualization_Icy_setup,'Label','Start Icy');
    %
    handles.menu_visualization_send_current_proj_to_Icy = uimenu(menu_visualization,'Label','Send current Projections','Separator','on');
    handles.menu_visualization_send_current_volm_to_Icy = uimenu(menu_visualization,'Label','Send current Volume');    
    
    %================================= help   
    
    menu_help = uimenu(obj.window,'Label','Help');
    handles.menu_help_about = uimenu(menu_help,'Label','About...');
    handles.menu_help_tracker = uimenu(menu_help,'Label','Open Issue Tracker...');
    handles.menu_help_bugs = uimenu(menu_help,'Label','File Bug Report...');

    %================================= indication    
    
    handles.proj_label = uimenu(obj.window,'Label','proj','ForegroundColor','red');    
    handles.volm_label = uimenu(obj.window,'Label','volm','ForegroundColor','red');    
    % handles.batch_label = uimenu(obj.window,'Label','batch','ForegroundColor','red');    
        
end


