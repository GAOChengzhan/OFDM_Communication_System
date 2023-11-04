# OFDM_Communication_System

OFDM is a mainstream PHY-layer technology widely adopted by modern wireless networks (e.g., WiFi and LTE). In this repo, an OFDM communication system in Matlab is implemented. The system represents a simplified version of the WiFi (802.11) PHY layer, which involves packet construction at the transmitter side, and packet
detection, synchronization and decoding at the receiver side. 

## (1) Packet construction and OFDM modulation.
#### Step (a) BPSK modulation: 
Create a packet represented by a vector of random bits {0,1,1,0,1…}. The vector contains 4800 bits. Convert the digital bits into BPSK symbols (1+0*j or -1+0*j), and then group the BPSK symbols into 802.11 OFDM symbols. 

<img width="700" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/0818d158-cb93-4660-a8ab-762c4a762a7a">


#### Step (b) OFDM modulation: 
Modulate each OFDM symbol using 64-point IFFT, and add a 16-sample cyclic prefix to it.
Ref: IEEE 802.11-2007, Section 17.3.5.9. 
#### Step (c) Add STF and LTF preambles to each data packet
Follow Sec. 17.3.3 of IEEE 802.11-2007. 

**The magnitude of samples in the resulting STF**

<img width="650" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/c8271da2-56a0-41ef-b9d0-5bba90b7012b">

**The power spectrum density of the OFDM data symbols**

<img width="650" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/41d028d0-a69b-464d-a5cd-4e9c545707e4">

## (2) Packet transmission and channel distortion
After the above steps, the packet is modulated into a sequence of samples (complex numbers). A number of (e.g., 100) zero samples is added before the packet, to represent the idle period before the actual transmission happens. Suppose the packet is sent through a simplified wireless channel, with the following distortion effects:

(i) Magnitude distortion: the channel attenuates the magnitude of each sample to 10^-5 of the original

(ii) The channel shifts the phase of each sample by -3pi/4, i.e., multiplying it by exp(-j*3pi/4)

(iii) The imperfect radio hardware causes a frequency offset between the transmitter and receiver. This offset causes the receiver's phase to drift from the transmitter's phase. Suppose the phase drift is exp(-j * 2 * pi * 0.00017) per sample, i.e., for the kth sample, the phase drift is exp(-j * 2 * pi * 0.00017 * k)

(iv) Channel noise. For each sample, a Gaussian random number (mean 0 and variance 10^-14) is added to represent channel noise.

**The magnitude of samples in the packet’s STF, after the channel distortion effects:**

<img width="650" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/67d82983-2f6e-4b56-8c7b-ec77208f7fa6">

## (3) Packet detection
The channel-distorted samples are what the receiver actually receives. But the receiver actually needs the packets and the bits therein. So how does a receiver know a packet arrives? The answer is using a self-correlation algorithm to detect the presence of the STF, thus identifying the arrival of a packet. So, implement the self-correlation-based algorithm to detect packets. 

**The self-correlation results as a function of sample index**

<img width="650" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/7292c176-6bc3-49ce-8f6a-f47bfee72578">


The indexes of the samples where packets are detected range from 101 to 260.

## (4) Packet synchronization
Packet detection does not tell us the exact starting time of a packet. But since the STF sequence is known to the receiver, a cross-correlation algorithm can be used to single out the first sample of the STF, thus achieving synchronization between receiver and transmitter. So, the cross-correlation algorithm is implemented for synchronization, again using the channel-distorted sequence of samples as input. 

**The cross-correlation results, as a function of sample index**
<img width="650" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/1c45f20a-1d48-430f-ac05-7623d4ed7146">


Indices of samples corresponding to the STF starting time, for each packet: 101   117   133   149   165   181   197   213   229   245. 

## (5) Channel estimation and packet decoding
Ref: Chapter 6 of the MS thesis “SOFTWARE DEFINED RADIO (SDR) BASED IMPLEMENTATION OF IEEE 802.11 WLAN BASEBAND PROTOCOLS” 

Step (a) 
After synchronization, the receiver knows the exact starting time of the LTF as well. Leverage the LTF to estimate the frequency offset between the transmitter and receiver.

**The frequency offset between the transmitter and receiver: 0.000170**

Step (b) 
The receiver knows the sequence of samples in LTF, so it can estimate the channel magnitude/phase distortion to each sample (corresponding to each subcarrier in an OFDM
symbol). 

**The channel distortion to each subcarrier:**

<img width="700" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/815ac974-f3e6-4d7a-9b42-c287690495e3">


Step (c) Decode the digital information in each OFDM data symbol. 

First, as the receiver knows the starting time of each OFDM data symbol, it can run FFT over each OFDM symbol and convert it into a number of (64) subcarriers. 

Then, it can recover the original BPSK symbols by reverting the channel distortion (We assume the channel is stable over an entire packet. So the OFDM symbols suffer from the same channel distortion as the LTF). 

Finally, it can demap the BPSK symbols to {0,1} information bits and convert the bits into characters. Now the receiver fully recovers the sequence of bits sent by the transmitter! 

<img width="700" alt="image" src="https://github.com/GAOChengzhan/OFDM_Communication_System/assets/39005000/37196684-135c-4e85-b6a8-3a39b2e74f0b">
