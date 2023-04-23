function  [s1,loc1,s2,loc2,snr,level,trial,ext] = nn_Parse_File_Name(str);

seps = find(str=='_');
dot = find(str=='.',1);

s1 = str(1:seps(1)-1);
loc1 = str(seps(1)+1:seps(2)-1);

s2 = str(seps(2)+1:seps(3)-1);
loc2 = str(seps(3)+1:seps(4)-1);

snr = str(seps(4)+1:seps(5)-1);

if length(seps) == 6,
    
    level = str(seps(5)+1:seps(6)-1);
    
    trial = str(seps(6)+1:dot-1);
    
else
    
    if isempty(dot),
                
    level = str(seps(5)+1:end);
    
    else
        
    level = str(seps(5)+1:dot-1);
    
    end
    
    trial = '';
    
end

ext = str(dot+1:end);