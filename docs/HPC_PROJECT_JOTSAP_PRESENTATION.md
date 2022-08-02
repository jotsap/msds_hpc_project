SMU HPC Project
========================================================
author: Jeremy Otsap
date: Aug 4, 2022
autosize: true



HPC DS7347 - FINAL PROJECT
========================================================
  
[SMU Data Science Masters](https://datascience.smu.edu)
  
## Fraud Detection
  
JEREMY OTSAP  
jotsap@smu.edu
  


Problem & Data
========================================================

[Kaggle: Fraud Detection](https://www.kaggle.com/datasets/ealaxi/paysim1)
Size: 470MB  
Dimensions: 6.3 Million Rows & 9 Predictors

* step [int]: Maps a unit of time in the real world. In this case 1 step is 1 hour of time. Total steps 744 (30 days simulation).
* type [factor]: CASH-IN, CASH-OUT, DEBIT, PAYMENT and TRANSFER
* amount [int]: amount of the transaction in local currency
* nameOrig [char]: customer who started the transaction
* oldbalanceOrg [dollar]: initial balance before the transaction
* newbalanceOrig [dollar]: customer's balance after the transaction.
* nameDest [char]: recipient ID of the transaction.
* oldbalanceDest [float]: initial recipient balance before the transaction.
* newbalanceDest [float]: recipient's balance after the transaction.

RESPONSE:
* isFraud [boolean]: identifies a fraudulent transaction (1) and non fraudulent (0)


Alternative Data Set
========================================================

NOTE: I did consider an alternative:  
https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud

93% of features were PCA generated predictors that were already fully scaled & centered:  
V1 - V28 + Time Interval + Amount  
Size: 147MB  
Rows: 248,000  
  
Not a good candidate
* Predictors have already been processed
* Less than 1 million rows
* No categorical predictors; numerical & interval only


Analysis workflow 
========================================================
* Load Data
* Clean & Process Data
* Train Model


Tools & Technology
========================================================
Developing this model in R

* Data Cleaning: Dplyr, Magrittr, Tidyr, Readr
* Data Modeling: Caret, RandomForest, Ranger, e1071, Parallel, doParallel
* Workflow: SLURM, Spack


Dev Process
========================================================

Informally wanted to emulate a separation of environments. While not perfect, functionally it served the purpose

* Dev: Local PC
* Staging: M2 VDI
* Prod: M2 Slurm


Dev: Local System
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/Laptop-DxDiag-System.JPG)

***
Acer Aspire E5-773G  
Intel i5-6200 2.3GHz [Skylake]  
- 2 Physical Cores + Hyperthreading
- SSE 4.2 and AVX2 Vector Extensions  

16GB DDR3L-1600 RAM  
OS Disk: 256 SSD  
System Disk: 1TB HDD  


M2 Staging
========================================================

[M2 VNC Statistics](https://s2.smu.edu/hpc/documentation/about.html#virtual-desktop-nodes)

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/STAG-VDI-Request.JPG)

***
  
  
Each node has: 
* Dual Intel Xeon E5-2695v4 2.1 GHz 18-core “Broadwell” processors
* 256 GB of DDR4-2400 RAM
* NVIDIA Quadro M5000 GPU
  
  
RStudio on M2 VDI
========================================================
![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/STAG-VDI-VNC.JPG)


M2 Prod
========================================================

[standard-mem-s](https://s2.smu.edu/hpc/documentation/about.html#standard-nodes)


* Xeon E5-2695v4 2.1 GHz 18-core “Broadwell” processors with 45 MB of cache each 
* 256 GB of DDR4-2400 memory
* Advanced Vector Extensions (AVX2)


Dev - Data Loading 
========================================================

**Problem:** 470 MB - too big for GitHub  
**Solution:** Used Azure Blob Storage

Data Loading from Azure: **135 minutes**  
Unreliably crashed more than **50% of the time**


Data Loading from HDD
========================================================
**5 MIN & 55 SEC**  

![](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/DEV_DataLoad_HDD.jpg)


Data Loading from SSD
========================================================
**4 MIN & 47 SEC**  
~19% improvement

![](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/DEV_DataLoad_SSD.jpg)


Staging - Data Loading from Azure
========================================================

MUCH faster than Dev since it leveraged M2's internet connection  
**7 MIN 24 SEC**

![](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/STAG-DataLoad-Azure.JPG)



Staging - Data Loading from $WORK
========================================================

**2 MIN 35 SEC**  
~65% improvement

![](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/STAG-DataLoad-WORK.JPG)


Optimizing Model
========================================================

Model selection: CART / Random Forest

**PRO:** Good candidate for parallel processing  
**CON:** Bad candidate for GPU CUDA

  
*Reference*  
https://rstudio-pubs-static.s3.amazonaws.com/15192_5965f6c170994ebb972deaf18f1ddf34.html


Good candidate for parallel processing
========================================================
Resampling is primary approach for optimizing predictive models with tuning parameters. To do this, many alternate versions of the training set are used to train the model and predict a hold-out set. This process is repeated many times to get performance estimates that generalize to new data sets. Each of the resampled data sets is independent of the others, so there is no formal requirement that the models must be run sequentially. 


Bad candidate for GPU CUDA
========================================================
CUDA cores do not act independently. 
While running automatically organized into concurrently operating threads aka 'warps'
GPU usually has only 1-2 mutliprocessors which runs the entire warp 
Every CUDA core in the thread or warp is capable of running concurrently on the warp, HOWEVER GPU multiprocessor has a constraint: the instruction on _each_ thread in the warp **must be the same.** If instructions _differ_ a thread will **wait.**



Initial RF Model: Non-Optimized Library
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/TEST-RandomForest-Default_Grid.JPG)

***
Default RandomForest R package  
https://github.com/cran/randomForest

Run-time: **52 MIN & 7 SEC**


Ranger Library
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/TEST-RandomForest-Ranger_1CPU.JPG)

***

Ranger is a fast implementation of random forests written in C++ instead of Fortran for RandomForest package  
https://github.com/imbs-hl/ranger

Run-time: **37 MIN & 47 SEC**


Ranger Library: 2 vCPU
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/TEST-RandomForest-Ranger_2CPU.JPG)

***

Run-time: **21 MIN & 23 SEC**


Ranger Library: 3 vCPU
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/TEST-RandomForest-Ranger_3CPU.JPG)

***

Run-time: **15 MIN & 21 SEC**


Ranger Library: 4 vCPU
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/TEST-RandomForest-Ranger_4CPU.JPG)

***

Run-time: **12 MIN & 22 SEC**


Ranger Library: 6 vCPU
========================================================

![alt text](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/TEST-RandomForest-Ranger_6CPU.JPG)

***

Run-time: **9 MIN & 32 SEC**


Parallelization Performance Improvement
========================================================
  
### Diminishing returns after 6 CPUs  
Runtime capped out at approximately 8 minutes  


```{r rf-performance, echo=FALSE} 

rf_times <- c(52.115, 37.777, 21.374, 15.355, 12.365, 9.533)
names(rf_times) <- c('Default-RF', 'Ranger-1CPU', 'Ranger-2CPU', 'Ranger-3CPU', 'Ranger-4CPU', 'Ranger-6CPU')

barplot( rf_times, col = rainbow(length(rf_times)),   main = "RF Performance vs CPU", names.arg = F, horiz = T, legend.text = names(rf_times), xlab = "Minutes")


```




