function [folder_list, folder_order] = orderFolder(folders)
    % order folders by date in folder name
    % Arg:
    %   folders: folders to sort
    %   "omegaL-01-Dec-2020-1"
    %   dStart, dEnd: start and end index of date in folder name
    %   2,4
    % Out:
    %   folder_list: sorted folders
    %   folder_order: the order of sorted folders

    %% sort by date
    char_i = split(folders,'-');
    if length(char_i(1,:)) > 1
        char = join(char_i(:,2:4),'-');
    else
        char = join(char_i(2:4),'-');
    end
    char = datetime(char,'InputFormat','dd-MMM-yyyy','Locale','en_US');
    [~, I] = sortrows(char); % sort folders by current_round and used_trial
    folder_list = folders(I);
    folder_order = I;
end