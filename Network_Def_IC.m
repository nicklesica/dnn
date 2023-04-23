input_layers = [
    
imageInputLayer([pnet.frame_samps 1],'Name','in','Normalization','none')

];

switch pnet.input_layer_type
    case 'conv'
        input_layers = [input_layers
            convolution2dLayer([pnet.filter_samps 1],pnet.n_filters,'Stride',[1 1],'Padding','same','Name','incon0')
            ];
    case 'sinc'
        input_layers = [input_layers
            nn_My_SincNet_Layer(pnet.n_sincs,pnet.filter_samps,pnet.input_sampling_rate,1,'incon0')
            ];
end

switch pnet.input_act_type
    case 'tanh'
        input_layers = [input_layers
            tanhLayer('Name','inact0')
            ];
    case 'mylog'
        input_layers = [input_layers
            nn_My_Log_Layer('Name','inact0')
            ];
end

encoder_layers = [];

for i_depth = 1:pnet.encoder_depth,
    encoder_layers = [encoder_layers
        eval(sprintf('convolution2dLayer([pnet.filter_samps 1],pnet.n_filters,''Stride'',[2 1],''Padding'',''same'',''Name'',''incon%d'')',i_depth));
        eval(sprintf('preluLayer(pnet.n_filters,''inact%d'')',i_depth));
        ];
end

bottleneck_layers = [
    convolution2dLayer([pnet.filter_samps 1],pnet.n_bottleneck,'Stride',[1 1],'Padding','same','Name','bcon');
    preluLayer(pnet.n_bottleneck,'bact');
    ];

output_layers = [
    convolution2dLayer([(pnet.context_samps_1/2.^pnet.encoder_depth)+1 1],1,'Stride',[1 1],'Padding',0,'Name','dummy1','WeightLearnRateFactor',0)
    convolution2dLayer([(pnet.context_samps_2/2.^pnet.encoder_depth)+1 1],1,'Stride',[1 1],'Padding',0,'Name','dummy2','WeightLearnRateFactor',0)
    crop2dLayer([1 (pnet.context_samps_1/2.^pnet.encoder_depth)+1] ,'Name','outcrop')
    transposedConv2dLayer([1 1],numel(pnet.ix_output_chans),'Stride',[1 1],'Cropping','same','Name','outcon0');%,'BiasLearnRateFactor',0)
    ];

switch pnet.output_act_type,
    case 'relu'
        output_layers = [output_layers
            reluLayer('Name','outact0')
            ];
    case 'exp'
        output_layers = [output_layers
            nn_My_Exp_Layer('Name','outact0')
            ];
end

switch pnet.loss_type,
    case 'mse'
        output_layers = [output_layers
            regressionLayer('Name','out')
            ];
    case 'mae'
        output_layers = [output_layers
            nn_My_MAE_Regression_Layer('mae');
            ];
    case 'poisson'
        output_layers = [output_layers
            nn_My_Poisson_Loss_Layer('Poiss');
            ];
end

layers = [input_layers;encoder_layers;bottleneck_layers;output_layers]

graph = layerGraph(layers);

graph = connectLayers(graph, 'dummy2', 'outcrop/ref');
graph = disconnectLayers(graph, 'dummy2', 'outcrop/in');
graph = connectLayers(graph, 'bact', 'outcrop/in');

analyzeNetwork(graph)