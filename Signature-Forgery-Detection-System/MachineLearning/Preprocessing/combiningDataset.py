import os
import shutil

# Target Paths
datasetDir_path = "./Signature-Forgery-Detection-System/Dataset"

target_genuine = "./Signature-Forgery-Detection-System/Dataset/HybridDataset/Genuine"
target_forged = "./Signature-Forgery-Detection-System/Dataset/HybridDataset/Forged"

# Create target folders if not exist
os.makedirs(os.path.join(datasetDir_path, "HybridDataset"), exist_ok=True)
os.makedirs(target_genuine, exist_ok=True)
os.makedirs(target_forged, exist_ok=True)


# Process Dataset 02
def combineDataset2(): 
    source_forgery = "./Signature-Forgery-Detection-System/Dataset/ProcessingDataset/archive2/FORGERY_ALL"
    source_real = "./Signature-Forgery-Detection-System/Dataset/ProcessingDataset/archive2/REAL_ALL"

    # Processing Forged Signatures
    for file_name in os.listdir(source_forgery):
        if file_name.endswith(".jpg"):
            parts = file_name.split("_")
            if len(parts) == 2:
                person_id = parts[0][-3:]  # Extract last 3 digits of the first part as person ID
                image_id = parts[1].split(".")[0]  # Extract image ID before file extension
                new_name = f"F_D2_{person_id}_{image_id}.jpg"
                shutil.copy(os.path.join(source_forgery, file_name), os.path.join(target_forged, new_name))

    # Processing Genuine Signatures
    for file_name in os.listdir(source_real):
        if file_name.endswith(".jpg"):
            parts = file_name.split("_")
            if len(parts) == 2:
                person_id = parts[0][-3:]  # Extract last 3 digits of the first part as person ID
                image_id = parts[1].split(".")[0]  # Extract image ID before file extension
                new_name = f"T_D2_{person_id}_{image_id}.jpg"
                shutil.copy(os.path.join(source_real, file_name), os.path.join(target_genuine, new_name))
    
    print("Completed Dataset 2 Process")


# Process Dataset 03
def combineDataset3(): 
    source_path = "./Signature-Forgery-Detection-System/Dataset/ProcessingDataset/archive3/Signature Images"

    for file_name in os.listdir(source_path):
        if len(file_name) > 3 and (file_name[2] == "F" or file_name[2] == "T"):  # Ensure filename is long enough to check the third letter and valid format
            file_path = os.path.join(source_path, file_name)

            # identifier = file_name[:3]  # Extract the first three characters for ID
            # count = file_name[4:]  # Extract remaining digits as count
            split_char = "F" if "F" in file_name else "T"
            person_id, image_id_ext = file_name.split(split_char)
            image_id, extension = os.path.splitext(image_id_ext) 

            if file_name[2] == "F":  # Forged signature
                new_name = f"F_D3_{int(person_id) + 30}_{image_id}{extension}"
                shutil.copy(file_path, os.path.join(target_forged, new_name))
            elif file_name[2] == "T":  # Genuine signature
                new_name = f"T_D3_{int(person_id) + 30}_{image_id}{extension}"
                shutil.copy(file_path, os.path.join(target_genuine, new_name))
    
    print("Completed Dataset 3 Process")


# Processing
if __name__ == "__main__":
    combineDataset2()
    combineDataset3()
    print("Dataset combination completed successfully.")
