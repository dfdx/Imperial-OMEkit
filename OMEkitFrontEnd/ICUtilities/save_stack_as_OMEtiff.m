function save_stack_as_OMEtiff(folder, file_names, extension, dimension, FLIM_mode, ometiffilename)

            if isempty(file_names) || 0 == numel(file_names), return, end;
            
            num_files = numel(file_names);
            %
            sizeC = 1;
            sizeZ = 1;
            sizeT = 1;            
            
            try 
                I = imread([folder filesep file_names{1}],extension); 
                I = I'; % might fail if not single-plane data
            catch err, 
                msgbox(err.mesasge), 
                return, 
            end;

            sizeX = size(I,1);
            sizeY = size(I,2);
            %
            if strcmp(dimension,'none'), dimension = 'ModuloAlongZ'; end; % default
            %
            switch dimension
                case 'ModuloAlongC'
                    sizeC = num_files;
                case 'ModuloAlongZ'
                    sizeZ = num_files;
                case 'ModuloAlongT'
                    sizeT = num_files;
                otherwise
                    errordlg('wrong dimension specification'), return;
            end

% verify that enough memory is allocated
bfCheckJavaMemory();
% Check for required jars in the Java path
bfCheckJavaPath();
        
java.lang.System.setProperty('javax.xml.transform.TransformerFactory','com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl');

% Create metadata
toInt = @(x) ome.xml.model.primitives.PositiveInteger(java.lang.Integer(x));
OMEXMLService = loci.formats.services.OMEXMLServiceImpl();
metadata = OMEXMLService.createOMEXMLMetadata();
metadata.createRoot();

metadata.setImageID('Image:0', 0);
metadata.setPixelsID('Pixels:0', 0);
metadata.setPixelsBinDataBigEndian(java.lang.Boolean.TRUE, 0, 0);

% Set dimension order
dimensionOrderEnumHandler = ome.xml.model.enums.handlers.DimensionOrderEnumHandler();
dimensionOrder = dimensionOrderEnumHandler.getEnumeration('XYZCT');
metadata.setPixelsDimensionOrder(dimensionOrder, 0);

% Set pixels type
pixelTypeEnumHandler = ome.xml.model.enums.handlers.PixelTypeEnumHandler();
if strcmp(class(I), 'single')
    pixelsType = pixelTypeEnumHandler.getEnumeration('float');
else
    pixelsType = pixelTypeEnumHandler.getEnumeration(class(I));
end

metadata.setPixelsType(pixelsType, 0);

metadata.setPixelsSizeX(toInt(sizeX), 0);
metadata.setPixelsSizeY(toInt(sizeY), 0);
metadata.setPixelsSizeZ(toInt(sizeZ), 0);
metadata.setPixelsSizeC(toInt(sizeC), 0);
metadata.setPixelsSizeT(toInt(sizeT), 0);

toNNI = @(x) ome.xml.model.primitives.NonNegativeInteger(java.lang.Integer(x));
    %
    num_files = numel(file_names);
                        %
                       for i = 1:num_files
% THIS WORKS BUT THIS SPECIFICATION IS PRESENTLY NOT USED                            
                                z = 1;
                                c = 1;
                                t = 1;
                                %
                                switch dimension
                                    case 'ModuloAlongC'
                                        c = i;
                                    case 'ModuloAlongZ'
                                        z = i;
                                    case 'ModuloAlongT'
                                        t = i;
                                end
                                metadata.setPlaneTheZ(toNNI(z-1),0,i-1);
                                metadata.setPlaneTheC(toNNI(c-1),0,i-1);
                                metadata.setPlaneTheT(toNNI(t-1),0,i-1);
% metadata.setPlaneAnnotationRef(['Annotation:' num2str(i-1)],0,i-1,0); %excessive + causes error (in the case of OPT) ...  
                                metadata.setTiffDataIFD(toNNI(z-1),0,i-1);
                                metadata.setTiffDataFirstZ(toNNI(z-1),0,i-1);
                                metadata.setTiffDataFirstC(toNNI(c-1),0,i-1);
                                metadata.setTiffDataFirstT(toNNI(t-1),0,i-1);                                                                                                
                                %                                                                
%                                 if ~(strcmp(FLIM_mode,'Time Gated') || strcmp(FLIM_mode,'Time Gated non-imaging'))                                                      
%                                     metadata.setCommentAnnotationID(['Annotation:' num2str(i-1)],i-1);
%                                     metadata.setCommentAnnotationValue(char(file_names{i}),i-1);
%                                 end                                
                        end                                                                                      
                        %                                        
                        if strcmp(FLIM_mode,'Time Gated') || strcmp(FLIM_mode,'Time Gated non-imaging')                      
                            
                                % MODULO   
                                modlo = loci.formats.CoreMetadata();
                            
                              % check if FLIM Modulo specification is available    
                              channels_names = cell(1,num_files);
                              for i = 1 : num_files
                                  fnamestruct = parse_DIFN_format1(file_names{i});
                                  channels_names{i} = fnamestruct.delaystr;
                              end
                              %  
                              delays = zeros(1,numel(channels_names));
                              for f=1:numel(channels_names)
                                delays(f) = str2num(channels_names{f});
                              end                    

                              switch dimension

                                  case 'ModuloAlongZ'
                                      modlo.moduloZ.type = loci.formats.FormatTools.LIFETIME;
                                      modlo.moduloZ.unit = 'ps';
                                      modlo.moduloZ.typeDescription = 'Gated';
                                      %  
                                      modlo.moduloZ.labels = javaArray('java.lang.String',length(delays));                                  
                                      for i=1:length(delays)
                                        modlo.moduloT.labels(i)= java.lang.String(num2str(delays(i)));
                                      end                                                      

                                  case 'ModuloAlongC'
                                      modlo.moduloC.type = loci.formats.FormatTools.LIFETIME;
                                      modlo.moduloC.unit = 'ps';
                                      modlo.moduloC.typeDescription = 'Gated';                     
                                      %
                                      modlo.moduloC.labels = javaArray('java.lang.String',length(delays));                                  
                                      for i=1:length(delays)
                                        modlo.moduloC.labels(i)= java.lang.String(num2str(delays(i)));
                                      end                                                      

                                  case 'ModuloAlongT'
                                      modlo.moduloT.type = loci.formats.FormatTools.LIFETIME;
                                      modlo.moduloT.unit = 'ps';
                                      modlo.moduloT.typeDescription = 'Gated';                              
                                      %
                                      modlo.moduloT.labels = javaArray('java.lang.String',length(delays));                                  
                                      for i=1:length(delays)
                                        modlo.moduloT.labels(i)= java.lang.String(num2str(delays(i)));
                                      end                                                      
                              end

                        end
                      
if exist('modlo','var'), OMEXMLService.addModuloAlong(metadata, modlo, 0); end;                      

% Set channels ID and samples per pixel
for i = 1: sizeC
    metadata.setChannelID(['Channel:0:' num2str(i-1)], 0, i-1);
    metadata.setChannelSamplesPerPixel(toInt(1), 0, i-1);
end

        % DESCRIPTION - starts
        try
            description1 = [];
            xmlfilename = [];
            xmlfilenames = dir([folder filesep '*.xml']);                
            if 1 == numel(xmlfilenames), xmlfilename = xmlfilenames(1).name; end;
            if ~isempty(xmlfilename)
                fid = fopen([folder filesep xmlfilename],'r');
                fgetl(fid);
                description1 = fscanf(fid,'%c');
                fclose(fid);
            end                                                
            %
            % try the same, one level up
            description2 = []; 
            xmlfilename = [];            
            sf = strfind(folder,filesep);
            xmlfilenames = dir([folder(1:sf(length(sf))) '*.xml']);                
                if 1 == numel(xmlfilenames), xmlfilename = xmlfilenames(1).name; end;
                if ~isempty(xmlfilename)
                    fid = fopen([folder(1:sf(length(sf))) xmlfilename],'r');
                    fgetl(fid);                
                    description2 = fscanf(fid,'%c');
                    fclose(fid);
                end
            
            ann_ind = 0;
            if exist('modlo','var'), ann_ind = 1; end;            
            
            if ~isempty(description1) && ~isempty(description2)
                metadata.setXMLAnnotationID(['Annotation:' num2str(ann_ind)],ann_ind); 
                metadata.setXMLAnnotationValue(description1,ann_ind);
                ann_ind = ann_ind + 1;
                metadata.setXMLAnnotationID(['Annotation:' num2str(ann_ind)],ann_ind); 
                metadata.setXMLAnnotationValue(description2,ann_ind);
            else
                dscr = [];
                if ~isempty(description1) 
                    dscr = description1;
                elseif ~isempty(description2) 
                    dscr = description2; 
                end;
                if ~isempty(dscr)
                    metadata.setXMLAnnotationID(['Annotation:' num2str(ann_ind)],ann_ind); 
                    metadata.setXMLAnnotationValue(dscr,ann_ind);
                end
            end

            
% THIS DOESN'T WORK!!!!!!!!!!!!!!!!!!!!!!            
%             if ~(strcmp(FLIM_mode,'Time Gated') || strcmp(FLIM_mode,'Time Gated non-imaging'))                                                      
%                 for i=1+ann_ind:34
%                     metadata.setCommentAnnotationID(['Annotation:' num2str(i)],i);
%                     metadata.setCommentAnnotationValue(char(file_names{i}),i);                    
%                 end                
%             end
                        for k=0:num_files-1
                     metadata.setCommentAnnotationID(['Annotation:' num2str(k)],k);
                     metadata.setCommentAnnotationValue(char(file_names{k+1}),k);                    
                        end
            
            
       catch err
             display(err.message);
       end
       % DESCRIPTION - ends
                       
% Create ImageWriter
writer = loci.formats.ImageWriter();
writer.setWriteSequentially(true);
writer.setMetadataRetrieve(metadata);
writer.setCompression('LZW');
writer.getWriter(ometiffilename).setBigTiff(true);
writer.setId(ometiffilename);

% Load conversion tools for saving planes
switch class(I)
    case {'int8', 'uint8'}
        getBytes = @(x) x(:);
    case {'uint16','int16'}
        getBytes = @(x) loci.common.DataTools.shortsToBytes(x(:), 0);
    case {'uint32','int32'}
        getBytes = @(x) loci.common.DataTools.intsToBytes(x(:), 0);
    case {'single'}
        getBytes = @(x) loci.common.DataTools.floatsToBytes(x(:), 0);
    case 'double'
        getBytes = @(x) loci.common.DataTools.doublesToBytes(x(:), 0);
end

% Save planes to the writer
hw = waitbar(0, 'Loading images...');
nPlanes = sizeZ * sizeC * sizeT;
for index = 1 : nPlanes
    I = imread([folder filesep file_names{index}],extension);            
    I = I';
    writer.saveBytes(index-1, getBytes(I));
waitbar(index/nPlanes,hw); drawnow;    
end
delete(hw); drawnow;

writer.close();

% xmlValidate = loci.formats.tools.XMLValidate();
% comment = loci.formats.tiff.TiffParser(ometiffilename).getComment()
% xmlValidate.process(ometiffilename, java.io.BufferedReader(java.io.StringReader(comment)));

end