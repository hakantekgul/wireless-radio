
fileID = fopen('input.txt','r');
formatSpec = '%f';
Input = fscanf(fileID,formatSpec); %Input signal is read from file
fclose(fileID);

fid = fopen ('preamble.txt','r'); %Read preamble values %
ii  = 1;

while ~feof(fid)
    pre_amble(ii, :) = str2num(fgets(fid));
    ii = ii + 1;
end
fclose(fid);

j = 1;

% Down Conversion:%
index_carrier = (0:2999)';

carriercos = cos(2*pi*20*index_carrier*0.01);
carriersin = sin(2*pi*20*index_carrier*0.01);

I = Input.* carriercos;
Q = Input.* carriersin;

% downconversion reduces the amplitude of the baseband component by 2 %
% so multiply by 2 
I = I * 2;
Q = Q * 2;

% Filter: %
I_f = fftshift(fft(I)); %get the signals in frequency domain
Q_f = fftshift(fft(Q));

% eliminate all frequencies outside the range of −5.1 to +5.1 Hz 
% by setting those frequency components to zero. 

freq = (linspace(-50,50,3000))'; %generate a 3000 frequency axis -50 to 50

for k = 1:3000
    if((freq(k) > 5.1) || (freq(k) < -5.1))
        I_f(k) = 0;
        Q_f(k) = 0;
    end
end

 %Take IFFT again to get back to time domain: %
 I_filtered = ifft(fftshift(I_f),'symmetric'); % want it to be symmetric
 Q_filtered = ifft(fftshift(Q_f),'symmetric');
     
% Downsample: %
for i = 1:10:3000
    Down_10_I(j,1) = I_filtered(i,1); 
    Down_10_Q(j,1) = Q_filtered(i,1);
    j = j+1;
end

% We are left with 300 samples of I and Q. 

% Correlate: %
z = complex(Down_10_I,Down_10_Q);
correlated = xcorr(pre_amble, z);

maximum = max(abs(correlated));

for m = 1:300
    if(abs(correlated(m,1)) == maximum)
        start_pt = m;
    end
end

%Calculate the size of the message and the starting symbol index
siz = 300 - start_pt + length(pre_amble);
start_pt_2 = start_pt - 1 - length(pre_amble);

for fi = 1:siz
    Final_Array(fi,1) = z(start_pt_2);
    start_pt_2 = start_pt_2 + 1;
end

% Demodulate: %
I_final = real(Final_Array);
Q_final = imag(Final_Array);

Message = strings(siz+1,1);


for iif = 1:siz
    if(I_final(iif) > 2 && I_final(iif) < 4 && Q_final(iif) > 2 && Q_final(iif) < 4)
        %0000
        Message(iif,1) = '0000';
    
    elseif(I_final(iif) > 0 && I_final(iif) < 2 && Q_final(iif) > 2 && Q_final(iif) < 4)
        %0001
        Message(iif,1) = '0001';
    
    elseif(I_final(iif) > -2 && I_final(iif) < 0 && Q_final(iif) > 2 && Q_final(iif) < 4)
        %0011
        Message(iif,1) = '0011';
    
    elseif(I_final(iif) > -4 && I_final(iif) < -2 && Q_final(iif) > 2 && Q_final(iif) < 4)
        %0010
        Message(iif,1) = '0010';
    
    elseif(I_final(iif) > 2 && I_final(iif) < 4 && Q_final(iif) > 0 && Q_final(iif) < 2)
        %0100
        Message(iif,1) = '0100';
    
    elseif(I_final(iif) > 0 && I_final(iif) < 2 && Q_final(iif) > 0 && Q_final(iif) < 2)
        %0101
        Message(iif,1) = '0101';
    
    elseif(I_final(iif) > -2 && I_final(iif) < 0 && Q_final(iif) > 0 && Q_final(iif) < 2)
        %0111
        Message(iif,1) = '0111';
    
    elseif(I_final(iif) > -4 && I_final(iif) < -2 && Q_final(iif) > 0 && Q_final(iif) < 2)
        %0110
        Message(iif,1) = '0110';
    
    elseif(I_final(iif) > 2 && I_final(iif) < 4 && Q_final(iif) > -2 && Q_final(iif) < 0)
        %1100
        Message(iif,1) = '1100';
    
    elseif(I_final(iif) > 0 && I_final(iif) < 2 && Q_final(iif) > -2 && Q_final(iif) < 0)
        %1101
        Message(iif,1) = '1101';
    
    elseif(I_final(iif) > -2 && I_final(iif) < 0 && Q_final(iif) > -2 && Q_final(iif) < 0)
        %1111
        Message(iif,1) = '1111';
    
    elseif(I_final(iif) > -4 && I_final(iif) < -2 && Q_final(iif) > -2 && Q_final(iif) < 0)
        %1110
        Message(iif,1) = '1110';
    
    elseif(I_final(iif) > 2 && I_final(iif) < 4 && Q_final(iif) > -4 && Q_final(iif) < -2)
        %1000
        Message(iif,1) = '1000';
    
    elseif(I_final(iif) > 0 && I_final(iif) < 2 && Q_final(iif) > -4 && Q_final(iif) < -2)
        %1001
        Message(iif,1) = '1001';
    
    elseif(I_final(iif) > -2 && I_final(iif) < 0 && Q_final(iif) > -4 && Q_final(iif) < -2)
        %1011
        Message(iif,1) = '1011';
    
    elseif(I_final(iif) > -4 && I_final(iif) < -2 && Q_final(iif) > -4 && Q_final(iif) < -2)
        %1010
        Message(iif,1) = '1010';
    end
end %Demodulate using constellation diagram

% ASCII to text: %
index = 1;
for iii = 1:2:siz    
    string = strcat(Message(iii,1),Message(iii+1,1));
    character = char(bin2dec(string));
    Characters(index,1) = character;
    index = index + 1;
end

B = cellstr(Characters);
str = strjoin(B);

fprintf('TRANSMITTED MESSAGE IS: \n');
disp(str);


%%%%%%%%%%%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%




