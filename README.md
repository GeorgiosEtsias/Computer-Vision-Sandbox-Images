# Application of computer vision on laboratory sandbox investigations 
## Table of contents
- [Citing this work](#citing-this-work)

- [Compatibility](#compatibility)

- [Project overview](#project-overview)

- Image pre-processing

- Classification

- Regression

- Common errors – out of memory

## Citing this work

This project is part of the Saline Intrusion in Coastal Aquifers ([SALINA](https://gow.epsrc.ukri.org/NGBOViewGrant.aspx?GrantRef=EP/R019258/1)) research project. 
Data acquisition and analysis was conducted in Queen’s University Belfast (2019-2020). Funding was provided by EPSRC Standard Research (Grant No. EP/R019258/1).

If you use Computer-Vision-Sandbox-Images as part of your workflow in a scientific publication, please consider citing the repository with the following DOI:

Etsias, G.; Hamill, G.A.; Benner, E.M.; Águila, J.F.; McDonnell, M.C.; Flynn, R.; Ahmed, A.A. Optimizing Laboratory Investigations of Saline Intrusion by Incorporating Machine Learning Techniques. Water 2020, 12, 2996. DOI: [10.3390/w12112996](https://www.mdpi.com/2073-4441/12/11/2996).  

## Compatibility

Works in accordance with the following MATLAB toolboxes:
[Deep Learning Toolbox](https://uk.mathworks.com/products/deep-learning.html), [Global Optimization Toolbox](https://uk.mathworks.com/products/global-optimization.html?s_tid=srchtitle), [Image Processing Toolbox](https://uk.mathworks.com/products/image.html?s_tid=srchtitle), [Statistics and Machine Learning Toolbox](https://uk.mathworks.com/products/statistics.html?s_tid=srchtitle), [Parallel Computing Toolbox](https://uk.mathworks.com/products/parallel-computing.html?s_tid=srchtitle), [Optimization Toolbox](https://uk.mathworks.com/products/optimization.html?s_tid=srchtitle)

## Project overview
Deriving saltwater concentrations from the values of light intensity is a long-established image processing practice in laboratory scale investigations of saline intrusion. The current repository presents a novel methodology that employs the predictive ability of machine learning algorithms in order to determine saltwater concentration fields. The proposed approach consists of three distinct parts, image pre-processing, ground profile classification (bead structure recognition) and saltwater field generation (regression). It minimizes the need for aquifer-specific calibrations, significantly shortening the experimental procedure by up to 50% of the time required. 

![alt text](https://github.com/GeorgiosEtsias/Computer-Vision-Sandbox-Images/blob/main/Figures/Fig1.PNG)
A graphical outline of the investigation

