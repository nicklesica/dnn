classdef nn_My_Regression_Datastore_Current < matlab.io.Datastore & ...
        matlab.io.datastore.MiniBatchable & ...
        matlab.io.datastore.Shuffleable & ...
        matlab.io.datastore.Partitionable & ...
        matlab.io.datastore.PartitionableByIndex
    
    properties
        Datastore
        MiniBatchSize
        InFrameSamps
        OutFrameSamps
        InChans
        OutChans
        InChansTot
        OutChansTot
        IXInChans
        IXOutChans
        InScales
        OutScales
        InSources
        OutSources
        Delays
    end
    
    properties(SetAccess = protected)
        NumObservations
    end
    
    properties(Access = private)
        CurrentFileIndex
    end
    
    methods
        function ds = nn_My_Regression_Datastore_Current(input_files,output_files,pars)
            
            ds.InSources = length(input_files);
            ds.OutSources = length(output_files);
            
            in_ds = fileDatastore(fileparts(input_files{1}{1}), ...
                'ReadFcn',eval(sprintf('@nn_Read_%s_Frame',pars.input_type)));
            in_ds.Files = input_files{1};
            ds.InChans(1) = size(preview(in_ds),2);
            ds.InFrameSamps = size(preview(in_ds),1);
            ds.NumObservations = length(input_files{1});
            ds.InChansTot = ds.InChans;
            
            out_ds = fileDatastore(fileparts(output_files{1}{1}), ...
                'ReadFcn',eval(sprintf('@nn_Read_%s_Frame',pars.output_type)));
            out_ds.Files = output_files{1};
            ds.OutChans(1) = size(preview(out_ds),2);
            ds.OutFrameSamps = size(preview(out_ds),1);
            ds.OutChansTot = ds.OutChans;
            
            if ds.OutSources == 1,
                out_ds = combine(out_ds);
            else
                for i_output_source = 2:ds.OutSources,
                    temp = fileDatastore(fileparts(output_files{i_output_source}{1}), ...
                        'ReadFcn',eval(sprintf('@nn_Read_%s_Frame',pars.output_type)));
                    temp.Files = output_files{i_output_source};
                    ds.OutChans(i_output_source) = size(preview(temp),2);
                    out_ds = combine(out_ds,temp);
                    ds.OutChansTot = ds.OutChansTot+size(preview(temp),2);
                end
            end
            
            ds.MiniBatchSize = pars.mini_batch_size;
            ds.CurrentFileIndex = 1;
            ds.IXInChans = pars.ix_input_chans;
            ds.IXOutChans = pars.ix_output_chans;
            ds.InScales = pars.scale_input_vals;
            ds.OutScales = pars.scale_output_vals;
            ds.Delays = pars.delay_output_vals;
            ds.Datastore = combine(in_ds,out_ds);
        end
        
        function tf = hasdata(ds)
            % tf = hasdata(ds) returns true if more data is available.
            
            tf = hasdata(ds.Datastore);
        end
        
        function [data,info] = read(ds)
            
            info = struct;
            
            input_data = zeros(ds.InFrameSamps,ds.InChansTot,ds.MiniBatchSize,'single');
            output_data = zeros(ds.OutFrameSamps,ds.OutChansTot,ds.MiniBatchSize,'single');
            
            for i_frame = 1:ds.MiniBatchSize,
                input_data(:,1:ds.InChans(1),i_frame) = read(ds.Datastore.UnderlyingDatastores{1});
            end
            
            for i_ds = 2:ds.InSources,
                
                ix_chans = sum(ds.InChans(1:i_ds-1))+1:sum(ds.InChans(1:i_ds));
                
                for i_frame = 1:ds.MiniBatchSize,
                    input_data(:,ix_chans,i_frame) = read(ds.Datastore.UnderlyingDatastores{i_ds});
                end
            end
            
            for i_frame = 1:ds.MiniBatchSize,
                output_data(:,1:ds.OutChans(1),i_frame) = read(ds.Datastore.UnderlyingDatastores{ds.InSources+1});
            end
            
            for i_ds = 2:ds.OutSources,
                
                ix_chans = sum(ds.OutChans(1:i_ds-1))+1:sum(ds.OutChans(1:i_ds));
                
                for i_frame = 1:ds.MiniBatchSize,
                    output_data(:,ix_chans,i_frame) = read(ds.Datastore.UnderlyingDatastores{ds.InSources+i_ds});
                end
            end
            
            ds.CurrentFileIndex = ds.CurrentFileIndex + ds.MiniBatchSize;
            
            % Keep only specified channels
            input_data = input_data(:,ds.IXInChans,:);
            output_data = output_data(:,ds.IXOutChans,:);
            
            % Scale
            if any(ds.InScales),
                temp = repmat(ds.InScales,[size(input_data,1) 1 size(input_data,3)]);
                input_data = input_data.*temp;
            end
            
            if any(ds.OutScales),
                temp = repmat(ds.OutScales,[size(output_data,1) 1 size(output_data,3)]);
                output_data = output_data.*temp;
            end
            
            % Convert to cell array
            input_data = permute(input_data,[1 4 2 3]);
            input_data = squeeze(num2cell(input_data,[1 2 3]));
            
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
        
        function ds2 = partitionByIndex(ds,ix)
            
            ds2 = subset(ds,ix)
            
        end
        
        function ds2 = subset(ds,ix)
            
            ds2 = copy(ds);
            ds2.Datastore = copy(ds.Datastore);
            
            ds2.NumObservations = length(ix);
            for i = 1:length(ds2.Datastore.UnderlyingDatastores)
                ds2.Datastore.UnderlyingDatastores{i}.Files = ds2.Datastore.UnderlyingDatastores{i}.Files(ix);
            end
            
        end
        
        function ds2 = shuffle(ds)
            
            ds2 = copy(ds);
            ds2.Datastore = copy(ds.Datastore);
            
            numObservations = ds2.NumObservations;
            ix = randperm(numObservations);
            
            for i = 1:length(ds2.Datastore.UnderlyingDatastores)
                ds2.Datastore.UnderlyingDatastores{i}.Files = ds2.Datastore.UnderlyingDatastores{i}.Files(ix);
            end
            
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
