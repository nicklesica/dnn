function out = nn_Get_Pred_From_Datastore(ds,net,ix,layer,do_reshape);

if nargin < 5,
    do_reshape = 1;
end

temp = copy(ds);
sub_ds = subset(temp,ix);
reset(sub_ds);

if nargin < 4,
    out = predict(net,sub_ds);
else
    out = activations(net,sub_ds,layer);
end

if do_reshape,
    out = reshape(permute(out,[1 4 3 2]),[],size(out,3));
end
