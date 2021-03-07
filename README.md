# Progetto di Reti Logiche - 2020
Progetto di Reti Logiche 2020/2021 @Politecnico Di Milano - Image Equalizer

## Authors
* [Matteo Crugnola](https://github.com/crugio48)
* [Andrea Carotti](https://github.com/andreacarotti99)

## General Overview

The design specification of the Final Test (Logic Networks) 2020 is inspired by the method of equalization of the histogram of an image1.
The method of equalizing the histogram of an image is a method designed to recalibrate the contrast of an image when the range of intensity values are very close by distributing them over the entire intensity range, in order to increase the contrast.

<img width="722" alt="Schermata 2021-03-08 alle 00 07 50" src="https://user-images.githubusercontent.com/34317356/110258360-8fdd3300-7fa2-11eb-8d88-54b26e0c951e.png">


The version to be developed does not require the implementation of the standard algorithm but a simplified version of it. The equalization algorithm will only be applied to 256-level grayscale images and must transform each of its pixels as follows:

```
DELTA_VALUE = MAX_PIXEL_VALUE – MIN_PIXEL_VALUE
SHIFT_LEVEL = (8 – FLOOR(LOG2(DELTA_VALUE +1)))
TEMP_PIXEL = (CURRENT_PIXEL_VALUE - MIN_PIXEL_VALUE) << SHIFT_LEVEL NEW_PIXEL_VALUE = MIN( 255 , TEMP_PIXEL)
```

Where MAX_PIXEL_VALUE and MIN_PIXEL_VALUE are the maximum and minimum value of the image pixels, CURRENT_PIXEL_VALUE is the value of the pixel to be transformed, and NEW_PIXEL_VALUE is the value of the new pixel.

The module to be implemented will have to read the image from a memory in which the image to be processed is stored sequentially and line by line. Each byte corresponds to one pixel of the image.
The size of the image is defined by 2 bytes, stored starting from address 0. The byte at address 0 refers to the column size; the byte in address 1 refers to the row size. The maximum image size is 128x128 pixels.
The image is stored starting from address 2 and in contiguous bytes. So the byte at address 2 is the first pixel of the first line of the image.
The equalized image must be written into memory immediately after the original image.

## Data
The dimensions of the image, each 8 bits in size, are stored in a memory with addressing to the Byte starting from position 0: the byte in position 0 refers to the number of columns (N -COL), the byte in position 1 it refers to the number of lines (N-RIG).
The pixels of the image, each of an 8-bit, are stored in memory with addressing to the Byte starting from position 2.
The pixels of the equalized image, each of an 8 bit, are stored in memory with addressing to the Byte starting from position 2 + (N-COL * N-RIG).

#### Additional Notes
1. Note that in the module to be implemented, FLOOR (LOG2 (DELTA_VALUE +1)) is an integer with values ​​between 0 and 8 that can be easily obtained from threshold controls.
2. Pay attention to the number of bits needed in each step.
3. The module must be designed to be able to encode multiple images, but the image to be encoded will never be changed within the same run, ie before the module has signaled completion via the DONE signal. See the
next step for the re-start protocol.
4. The module will start processing when an incoming START signal comes
brought to 1. The START signal will remain high until the DONE signal is brought high; At the end of the computation (and once the result has been written into memory), the module to be designed must raise (bring to 1) the DONE signal which notifies the end of processing. The DONE signal must remain high until the START signal is reset to 0. A new start signal cannot be given until DONE has been reset to zero. If at this point the START signal is raised, the module will have to restart with the coding phase.
5. The module must be designed considering that the module will always be reset before the first coding. Instead, as described in the previous protocol, a second processing will not have to wait for the module reset.

## Component Interface
The component to be described must have the following interface:
```
entity project_reti_logiche is
     port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_start   : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector (7 downto 0)
     );
end project_reti_logiche;

```

#### Further notes
1. the module name must be project_reti_logiche
2. i_clk is the CLOCK input signal generated by the TestBench;
3. i_rst is the RESET signal that initializes the machine ready to receive the first one START signal;
4. i_start is the START signal generated by the Test Bench;
5. i_data is the signal (vector) that arrives from the memory following a request for reading;
6. o_address is the output signal (vector) that sends the address to the memory;
7. o_done is the output signal that communicates the end of processing and the output data written in memory;
8. o_en is the ENABLE signal to be sent to the memory in order to communicate (both in reading and in writing);
9. o_we is the WRITE ENABLE signal to be sent to memory (= 1) in order to be able to write to us. To read from memory it must be 0;
10. o_data is the output signal (vector) from the component to the memory.

## Input/Output Example
The following sequence of numbers shows an example of the contents of the memory at the end of a processing. The values that are represented here in decimal are stored in memory with the equivalent binary coding on 8 unsigned bits.

<img width="380" alt="Schermata 2021-03-08 alle 00 08 29" src="https://user-images.githubusercontent.com/34317356/110258352-7e942680-7fa2-11eb-87ad-d264628c23d0.png">


