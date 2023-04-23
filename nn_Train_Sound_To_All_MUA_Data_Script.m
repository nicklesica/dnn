%% SET PARAMETERS
pnet.input_type = 'Sound';
pnet.output_type = 'MUA';

% pnet.output_dates = {'210311_R','210311_L','210315_R','210315_L','210316_L','210316_R'};

for i_output_date = 1:length(pnet.output_dates),
    
    %Test 2
    pnet.output_test_specs_2{1,i_output_date}.folder = fullfile(nn_frame_root,sprintf('responses/mua/timit/train/%s/mua_crop',pnet.output_dates{i_output_date}));
    pnet.output_test_specs_2{1,i_output_date} = nn_Initialize_File_Specs(pnet.output_test_specs_2{1,i_output_date});
    pnet.output_test_specs_2{1,i_output_date}.trial = '2';
    pnet.output_test_files_2{i_output_date} = nn_Get_Filtered_File_List(pnet.output_test_specs_2{1,i_output_date});
    
    pnet.input_test_specs_2{1}.folder = fullfile(nn_frame_root,'sounds/timit/train/sound');
    pnet.input_test_files_2{1} = nn_Convert_Output_Frame_List_To_Input_Frame_List(pnet.output_test_files_2{1,i_output_date},pnet.input_test_specs_2{1}.folder);
    
    %Test
    pnet.output_test_specs{1,i_output_date}.folder = fullfile(nn_frame_root,sprintf('responses/mua/timit/train/%s/mua_crop',pnet.output_dates{i_output_date}));
    pnet.output_test_specs{1,i_output_date} = nn_Initialize_File_Specs(pnet.output_test_specs{1,i_output_date});
    pnet.output_test_specs{1,i_output_date}.trial = '1';
    pnet.output_test_files{i_output_date} = nn_Change_Trial_In_Frame_List(pnet.output_test_files_2{i_output_date},'2','1');
    
    pnet.input_test_specs{1}.folder = fullfile(nn_frame_root,'sounds/timit/train/sound');
    pnet.input_test_files{1} = nn_Convert_Output_Frame_List_To_Input_Frame_List(pnet.output_test_files{1,i_output_date},pnet.input_test_specs{1}.folder);
    
    % Train
    pnet.output_train_specs{1,i_output_date}.folder = fullfile(nn_frame_root,sprintf('responses/mua/timit/train/%s/mua_crop',pnet.output_dates{i_output_date}));
    pnet.output_train_specs{1,i_output_date} = nn_Initialize_File_Specs(pnet.output_train_specs{1,i_output_date});
    pnet.output_train_specs{1,i_output_date}.trial = '1';
    pnet.output_train_files{i_output_date} = nn_Get_Filtered_File_List(pnet.output_train_specs{1,i_output_date});
    
    pnet.input_train_specs{1}.folder = fullfile(nn_frame_root,'sounds/timit/train/sound');
    pnet.input_train_files{1} = nn_Convert_Output_Frame_List_To_Input_Frame_List(pnet.output_train_files{1,i_output_date},pnet.input_train_specs{1}.folder);
    
    pnet.output_train_specs{2,i_output_date}.folder = fullfile(nn_frame_root,sprintf('responses/mua/timit/test/%s/mua_crop',pnet.output_dates{i_output_date}));
    pnet.output_train_specs{2,i_output_date} = nn_Initialize_File_Specs(pnet.output_train_specs{2,i_output_date});
    pnet.output_train_specs{2,i_output_date}.trial = '1';
    these_output_files = nn_Get_Filtered_File_List(pnet.output_train_specs{2,i_output_date});
    
    pnet.input_train_specs{2}.folder = fullfile(nn_frame_root,'sounds/timit/test/sound');
    these_input_files = nn_Convert_Output_Frame_List_To_Input_Frame_List(these_output_files,pnet.input_train_specs{2}.folder);
    
    pnet.output_train_files{i_output_date} = [pnet.output_train_files{i_output_date}; these_output_files];
    pnet.input_train_files{1} = [pnet.input_train_files{1}; these_input_files];
    
    % Exclude anything in Test from Train
    [~,test_names] = fileparts(pnet.output_test_files{i_output_date});
    [~,train_names] = fileparts(pnet.output_train_files{i_output_date});
    ix = ~ismember(train_names,unique(test_names));
    pnet.input_train_files{1} = pnet.input_train_files{1}(ix);
    pnet.output_train_files{i_output_date} = pnet.output_train_files{i_output_date}(ix);
    
    % Double check that there is no overlap between Test from Train
    [~,test_names] = fileparts(pnet.output_test_files{i_output_date});
    [~,test_names_2] = fileparts(pnet.output_test_files_2{i_output_date});
    [~,train_names] = fileparts(pnet.output_train_files{i_output_date});
    
    if any(ismember(test_names,train_names)) | any(ismember(test_names_2,train_names)),
        keyboard
    end
    
end

pnet.n_input_chans = 0;
for i = 1:length(pnet.input_train_files),
    temp = eval(sprintf('nn_Read_%s_Frame(pnet.input_train_files{i}{1});',pnet.input_type));
    pnet.n_input_chans = pnet.n_input_chans + size(temp,2);
end
if ~isfield(pnet,'ix_input_chans'),
    pnet.ix_input_chans = 1:pnet.n_input_chans;
end

pnet.n_output_chans = 0;
for i = 1:length(pnet.output_train_files),
    temp = eval(sprintf('nn_Read_%s_Frame(pnet.output_train_files{i}{1});',pnet.output_type));
    pnet.n_output_chans = pnet.n_output_chans + size(temp,2);
end
if ~isfield(pnet,'ix_output_chans'),
    pnet.ix_output_chans = 1:pnet.n_output_chans;
end