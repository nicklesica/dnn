classdef nn_Sound_To_MUA_Datastore < matlab.io.Datastore & ...
        matlab.io.datastore.MiniBatchable & ...
        matlab.io.datastore.Shuffleable & ...
        matlab.io.datastore.Partitionable
    
    properties
        Datastore
        MiniBatchSize
        FrameSamps
        ContextSamps
        NChans
        IXChans
        Scales
        Delays
    end
    
    properties(SetAccess = protected)
        NumObservations
    end
    
    properties(Access = private)
        CurrentFileIndex
    end
    
    methods
        function ds = nn_Sound_To_MUA_Datastore(input_folder,output_folder,pars)
            
            % pars: context_samps, ix_chans, scales, delays
            
            % Create file datastore.
            an_ds = fileDatastore(output_folder, ...
                'ReadFcn',@nn_Read_MUA_Frame,'FileExtensions','.frame');
            
            ds.NumObservations = numel(an_ds.Files);
            ds.MiniBatchSize = 128;
            ds.CurrentFileIndex = 1;
            ds.FrameSamps = size(preview(an_ds),1);
            ds.ContextSamps1 = pars.context_samps_1;
            ds.ContextSamps2 = pars.context_samps_2;
            ds.NChans = size(preview(an_ds),2);
            ds.IXChans = pars.ix_chans;
            ds.Scales = pars.scale_output_vals;
            ds.Delays = pars.delay_output_vals;
            
            sound_ds = fileDatastore(input_folder, ...
                'ReadFcn',@nn_Read_Sound_Frame,'FileExtensions','.frame');
            
            ds.Datastore = combine(sound_ds,an_ds);
        end
        
        function tf = hasdata(ds)
            % tf = hasdata(ds) returns true if more data is available.
            
            tf = hasdata(ds.Datastore);
        end
        
        function [data,info] = read(ds)
            
            info = struct;
            
            
            input_data = zeros(ds.FrameSamps,1,ds.MiniBatchSize,'single');
            
            for i_frame = 1:ds.MiniBatchSize,
                input_data(:,:,i_frame) = read(ds.Datastore.UnderlyingDatastores{1});
            end
            
            output_data = zeros(ds.FrameSamps,ds.NChans,ds.MiniBatchSize,'single');
            
            for i_frame = 1:ds.MiniBatchSize,
                output_data(:,:,i_frame) = read(ds.Datastore.UnderlyingDatastores{2});
            end
            
            ds.CurrentFileIndex = ds.CurrentFileIndex + ds.MiniBatchSize;
            
            % Keep only specified channels
            output_data = output_data(:,ds.IXChans,:);
            
            % Shift to compensate for time delays
            to_delay = find(ds.Delays);
            
            for i_chan = 1:length(to_delay),
                output_data(:,to_delay(i_chan),:) = ...
                    circshift(output_data(:,to_delay(i_chan),:),-ds.Delays(to_delay(i_chan)),1);
            end
            
            % Crop context samples
            output_data = output_data(ds.ContextSamps1+1:end-ds.ContextSamps2,:,:);
            
            % Scale
            if any(ds.Scales),
                temp = repmat(ds.Scales,[size(output_data,1) 1 size(output_data,3)]);
                output_data = output_data.*temp;
            end
            
            % Convert to cell array
            input_data = squeeze(num2cell(input_data,[1 2]));
            output_data = permute(output_data,[1 4 2 3]);
            output_data = squeeze(num2cell(output_data,[1 2 3]));
            data = table(input_data,output_data);
            
        end
        
        function reset(ds)
            
            reset(ds.Datastore);
            ds.CurrentFileIndex = 1;
            
        end
        
        function ds2 = partition(ds,n,ix)
            
            ds2 = copy(ds);
            ds2.Datastore = partition(ds.Datastore,n,ix);
            ds2.NumObservations = numel(ds2.Datastore.UnderlyingDatastores{1}.Files);
            
        end
        
        function ds2 = subset(ds,ix)
            
            ds2 = copy(ds);
            ds2.Datastore = copy(ds.Datastore);
            
            ds2.NumObservations = length(ix);
            ds2.Datastore.UnderlyingDatastores{1}.Files = ds2.Datastore.UnderlyingDatastores{1}.Files(ix);
            ds2.Datastore.UnderlyingDatastores{2}.Files = ds2.Datastore.UnderlyingDatastores{2}.Files(ix);
            
        end
        
        function ds2 = shuffle(ds)
            
            ds2 = copy(ds);
            ds2.Datastore = copy(ds.Datastore);
            
            numObservations = ds2.NumObservations;
            ix = randperm(numObservations);
            ds2.Datastore.UnderlyingDatastores{1}.Files = ds2.Datastore.UnderlyingDatastores{1}.Files(ix);
            ds2.Datastore.UnderlyingDatastores{2}.Files = ds2.Datastore.UnderlyingDatastores{2}.Files(ix);
            
        end
    end
    
    methods (Hidden = true)
        function frac = progress(ds)
            % frac = progress(ds) returns the percentage of observations
            % read in the datastore.
            
            frac = (ds.CurrentFileIndex - 1) / ds.NumObservations;
        end
    end
    
    methods(Access = protected)
        function n = maxpartitions(ds)
            n = ds.NumObservations;
        end
    end
end
