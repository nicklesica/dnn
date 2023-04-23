function frame_list = nn_Convert_Output_Frame_List_To_Input_Frame_List(frame_list,input_frame_dir)

[~,names,exts] = fileparts(frame_list);

input_frame_dir(end+1) = '\';

frame_list = strcat(input_frame_dir,names);
frame_list = strcat(frame_list,exts);

ix = find(frame_list{1}=='.',2,'last');
to_erase = frame_list{1}(ix(1):ix(2)-1);
frame_list = erase(frame_list,to_erase);

to_erase = '_1.';
frame_list = strrep(frame_list,to_erase,'.');

to_erase = '_2.';
frame_list = strrep(frame_list,to_erase,'.');
