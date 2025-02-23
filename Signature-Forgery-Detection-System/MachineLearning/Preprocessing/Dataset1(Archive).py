import os
import shutil
from PIL import Image

# Define source and destination directories
source_dir = "Signature-Forgery-Detection-System/MachineLearning/Dataset/Resources/ProcessingDataset/archive"
output_dir = "Signature-Forgery-Detection-System/MachineLearning/Dataset/Processing/Dataset01(Archive)"
real_dir = os.path.join(output_dir, "real")
forged_dir = os.path.join(output_dir, "forged")

# Create the output folders if they don't exist
os.makedirs(real_dir, exist_ok=True)
os.makedirs(forged_dir, exist_ok=True)

# Helper function to check if an image is original or forged
def get_label(filename):
    if "forgeries" in filename or "_F_" in filename or filename.startswith("forge"):
        return "forged"
    elif "original" in filename or "_G_" in filename:
        return "real"
    return None  # Ignore unknown formats

# Process all images in the dataset
for split in ["Train", "Test"]:  # Loop through Train and Test directories
    split_path = os.path.join(source_dir, split)
    
    if not os.path.exists(split_path):
        print(f"Skipping missing directory: {split_path}")
        continue
    
    for subject_id in os.listdir(split_path):  # Loop through subject folders (e.g., "1", "10", "58")
        subject_path = os.path.join(split_path, subject_id)
        
        if not os.path.isdir(subject_path):  # Skip if not a directory
            continue
        
        for filename in os.listdir(subject_path):  # Loop through image files
            file_path = os.path.join(subject_path, filename)
            
            # Identify label
            label = get_label(filename)
            if label is None:
                print(f"Skipping unknown file: {filename}")
                continue
            
            # Standardize filename: subjectID_label_count.jpg
            new_filename = f"{subject_id}_{label}_{filename.split('_')[-1].split('.')[0]}.jpg"
            dest_dir = real_dir if label == "real" else forged_dir
            dest_path = os.path.join(dest_dir, new_filename)

            # Convert to JPG and save in new structure
            try:
                img = Image.open(file_path).convert("RGB")  # Convert to RGB to avoid format issues
                img.save(dest_path, "JPEG")
                print(f"Processed: {new_filename}")
            except Exception as e:
                print(f"Error processing {filename}: {e}")

print("Dataset cleanup completed!")
