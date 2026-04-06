# Heilmeier Questions: Hardware Acceleration for CNN Layers

**1. What are you trying to do? Articulate your objectives using absolutely no jargon.**
I am trying to design a specialized, custom computer chip that is built exclusively to do the math required for artificial intelligence to "see" and recognize images. Instead of using a normal computer brain that can do a little bit of everything, I want to build a highly efficient engine that does only one specific type of math extremely fast.

**2. How is it done today, and what are the limits of current practice?**
Today, this image-recognition math is usually run on standard computer processors (CPUs) or graphics cards (GPUs). While these are powerful, they are general-purpose machines. The major limit of current practice is that these chips waste a massive amount of time and battery power just moving data back and forth from their memory. They are not perfectly optimized for the highly repetitive math required by image processing.

**3. What is new in your approach and why do you think it will be successful?**
My approach focuses on building a dedicated hardware unit (a co-processor) that specifically accelerates the "Multiply-Accumulate" (MAC) operations that dominate Convolutional Neural Networks. By designing a custom data flow (such as a weight-stationary architecture), I can minimize how often the chip has to fetch data from memory. I believe this will be successful because stripping away the overhead of a general-purpose CPU allows this custom hardware to process the specific CNN algorithm much faster and with significantly less power.