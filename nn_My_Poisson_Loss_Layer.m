classdef nn_My_Poisson_Loss_Layer < nnet.layer.RegressionLayer
    % Example custom regression layer with mean-absolute-error loss.
    
    methods
        function layer = nn_My_Poisson_Loss_Layer(name)
            % layer = maeRegressionLayer(name) creates a
            % mean-absolute-error regression layer and specifies the layer
            % name.
			
            % Set layer name.
            layer.Name = name;

            % Set layer description.
            layer.Description = 'Poisson loss';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % loss = forwardLoss(layer, Y, T) returns the MAE loss between
            % the predictions Y and the training targets T.
            
            % Calculate Poisson loss.
            loss = mean(Y(:)-T(:).*log(Y(:)));
    
        end
    end
end