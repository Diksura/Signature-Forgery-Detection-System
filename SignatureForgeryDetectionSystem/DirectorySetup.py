import os
import subprocess

## ===============================================================================================================
## MAKE SURE YOU HAVE SETUPED THE VIRTUAL ENVIROMENT BEFORE RUN THIS, IF NOT IT'LL INSTALL PACKAGES GLOBALLY.
## ===============================================================================================================

## -----------------------------------------------------------------------------------------------------------
## Packages Installations
subprocess.run(["pip", "install", "-r", "./SignatureForgeryDetectionSystem/requirements.txt"], check=True)


## -----------------------------------------------------------------------------------------------------------
## Directory Setup
main_path = "./SignatureForgeryDetectionSystem/MachineLearning/"

os.makedirs(os.path.join(main_path, "Dataset"), exist_ok=True)
os.makedirs(os.path.join(main_path, "Model"), exist_ok=True)


datasetDir_path = "./SignatureForgeryDetectionSystem/MachineLearning/Dataset/"

os.makedirs(os.path.join(datasetDir_path, "Features"), exist_ok=True)
os.makedirs(os.path.join(datasetDir_path, "Processing"), exist_ok=True)
os.makedirs(os.path.join(datasetDir_path, "Resources"), exist_ok=True)


processingDir_path = "./SignatureForgeryDetectionSystem/MachineLearning/Dataset/Processing/"

os.makedirs(os.path.join(processingDir_path, "AdvanceTestingDataset"), exist_ok=True)
os.makedirs(os.path.join(processingDir_path, "AugmentedDataset"), exist_ok=True)
os.makedirs(os.path.join(processingDir_path, "HybridDataset"), exist_ok=True)
os.makedirs(os.path.join(processingDir_path, "Pre-ProcessedDataset"), exist_ok=True)


resourcesDir_path = "./SignatureForgeryDetectionSystem/MachineLearning/Dataset/Resources/"

os.makedirs(os.path.join(resourcesDir_path, "Backup Dataset"), exist_ok=True)
os.makedirs(os.path.join(resourcesDir_path, "ProcessingDataset"), exist_ok=True)
