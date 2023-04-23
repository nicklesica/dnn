function file_list = nn_Get_Filtered_File_List(in)

file_dir = in.folder;
s1 = in.s1;
loc1 = in.loc1;
s2 = in.s2;
loc2 = in.loc2;
snr = in.snr;
level = in.level;
trial = in.trial;

if isempty(trial),
    
    temp = dir(fullfile(file_dir,sprintf('%s_%s_%s_%s_%s_%s.*',s1,loc1,s2,loc2,snr,level)));
    
else
    
    temp = dir(fullfile(file_dir,sprintf('%s_%s_%s_%s_%s_%s_%s.*',s1,loc1,s2,loc2,snr,level,trial)));
    
end

file_list = extractfield(temp,'name')';

file_dir(end+1) = '\';

file_list = cellfun(@strcat,repmat({file_dir},size(file_list)),file_list,'UniformOutput',false);