function frame_list = nn_Change_Trial_In_Frame_List(frame_list,old,new)

frame_list = strrep(frame_list,sprintf('_%s.',old),sprintf('_%s.',new));