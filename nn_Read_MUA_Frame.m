function vals = nn_Read_MUA_Frame(file)

n_chans = 256;

fid = fopen(file,'rb');
vals = fread(fid,'uint8=>single');
vals = reshape(vals,[],n_chans);
fclose(fid);