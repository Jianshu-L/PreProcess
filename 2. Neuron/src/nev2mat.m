function nev2mat(dataPath, archivePath)
BRfile = dirFiles(dataPath, 'nev');
ndName = strrep(BRfile, '.nev', 'Eve.mat');
%% read nev
NEVtime = 0;
for i = 1:length(BRfile)
    file = strcat(dataPath, '/', BRfile(i,:));
    fileEvent = strcat(archivePath, '/', ndName(i));
    if ~exist(fileEvent,'file') % whether Eve.mat exist
        % fprintf("nev to mat\n")
        % fprintf('open nev %s\n', file)
        tic;
        openNEV(char(file));
        t2 = toc;
        NEVtime = NEVtime + t2;
        load(strrep(file, "nev", "mat"),"NEV");
        delete(strrep(file, "nev", "mat"));
        evt = NEV.Data.SerialDigitalIO.UnparsedData;
        timestep = NEV.Data.SerialDigitalIO.TimeStamp;
        NevTags = NEV.MetaTags;
        marker = dec2bin(evt);
        if isempty(marker)
            fprintf("*****%s has no marker*****\n", file)
            event = [];
            save(fileEvent, 'event', 'NevTags', 'evt', 'timestep');
            continue
        end
        index = find(marker(:,9) == '1');
        markerS = bin2dec(marker(index-1,9:16));
        timestep = double(timestep(index-1)');
        event = [timestep';markerS'];
        if isempty(event)
            fprintf("*****%s has no marker*****\n", file)
            event = [];
            save(fileEvent, 'event', 'NevTags', 'evt', 'timestep');
            continue
        end
        fprintf('save nev %s\n', fileEvent)
        save(fileEvent, 'event', 'NevTags');
    else
        % fprintf("%s exists\n", fileEvent)
    end
end
NEVtime = NEVtime / length(BRfile);
fprintf("open NEV cost %.2f seconds\n", NEVtime);
rmpath(genpath('data/NPMK-5.5.0.0'))
end