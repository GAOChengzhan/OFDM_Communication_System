# OFDM_Communication_System

OFDM is a mainstream PHY-layer technology widely adopted by modern wireless networks (e.g., WiFi and LTE). In this repo, an OFDM communication system in Matlab is implemented. The system represents a simplified version of the WiFi (802.11) PHY layer, which involves packet construction at the transmitter side, and packet
detection, synchronization and decoding at the receiver side. 

## (1) Packet construction and OFDM modulation.
#### Step (a) BPSK modulation: 
Created a packet represented by a vector of random bits {0,1,1,0,1…}. The vector contains 4800 bits. Converted the digital bits into BPSK symbols (1+0*j or -1+0*j), and then grouped the BPSK symbols into 802.11 OFDM symbols. 
#### Step (b) OFDM modulation: 
Modulated each OFDM symbol using 64-point IFFT, and added a 16-sample cyclic prefix to it.
Ref: IEEE 802.11-2007, Section 17.3.5.9. 
#### Step (c) Add STF and LTF preambles to each data packet
Followed Sec. 17.3.3 of IEEE 802.11-2007. 

**The magnitude of samples in the resulting STF**
![Magnitude_Samples_SFT](https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/cf7d29bd-3623-4d88-a5fd-5b8de52d8246)

**The power spectrum density of the OFDM data symbols**
![Power_Spectrum_Density](https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/17274768-4bc5-4905-8a46-da778b9beb07)


## (2) Packet transmission and channel distortion
After the above steps, the packet was modulated into a sequence of samples (complex numbers). A number of (e.g., 100) zero samples was added before the packet, to represent the idle period before the actual transmission happens. Suppose the packet was sent through a simplified wireless channel, with the following distortion effects:

(i) Magnitude distortion: the channel attenuates the magnitude of each sample to 10^-5 of the original

(ii) The channel shifted the phase of each sample by -3pi/4, i.e., multiplying it by exp(-j*3pi/4)

(iii) The imperfect radio hardware caused a frequency offset between transmitter and receiver. This offset caused the receiver's phase to drift from the transmitter's phase. Suppose the phase drift was exp(-j * 2 * pi * 0.00017) per sample, i.e., for the kth sample, the phase drift is exp(-j * 2 * pi * 0.00017 * k)

(iv) Channel noise. For each sample, a Gaussian random number (mean 0 and variance 10^-14) was added to represent channel noise.

**The magnitude of samples in the packet’s STF, after the channel distortion effects:**
![STF_Magnitudes_PostDistortion](https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/c49e68af-ce4d-438b-81ee-f312729f4a5f)


## (3) Packet detection
The channel-distorted samples are what the receiver actually receives. But the receiver actually
needs the packets and the bits therein. So how does a receiver know a packet arrives? Recall in
lecture 5 we discussed about using self-correlation algorithm to detect the presence of the STF,
thus identifying the arrival of a packet. Now, implement the self-correlation based algorithm to
detect packets. Test your packet detection algorithm using the channel-distorted sequence of
samples as input. Plot the self-correlation results as a function of sample index. Write down the
indexes of the samples where packets are detected.
(4) Packet synchronization
Packet detection does not tell us the exact starting time of a packet. But since the STF sequence
is known to the receiver, a cross-correlation algorithm can be used to single out the first sample
of the STF, thus achieving synchronization between receiver and transmitter. Now, implement
the cross-correlation algorithm for synchronization, again using the channel distorted sequence
of samples as input. Plot the cross-correlation results, as a function of sample index. Print the
indices of samples corresponding to the STF starting time, for each packet.
(5) Channel estimation and packet decoding
Ref: Chapter 6 of the MS thesis “SOFTWARE DEFINED RADIO (SDR) BASED
IMPLEMENTATION OF IEEE 802.11 WLAN BASEBAND PROTOCOLS” (supplementary
material for Lecture 06)
Step (a) After synchronization, the receiver knows the exact starting time of the LTF as well.
Now, leverage the LTF to estimate the frequency offset between the transmitter and receiver, and
print the result.
Step (b) The receiver knows the sequence of samples in LTF, so it can estimate the channel
magnitude/phase distortion to each sample (corresponding to each subcarrier in an OFDM
symbol). Implement the estimation algorithm. Print the channel distortion to each subcarrier.
Step (c) Now, decode the digital information in each OFDM data symbol. First, as the receiver
knows the starting time of each OFDM data symbol, it can run FFT over each OFDM symbol
and convert it into a number of (64) subcarriers. Then, it can recover the original BPSK symbols
by reverting the channel distortion (We assume the channel is stable over an entire packet. So the
OFDM symbols suffer from the same channel distortion as the LTF). Finally, it can demap the
BPSK symbols to {0,1} information bits and convert the bits into characters. Now the receiver
fully recovers the sequence of bits sent by the transmitter! Print out the resulting characters and
check if they are the same as what was sent by the transmitter.
