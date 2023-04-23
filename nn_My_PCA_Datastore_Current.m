classdef nn_My_PCA_Datastore_Current < matlab.io.Datastore & ...    
        matlab.io.datastore.Partitionable
    
    properties
        Datastore
        OutFrameSamps
        OutChans
        OutChansTot
        IXOutChans
        OutScales
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
        function ds = nn_My_PCA_Datastore_Current(output_files,pars)
            
            ds.OutSources = length(output_files);
            
            out_ds = fileDatastore(fileparts(output_files{1}{1}), ...
                'ReadFcn',eval(sprintf('@nn_Read_%s_Frame',pars.output_type)));
            out_ds.Files = output_files{1};
            ds.OutChans(1) = size(preview(out_ds),2);
            ds.OutFrameSamps = size(preview(out_ds),1);
            ds.OutChansTot = ds.OutChans;
            ds.NumObservations = length(output_files{1});
            
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
            
            ds.CurrentFileIndex = 1;
            ds.IXOutChans = pars.ix_output_chans;
            ds.OutScales = pars.scale_output_vals;
            ds.Delays = pars.delay_output_vals;
            ds.Datastore = out_ds;
        end
        
        function tf = hasdata(ds)
            % tf = hasdata(ds) returns true if more data is available.
            
            tf = hasdata(ds.Datastore);
        end
        
        function [data,info] = read(ds)
            
            info = struct;
            
            output_data = zeros(ds.OutFrameSamps,ds.OutChansTot,'single');
            
            output_data(:,1:ds.OutChans(1)) = read(ds.Datastore.UnderlyingDatastores{1});
            
            for i_ds = 2:ds.OutSources,
                
                ix_chans = sum(ds.OutChans(1:i_ds-1))+1:sum(ds.OutChans(1:i_ds));
                
                output_data(:,ix_chans) = read(ds.Datastore.UnderlyingDatastores{i_ds});
            end
            
            ds.CurrentFileIndex = ds.CurrentFileIndex + 1;
            
            % Keep only specified channels
            output_data = output_data(:,ds.IXOutChans,:);
            
            % Scale
            if any(ds.OutScales),
                temp = repmat(ds.OutScales,[size(output_data,1) 1 size(output_data,3)]);
                output_data = output_data.*temp;
            end
            
            data = output_data;
            
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
