nn_net_root = './Models';
nn_frame_root = './Ex_Frames';

clear pnet options

pnet.output_dates = {
    '210311_L','210311_R'
    };

pnet.data_script = 'Data_Def_IC';
pnet.param_script = 'Network_Params_IC';
pnet.arch_script = 'Network_Def_IC';

% TRAINING
pnet.n_epochs = 10;
pnet.mini_batch_size = 64;
pnet.init_learn = 1e-4;

% SCALE
pnet.scale_input = 0;
pnet.scale_input_vals = 0;
pnet.scale_output = 0;
pnet.scale_output_vals = 0;
pnet.n_scale = 1000;

% DELAY
pnet.delay_output = 0;
pnet.delay_output_vals = 0;
pnet.n_delay = 1000;

% GOOD CHANNEL CRITERION
pnet.good_cc = sqrt(0.05);

% SETUP INPUT AND OUTPUT
eval(pnet.data_script)

% IDENTIFY GOOD CHANNELS
if pnet.good_cc,
    
    clear cc_trials
    
    test_ds = nn_My_PCA_Datastore_Current(pnet.output_test_files,pnet);
    test_ds_2 = nn_My_PCA_Datastore_Current(pnet.output_test_files_2,pnet);
    
    reset(test_ds);
    test = tall(test_ds);
    test = gather(test);
    
    reset(test_ds_2);
    test_2 = tall(test_ds_2);
    test_2 = gather(test_2);
    
    for i_chan = 1:size(test,2),
        cc_trials(i_chan) = corr(test(:,i_chan),test_2(:,i_chan));
    end
    
    pnet.ix_output_chans = find(cc_trials>pnet.good_cc);
    
    clear test_ds test_ds_2 test test_2
    
end

% SETUP DATASTORES
clear train_ds test_ds test_ds_2
train_ds = nn_My_Regression_Datastore_Current(pnet.input_train_files,pnet.output_train_files,pnet);
test_ds = nn_My_Regression_Datastore_Current(pnet.input_test_files,pnet.output_test_files,pnet);
test_ds_2 = nn_My_Regression_Datastore_Current(pnet.input_test_files_2,pnet.output_test_files_2,pnet);

% SETUP NETWORK
eval(pnet.param_script)

n_bottleneck = 8;

pnet.n_bottleneck = n_bottleneck;
pnet.name = sprintf('%s_test',pnet.output_dates{1}(1:6));

eval(pnet.arch_script)

pnet.check_dir = fullfile(nn_net_root,pnet.name);
mkdir(pnet.check_dir)

options = trainingOptions("adam", ...
    "MaxEpochs",pnet.n_epochs, ...
    "InitialLearnRate",pnet.init_learn,...
    "MiniBatchSize",pnet.mini_batch_size, ...
    "Shuffle","every-epoch", ...
    "Verbose",1, ...
    "CheckpointPath",pnet.check_dir);

save(fullfile(pnet.check_dir,'Parameters'),'pnet');

reset(gpuDevice(1))
net = trainNetwork(train_ds,graph,options);

mua = nn_Predict_Response_From_Datastore(test_ds,net,1:100);

figure
plot(mua(1:1000,:))

