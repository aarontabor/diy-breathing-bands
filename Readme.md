# Exploring DIY Breathing Bands

This projects explores the capabilities of "do-it-yourself" breath sensing bands created from commodity electronics and materials. Design-focused research has proposed the use of this form of breath sensing in applications ranging from mediation and mindfulness exercises to athletic and performance focused training. However, the sensing capabilities of DIY sensing bands is not well understood, so it is not clear if they are suitable alternatives to more rigorously validated sensors.

The results of this project suggest that commonly used DIY sensors differ from reference sensing devices in the signal profiles detected. However, critical features of the breathing signal appear to be preserved (e.g., the peaks and valleys of the signal). This suggests that DIY sensors are capable of accurately characterizing rudimentary features of the breath such as mean breathing rate, however more work may be needed to accurately sense more nuanced characteristics such as breathing volumes, velocities, and phase timing.


# Fabricating DIY Breathing Bands

In this project, I've developed three variants of DIY breath sensing bands based on implementations presented in previous research. Each variant was attached to an adjustable elastic strap that was positioned at the wearer's chest / abdomen during use.

    1. A **flex-sensor** based implementation that monitors breathing by detecting deformations in the curvature of the chest / abdomen as it expands and contracts.
    1. A **conductive-elastic-cord** based implementation that monitors breathing by detecting changes in the circumference of the chest / abdomen.
    1. A **conductive-elastic-fabric** with similar properties to the cord.


# Data Capture Utility

Each breath sensing band was interfaced through an Arduino Uno. A GUI was developed using Processing 3.0 (i.e., a Java-based prototyping language) and the Firmata library, which provides a generic API for interfacing with Arduino devices. This utility is found in the `ExperimentTools >> BreathLogger` project folder. More information about the utility can be found in the project report, linked below.


# Breath Guidance Utility

A breath guidance utility was used to ensure consistent breathing behaviors between participants in the study. This utility was also developed in Processing 3.0. The guide used in the study is found in the `ExperimentTools >> BreathGuide` project folder, while other alternative guide designs are found in the `ExperimentTools >> BreathTest` project folder. More information about these utilities can be found in the project report, linked below.


# Data Analysis

Data analysis was conducted using Python and R. Python scripts were used to pre-process and reshape the dataset, while R was used to compute relevant statistical analysis. Note that while summary figures are included in this repository, raw participant data has been omitted for anonymity. Data analysis scripts are found in the `DataAnalysis` project folder. More information about analysis and results is presented in the project report, linked below.


# More Information

This project was completed the UNB course CS6065, Human Computer Interaction. Additional information about the project and findings can be found below:
 
    - [Project Report](https://drive.google.com/file/d/1aPWoukxYgRNtGLF1-vNGCIn-KOlsoxOf/view?usp=sharing)
    - [Overview Video](https://youtu.be/yZ0PEfM-H_Q)