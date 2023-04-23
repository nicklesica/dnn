classdef nn_My_Log_Layer < nnet.layer.Layer
    
    properties (Learnable)
        % Layer learnable parameters
            
        % Scaling coefficient
    end
    
    methods
        function layer = nn_My_Log_Layer(numChannels, name) 
            % layer = preluLayer(numChannels, name) creates a PReLU layer
            % for 2-D image input with numChannels channels and specifies 
            % the layer name.

            % Set layer name.
            layer.Name = name;

            % Set layer description.
            layer.Description = "Two-sided log layer with " + numChannels + " channels";
        
        end
        
        function Z = predict(layer, X)
            % Z = predict(layer, X) forwards the input data X through the
            % layer and outputs the result Z.
            
            Z = sign(X).*log(abs(X)+1);
        end
    end
end