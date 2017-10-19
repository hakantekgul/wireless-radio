# wireless-radio
A basic wireless receiver system that detects any transmitted text message. 
Input is a 3000 sample long incoming signal at the antenna at 100Hz.
Following steps are implemented to decode the message:
1. Downconvert
2. Filter
3. Downsample
4. Correlate 
5. Demodulate (16 QAM)
6. ASCII to text

Executing the receiver with an input file and a preamble for correlation: 
1. Make sure input.txt and preamble.txt are available in path. 
2. Run src file in MATLAB and add the file to the MATLAB path if necessary. 
3. After running the code, you can see the transmitted message in the Command Window below in the format as follows: 

TRANSMITTED MESSAGE IS: 
blah blah blah

4. Use a spell checker to do error correction or use your common sense. 
5. Any 3000 input signal and any preamble should work with the code submitted with files input.txt and pre_amble.txt. 
