import cv2
import os
import numpy as np
import matplotlib.pyplot as plt

# --------------------------------------------------------------------------------------------------------------------------------------------
# Paths
datasetDir_path = "./Signature-Forgery-Detection-System/Dataset"

input_folder = "./Signature-Forgery-Detection-System/Dataset/HybridDataset"
output_folder = "./Signature-Forgery-Detection-System/Dataset/PreprocessedDataset"


# Ensure output directories exist
os.makedirs(os.path.join(datasetDir_path, "PreprocessedDataset"), exist_ok=True)
os.makedirs(os.path.join(output_folder, "Genuine"), exist_ok=True)
os.makedirs(os.path.join(output_folder, "Forged"), exist_ok=True)

# Preprocessing function
def preprocess_image(image_path, output_path):
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)  # Convert to grayscale
    img = cv2.resize(img, (256, 128))  # Resize to standard size (adjust as needed)
    
    # Apply thresholding (Binarization)
    _, img = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # Save the preprocessed image
    cv2.imwrite(output_path, img)

# Process all images
for category in ["Genuine", "Forged"]:
    input_dir = os.path.join(input_folder, category)
    output_dir = os.path.join(output_folder, category)

    for file_name in os.listdir(input_dir):
        input_path = os.path.join(input_dir, file_name)
        output_path = os.path.join(output_dir, file_name)
        
        preprocess_image(input_path, output_path)

print("Preprocessing complete!")


# --------------------------------------------------------------------------------------------------------------------------------------------
# Select a few sample images to visualize
# sample_images = [
#     "PreprocessedDataset/Genuine/sample1.jpg",
#     "PreprocessedDataset/Forgery/sample2.jpg"
# ]

# # Display images
# fig, axes = plt.subplots(1, len(sample_images), figsize=(10, 5))
# for ax, img_path in zip(axes, sample_images):
#     img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
#     ax.imshow(img, cmap='gray')
#     ax.set_title(os.path.basename(img_path))
#     ax.axis("off")

# plt.show()


# --------------------------------------------------------------------------------------------------------------------------------------------
import os
import shutil
import random

# Paths
data_dir = "./Signature-Forgery-Detection-System/Dataset/PreprocessedDataset"
train_dir = "./Signature-Forgery-Detection-System/Dataset/Dataset_Split/Train"
test_dir = "./Signature-Forgery-Detection-System/Dataset/Dataset_Split/Test"

# Split ratio
train_ratio = 0.8  

# Ensure directories exist
os.makedirs(os.path.join(datasetDir_path, "Dataset_Split"), exist_ok=True)
for category in ["Genuine", "Forged"]:
    os.makedirs(os.path.join(train_dir, category), exist_ok=True)
    os.makedirs(os.path.join(test_dir, category), exist_ok=True)

# Function to split dataset
def split_dataset(category):
    src_path = os.path.join(data_dir, category)
    images = os.listdir(src_path)
    
    random.shuffle(images)
    split_index = int(len(images) * train_ratio)

    train_images = images[:split_index]
    test_images = images[split_index:]

    for img in train_images:
        shutil.copy(os.path.join(src_path, img), os.path.join(train_dir, category, img))

    for img in test_images:
        shutil.copy(os.path.join(src_path, img), os.path.join(test_dir, category, img))

# Apply split for both categories
split_dataset("Genuine")
split_dataset("Forged")

print("Dataset split into training and testing sets!")
