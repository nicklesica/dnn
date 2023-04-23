function vals = nn_Read_Sound_Frame(file)

n_chans = 1;

fid = fopen(file,'rb');
vals = fread(fid,'float32=>single');
vals = reshape(vals,[],n_chans);
fclose(fid);