function frame_time = add_plane_to_OMEtiff_with_metadata(I, index, final_index, folder, ometiffilename, varargin)

global writer;
global getBytes;
global hw;

assert(isnumeric(I), 'First argument must be numeric');
assert(isnumeric(index), 'Second argument must be numeric');
assert(isnumeric(final_index), 'Third argument must be numeric');

ip = inputParser;

ip.addOptional('PhysSz_X', [], @isnumeric);
ip.addOptional('PhysSz_Y', [], @isnumeric);
ip.addOptional('ModuloZ_Type', [], @ischar);
ip.addOptional('ModuloZ_TypeDescription', [], @ischar);
ip.addOptional('ModuloZ_Unit', [], @ischar);
ip.addOptional('ModuloZ_Start', [], @isnumeric);
ip.addOptional('ModuloZ_Step', [], @isnumeric);
ip.addOptional('ModuloZ_End', [], @isnumeric);
ip.addOptional('ModuloZ_Labels', [], @isnumeric);
ip.addOptional('Tags', [], @ischar);    
ip.addOptional('Tags_SeparatingSeq', [], @ischar);    

ip.parse(varargin{:});

if 1 == index % make all setups

        addpath_OMEkit;

        sizeZ = final_index;

        % verify that enough memory is allocated
        bfCheckJavaMemory();
        % Check for required jars in the Java path
        bfCheckJavaPath();
        
        % ini logging
        loci.common.DebugTools.enableLogging('INFO');
        java.lang.System.setProperty('javax.xml.transform.TransformerFactory', 'com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl');

        metadata = createMinimalOMEXMLMetadata(I);
        toInt = @(x) ome.xml.model.primitives.PositiveInteger(java.lang.Integer(x));        
        metadata.setPixelsSizeZ(toInt(sizeZ), 0);

%%%%%%%%%%%%%%%%%%% set up Modulo XML description metadata if present - starts
if ~isempty(ip.Results.PhysSz_X)
    metadata.setPixelsPhysicalSizeX(ome.xml.model.primitives.PositiveFloat(java.lang.Double(ip.Results.PhysSz_X)),0);
end    
if ~isempty(ip.Results.PhysSz_Y)
    metadata.setPixelsPhysicalSizeY(ome.xml.model.primitives.PositiveFloat(java.lang.Double(ip.Results.PhysSz_Y)),0);
end

if (~isempty(ip.Results.ModuloZ_Type) && ~isempty(ip.Results.ModuloZ_TypeDescription) && ~isempty(ip.Results.ModuloZ_Unit)) || ~isempty(ip.Results.ModuloZ_Labels)
    modlo = loci.formats.CoreMetadata();        
    %
    modlo.moduloZ.type = ip.Results.ModuloZ_Type;
    modlo.moduloZ.unit = ip.Results.ModuloZ_Unit;
    modlo.moduloZ.typeDescription = ip.Results.ModuloZ_TypeDescription;
end

if ~isempty(ip.Results.ModuloZ_Start) && ~isempty(ip.Results.ModuloZ_Step) && ~isempty(ip.Results.ModuloZ_End)
    modlo.moduloZ.start = ip.Results.ModuloZ_Start;
    modlo.moduloZ.end = ip.Results.ModuloZ_End;
    modlo.moduloZ.step = ip.Results.ModuloZ_Step;
    %
elseif ~isempty(ip.Results.ModuloZ_Labels)
    %
    labels = ip.Results.ModuloZ_Labels;
    modlo.moduloZ.labels = javaArray('java.lang.String',length(labels));
    for i=1:length(labels)
        modlo.moduloZ.labels(i)= java.lang.String(num2str(labels(i)));
    end                                                      
end

if exist('modlo','var') 
    OMEXMLService = loci.formats.services.OMEXMLServiceImpl();
    OMEXMLService.addModuloAlong(metadata, modlo, 0); 
end;
%%%%%%%%%%%%%%%%%%% set up Modulo XML description metadata if present - ends        

% XMLAnnotaiton arrangement
% if only modulo present it goes with 0
% if description is present, it goes with 0
% then if modulo and description are present modulo goes with with 0 then
% description with 1

        % DESCRIPTION - one needs to find xml file if there... and so on
        n_anno = 0;        
        if exist('modlo','var'), n_anno = n_anno + 1; end;        
        try
            %
            xmlfilenames = dir([folder filesep '*.xml']);                
            for k = 1 : numel(xmlfilenames)
            xmlfilename = xmlfilenames(k).name;
                fid = fopen([folder filesep xmlfilename],'r');
                fgetl(fid);
                description = fscanf(fid,'%c');
                fclose(fid);
                index = n_anno+k-1;
                metadata.setXMLAnnotationID(['Annotation:' num2str(index)],index);
                metadata.setXMLAnnotationValue(description,index);
            end                        
            %
            n_anno = index;
            %
        catch err
            display(err.message);
        end
        % DESCRIPTION - ends
        
        % Tags
        tags = ip.Results.Tags;    
        sepsec = ip.Results.Tags_SeparatingSeq;    
        if ~isempty(tags) && ~isempty(sepsec)
            tags = strsplit(tags,sepsec);
            for k=1:numel(tags)
                metadata.setTagAnnotationID(['Annotation:' num2str(n_anno+k)],k-1);
                metadata.setTagAnnotationValue(tags{k},k-1);        
            end        
        end
        % Tags - end
                                       
        % Create ImageWriter
        writer = loci.formats.ImageWriter();
        writer.setWriteSequentially(true);
        writer.setMetadataRetrieve(metadata);        
        writer.setCompression('LZW'); % comment out to fix possible slowing down
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
        
        hw = waitbar(0, 'Loading images...');
end        

t0 = tic;
writer.saveBytes(index-1, getBytes(I));
frame_time = toc(t0);
waitbar(index/final_index,hw); drawnow;    
        
if index == final_index
    delete(hw); 
    drawnow;
    writer.close();
    
    %xmlValidate = loci.formats.tools.XMLValidate();
    %comment = loci.formats.tiff.TiffParser(ometiffilename).getComment()
    %xmlValidate.process(ometiffilename, java.io.BufferedReader(java.io.StringReader(comment)));    
end;

end