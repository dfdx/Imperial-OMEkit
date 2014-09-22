%-------------------------------------------------------------------------%
    function ret = parse_WP_format(folder)

            % A-7 - FOV00239

            ret = [];

            try
                letters = 'ABCDEFGH';

                dirlist = [];
                totlist = dir(folder);

                    z = 0;
                    for k=3:length(totlist)
                        if 1==totlist(k).isdir
                            z=z+1;
                            dirlist{z} = totlist(k).name;
                        end;
                    end  

                dirlist = sort_nat(dirlist);
                num_dirs = numel(dirlist);

                rows = zeros(1,num_dirs);
                cols = zeros(1,num_dirs);
                params = zeros(1,num_dirs);
                names = cell(1,num_dirs);

                for i = 1 : num_dirs        
                    iName = dirlist{i};        
                    names{i} = iName;                
                    str = split('-',iName);
                    imlet = char(str(1));
                    rows(1,i) = find(letters==imlet)-1;
                    cols(1,i) = str2num(char(str(2)))-1;        
                    %
                    str = split(' _ FOV',iName);
                    params(1,i) = str2num(char(str(length(str))));
                end        

                ret.names = names;
                ret.rows = rows;
                ret.cols = cols;
                ret.params  = params;
                ret.colMaxNum = 12;
                ret.rowMaxNum = 8;
                ret.extension = 'tif';
                ret.columnNamingConvention = 'number';  % 'Column_Names';
                ret.rowNamingConvention = 'letter';     % 'Row_Names'; 

            catch err
                display(err.message);    
            end
        end 