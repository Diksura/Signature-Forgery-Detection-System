# import tensorflow as tf
# import numpy as np
# import cv2
# import os
# from flask import Flask, request, jsonify
# from werkzeug.utils import secure_filename

# # Load the trained Siamese model
# MODEL_PATH = "/Users/pasan_diksura/Documents/SoftwareDevelopment/Projects/Signature-Forgery-Detection-System/SignatureForgeryDetectionSystem/MachineLearning/Model/signature_forgery_detection_model.h5"
# model = tf.keras.models.load_model(MODEL_PATH)

# # Define image dimensions (should match the training size)
# IMG_SIZE = (128, 256)

# app = Flask(__name__)

# # Ensure upload directory exists
# UPLOAD_FOLDER = "uploads"
# os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# def preprocess_image(image_path):
#     """ Load and preprocess an image for the model. """
#     img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)  # Convert to grayscale
#     img = cv2.resize(img, IMG_SIZE)  # Resize to match model input
#     img = np.expand_dims(img, axis=-1)  # Add channel dimension
#     img = np.expand_dims(img, axis=0)  # Add batch dimension
#     img = img / 255.0  # Normalize
#     return img

# @app.route("/predict", methods=["POST"])
# def predict():
#     if "image1" not in request.files or "image2" not in request.files:
#         return jsonify({"error": "Please provide both images"}), 400

#     # Save uploaded images
#     file1 = request.files["image1"]
#     file2 = request.files["image2"]
    
#     path1 = os.path.join(UPLOAD_FOLDER, secure_filename(file1.filename))
#     path2 = os.path.join(UPLOAD_FOLDER, secure_filename(file2.filename))
    
#     file1.save(path1)
#     file2.save(path2)

#     # Preprocess images
#     img1 = preprocess_image(path1)
#     img2 = preprocess_image(path2)

#     # Predict similarity
#     prediction = model.predict([img1, img2])[0][0]
    
#     # Set threshold (adjust based on model performance)
#     threshold = 0.4  
#     result = "Match" if prediction < threshold else "Forgery"

#     return jsonify({"prediction": float(prediction), "result": result})

# if __name__ == "__main__":
#     app.run(debug=True)





import tensorflow as tf
import numpy as np
import cv2
import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from skimage.feature import hog, local_binary_pattern
from scipy.stats import kurtosis, skew
from tensorflow.keras.applications.inception_v3 import preprocess_input

# Load the trained Siamese model
MODEL_PATH = "/Users/pasan_diksura/Documents/SoftwareDevelopment/Projects/Signature-Forgery-Detection-System/SignatureForgeryDetectionSystem/MachineLearning/Model/signature_forgery_detection_model.h5"
model = tf.keras.models.load_model(MODEL_PATH)

# Define image dimensions (should match the training size)
IMG_SIZE = (299, 299)
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app = Flask(__name__)

def preprocess_image(image_path):
    """ Load and preprocess an image for the model. """
    img = cv2.imread(image_path, cv2.IMREAD_COLOR)  # Load as color image
    img = cv2.resize(img, (299, 299))  # Resize to match model input
    img = preprocess_input(img)  # Apply InceptionV3 preprocessing
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    return img

# Feature extraction function
def extract_features_from_image(image_path):
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    img = cv2.resize(img, IMG_SIZE)
    
    features = []
    features.extend(hog(img, pixels_per_cell=(16, 16), cells_per_block=(2, 2), orientations=9, visualize=False, block_norm='L2-Hys'))
    features.extend(local_binary_pattern(img, P=24, R=3, method="uniform").ravel())
    features.extend(cv2.HuMoments(cv2.moments(img)).flatten())
    features.append(len(cv2.ORB_create().detect(img, None)))
    features.extend([np.mean(img), np.std(img), np.median(img), skew(img.flatten()), kurtosis(img.flatten())])
    
    binary = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]
    thickness = np.sum(binary == 255) / np.count_nonzero(binary)
    density = np.sum(binary == 255) / binary.size
    features.extend([thickness, density])
    
    return np.array(features)

@app.route("/predict", methods=["POST"])
def predict():
    if "image1" not in request.files or "image2" not in request.files:
        return jsonify({"error": "Please provide both images"}), 400

    # Save uploaded images
    file1 = request.files["image1"]
    file2 = request.files["image2"]
    
    path1 = os.path.join(UPLOAD_FOLDER, secure_filename(file1.filename))
    path2 = os.path.join(UPLOAD_FOLDER, secure_filename(file2.filename))
    
    file1.save(path1)
    file2.save(path2)

    # Preprocess images for CNN
    img1 = preprocess_image(path1)
    img2 = preprocess_image(path2)

    # Extract handcrafted features
    features1 = extract_features_from_image(path1)
    features2 = extract_features_from_image(path2)
    
    # Dynamically reshape features to match model input
    # Here you can resize or adjust the features if necessary
    features1 = np.expand_dims(features1, axis=0)
    features2 = np.expand_dims(features2, axis=0)
    
    # Make sure the feature vector length is what your model expects
    feature_length = features1.shape[1]
    
    # Update reshaping logic dynamically based on feature length
    # Assuming your model expects a feature vector of length 3821
    target_length = 3821
    
    if feature_length != target_length:
        # Resize or truncate the feature vector to the target length
        if feature_length > target_length:
            features1 = features1[:, :target_length]
            features2 = features2[:, :target_length]
        else:
            # Padding with zeros if the feature vector is smaller
            padding = np.zeros((1, target_length - feature_length))
            features1 = np.concatenate([features1, padding], axis=1)
            features2 = np.concatenate([features2, padding], axis=1)

    # Predict similarity
    prediction = model.predict([img1, features1])[0][0]
    
    # Set threshold (adjust based on model performance)
    threshold = 0.4  
    result = "Match" if prediction < threshold else "Forgery"

    return jsonify({"prediction": float(prediction), "result": result})

if __name__ == "__main__":
    app.run(debug=True)
