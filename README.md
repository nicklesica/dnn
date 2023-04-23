# dnn

This archive contains the Matlab code used to train the deep neural network models described in Sabesan et al., 2023.

It was run in the following Matlab envronment:

MATLAB                                                Version 9.10        (R2021a)
Audio Toolbox                                         Version 3.0         (R2021a)
Computer Vision Toolbox                               Version 10.0        (R2021a)
Curve Fitting Toolbox                                 Version 3.5.13      (R2021a)
DSP System Toolbox                                    Version 9.12        (R2021a)
Deep Learning Toolbox                                 Version 14.2        (R2021a)
GPU Coder                                             Version 2.1         (R2021a)
Image Processing Toolbox                              Version 11.3        (R2021a)
MATLAB Coder                                          Version 5.2         (R2021a)
MATLAB Compiler                                       Version 8.2         (R2021a)
MATLAB Compiler SDK                                   Version 6.10        (R2021a)
MATLAB Report Generator                               Version 5.10        (R2021a)
Mapping Toolbox                                       Version 5.1         (R2021a)
Optimization Toolbox                                  Version 9.1         (R2021a)
Parallel Computing Toolbox                            Version 7.4         (R2021a)
Signal Processing Toolbox                             Version 8.6         (R2021a)
Statistics and Machine Learning Toolbox               Version 12.1        (R2021a)
System Identification Toolbox                         Version 9.14        (R2021a)

with the following GPU settings:

  CUDADevice with properties:

                      Name: 'GeForce GTX 1080 Ti'
                     Index: 1
         ComputeCapability: '6.1'
            SupportsDouble: 1
             DriverVersion: 11.1000
            ToolkitVersion: 11
        MaxThreadsPerBlock: 1024
          MaxShmemPerBlock: 49152
        MaxThreadBlockSize: [1024 1024 64]
               MaxGridSize: [2.1475e+09 65535 65535]
                 SIMDWidth: 32
               TotalMemory: 1.1811e+10
           AvailableMemory: 1.0384e+10
       MultiprocessorCount: 28
              ClockRateKHz: 1582000
               ComputeMode: 'Default'
      GPUOverlapsTransfers: 1
    KernelExecutionTimeout: 1
          CanMapHostMemory: 1
           DeviceSupported: 1
           DeviceAvailable: 1
            DeviceSelected: 1

The file Example_Training_Script.m illustrates how to define and train a model.

The script can be run using the dataset in Ex_Frames_Zip on figshare at DOI:10.6084/m9.figshare.22651816. The variable nn_frame_root at the top of Example_Training_Script should be set to the location of the unzipped dataset. No other changes should be needed for Example_Training_Script to run.

The script will create a model:

layers = 

  21×1 Layer array with layers:

     1   'in'        Image Input              8192×1×1 images
     2   'incon0'    nn_My_SincNet_Layer      Sinc Layer with 48 filters
     3   'inact0'    nn_My_Log_Layer          Two-sided log layer with Name channels
     4   'incon1'    Convolution              128 32×1 convolutions with stride [2  1] and padding 'same'
     5   'inact1'    preluLayer               PReLU with 128 channels
     6   'incon2'    Convolution              128 32×1 convolutions with stride [2  1] and padding 'same'
     7   'inact2'    preluLayer               PReLU with 128 channels
     8   'incon3'    Convolution              128 32×1 convolutions with stride [2  1] and padding 'same'
     9   'inact3'    preluLayer               PReLU with 128 channels
    10   'incon4'    Convolution              128 32×1 convolutions with stride [2  1] and padding 'same'
    11   'inact4'    preluLayer               PReLU with 128 channels
    12   'incon5'    Convolution              128 32×1 convolutions with stride [2  1] and padding 'same'
    13   'inact5'    preluLayer               PReLU with 128 channels
    14   'bcon'      Convolution              8 32×1 convolutions with stride [1  1] and padding 'same'
    15   'bact'      preluLayer               PReLU with 8 channels
    16   'dummy1'    Convolution              1 33×1 convolutions with stride [1  1] and padding [0  0  0  0]
    17   'dummy2'    Convolution              1 33×1 convolutions with stride [1  1] and padding [0  0  0  0]
    18   'outcrop'   Crop 2D                  upper-left corner of cropping rectangle at [1 33]
    19   'outcon0'   Transposed Convolution   340 1×1 transposed convolutions with stride [1  1] and cropping 'same'
    20   'outact0'   nn_My_Exp_Layer          Exponential layer with Name channels
    21   'Poiss'     Regression Output        Poisson loss

and then train it on the dataset:

![image](https://user-images.githubusercontent.com/24247741/233834204-99047896-e925-4824-b9b8-e9fd67fe14ac.png)

and then finally plot the model output for a test input:

![image](https://user-images.githubusercontent.com/24247741/233834002-9acbb67e-a2d9-4494-8011-e64a060f4f92.png)

Note that the example dataset is very small. It is not meant to produce a good model but rather to illustrate how this code can be used to train models on other datasets.




  





