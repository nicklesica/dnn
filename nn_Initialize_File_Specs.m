function specs = nn_Initialize_File_Specs(specs)

if ~isfield(specs,'s1'),
    specs.s1 = '*';
    specs.loc1 = '*';
    specs.s2 = '*';
    specs.loc2 = '*';
    specs.snr = '*';
    specs.level = '*';
    specs.trial = '';
end


