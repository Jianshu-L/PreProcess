        function [fExist, fName] = NtoF(obj, dName)
            % neuron marker data name to data folder
            % Arg:
            %   dName: neuron data name. "datafile20210311001Marker.mat" or obj.BRdir.fileName
            % Out:
            %   fExist: whether data folder exist
            %   fName: data folder name. "omegaL-11-Mar-2021-1"
                
            name = char(dName);
            if all(contains(dName, '.'))
                temp = split(dName, '.');
                if length(dName) == 1
                    temp = temp';
                end
                name = char(temp(:,1));
            end
            dt = datetime(name(:,9:16), 'InputFormat','yyyyMMdd','Locale','en_US','Format','dd-MMM-yyyy');
            i_ = contains(string(name),"p");
            fName_ = string(zeros(length(dName),1));
            fName_(i_) = strcat('Patamon-', string(dt(i_)));
            fName_(~i_) = strcat('omegaL-', string(dt(~i_)));
            index_ = contains(obj.BEV.file, fName_);
            if sum(index_) == 0
                fprintf("no related behaviour data for %s\n", dName)
                fExist = 0;
                fName = strcat(fName_, '-d');
            else
                fExist = 1;
                fName = obj.BEV.file(index_);
            end
        end
