## Proposal: Fraud Detection

Fraud detection binomial prediction model. Eventually selected Random Forest as the model type
  
**[HTML Presentation]**(http://htmlpreview.github.io/?https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/docs/HPC_PROJECT_JOTSAP_PRESENTATION.html)
  

### Data source  

**[Kaggle: Fraud Detection]**(https://www.kaggle.com/datasets/ealaxi/paysim1)
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
  
### Tools & Technology
  
Developing this model in R

* Data Cleaning: Dplyr, Magrittr, Tidyr, Readr
* Data Modeling: Caret, RandomForest, Ranger, e1071, Parallel, doParallel
* Workflow: SLURM, Spack
  
### Production workflow  
* Load Spack Shell
* Activate Spack Environment
* Load Data
* Clean & Process Data
* Train Model
  
  
**File**                 | **Function**
-------------------------|-----------
```spack_r_final.yaml``` | Spack YAML file for creating the environment
```fraud_final.R```      | loads libraries, loads & cleans data, runs model
```fraud.sbatch```       | SLURM file that calls the **fraud_final.R** file 

### Tools for implementing the workflow  
I am initially developing this model in R. I'm using Caret on training data for hyperparameter tuning and AutoML  
Additionally R has packages that can parallelize such as RevoScaleR and doParallel()  


### Performance optimization targets  
NOTE: this will be detailed in my Project Write-up / Presentation

**Data Loading**
Initially I placed the data file on Azure Blob storage, however it literally took OVER AN HOUR, so instead I staged the data on M2 $WORK
  
**Data Cleaning**
I got a *small* processing improvement using Dplyr as it has vectorized operations for several of the steps

**Data Modeling**
Using **Ranger** was leverates C++ libraries which offers performance improvement over the default RandomForest. Additionally using **Caret** and **Parallel** library, you can actually parallelize the model training processes
  
  
### M2 Resource  
  
[standard-mem-s](https://s2.smu.edu/hpc/documentation/about.html#standard-nodes)


* Xeon E5-2695v4 2.1 GHz 18-core “Broadwell” processors with 45 MB of cache each 
* 256 GB of DDR4-2400 memory
* Advanced Vector Extensions (AVX2)
  
**RStudio on M2 VDI**  
![M2 VDI](https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/figures/STAG-VDI-VNC.JPG)
  
Each node has: 
* Dual Intel Xeon E5-2695v4 2.1 GHz 18-core “Broadwell” processors
* 256 GB of DDR4-2400 RAM
* NVIDIA Quadro M5000 GPU



