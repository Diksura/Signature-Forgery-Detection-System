import os
import shutil


# Target Paths
target_genuine = "./Dataset/HybridDataset/Genuine"
target_forged = "./Dataset/HybridDataset/Forged"

# Paths
source_path = "archive1/All"

# Create target folders if not exist
os.makedirs(target_genuine, exist_ok=True)
os.makedirs(target_forged, exist_ok=True)

# Process Dataset 01
for person_folder in os.listdir(source_path):
    person_path = os.path.join(source_path, person_folder)
    if os.path.isdir(person_path):
        for file_name in os.listdir(person_path):
            file_path = os.path.join(person_path, file_name)
            if "forge" in file_name:
                new_name = f"{person_folder}_f{file_name.split('_')[-1]}"
                shutil.copy(file_path, os.path.join(target_forged, new_name))
            elif "original" in file_name:
                new_name = f"{person_folder}_{file_name.split('_')[-1]}"
                shutil.copy(file_path, os.path.join(target_genuine, new_name))

# Paths
source_forgery = "archive2/FORGERY_ALL"
source_real = "archive2/REAL_ALL"

# Process Dataset 02
for file_name in os.listdir(source_forgery):
    new_name = f"dataset2_f{file_name}"
    shutil.copy(os.path.join(source_forgery, file_name), os.path.join(target_forged, new_name))

for file_name in os.listdir(source_real):
    new_name = f"dataset2_{file_name}"
    shutil.copy(os.path.join(source_real, file_name), os.path.join(target_genuine, new_name))
