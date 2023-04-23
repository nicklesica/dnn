pnet.name = 'S2MUA_';
pnet.name = strcat(pnet.name,sprintf('%1.0f',clock));
pnet.name(end+1:end+2) = '_1';

pnet.frame_samps = 8192;
pnet.context_samps_1 = 1024;
pnet.context_samps_2 = 1024;
pnet.middle_samps = pnet.frame_samps - (pnet.context_samps_1+pnet.context_samps_2);

pnet.input_sampling_rate = 24414.0625;
pnet.output_sampling_rate = 24414.0625/32;
pnet.output_samps = pnet.middle_samps*(pnet.output_sampling_rate/pnet.input_sampling_rate);

pnet.filter_samps = 32;
pnet.n_filters = 128;
pnet.n_sincs = 48;
pnet.input_layer_type = 'sinc';
pnet.input_act_type = 'mylog';
pnet.encoder_depth = 5;
pnet.n_bottleneck = 32;
pnet.output_act_type = 'exp';
pnet.loss_type = 'poisson';

