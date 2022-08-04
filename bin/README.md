
### Production workflow  
* Load Spack Shell
* Activate Spack Environment
* Load Data
* Clean & Process Data
* Train Model
  
### Project Files
  
**File**                 | **Function**
-------------------------|-----------
```spack_r_final.yaml``` | Spack YAML file for creating the environment
```fraud_final.R```      | loads libraries, loads & cleans data, runs model
```fraud.sbatch```       | SLURM file that calls the **fraud_final.R** file 


