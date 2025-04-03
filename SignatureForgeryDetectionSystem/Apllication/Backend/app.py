import tensorflow as tf
import numpy as np
import cv2
from flask import Flask, request, jsonify
from skimage.feature import hog, local_binary_pattern
from scipy.stats import kurtosis, skew
from tensorflow.keras.applications.inception_v3 import preprocess_input

# Load the trained Siamese model
MODEL_PATH = "/Users/pasan_diksura/Documents/SoftwareDevelopment/Projects/Signature-Forgery-Detection-System/SignatureForgeryDetectionSystem/MachineLearning/Model/signature_forgery_detection_model.h5"
model = tf.keras.models.load_model(MODEL_PATH)

# Define image dimensions (should match the training size)
IMG_SIZE = (299, 299)

app = Flask(__name__)

def preprocess_image(img_array):
    """Preprocess an image for the model."""
    img = cv2.resize(img_array, IMG_SIZE)  # Resize to match model input
    img = preprocess_input(img)  # Apply InceptionV3 preprocessing
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    return img

def extract_features_from_image(img_array):
    """Extract handcrafted features directly from an image array."""
    img_gray = cv2.cvtColor(img_array, cv2.COLOR_BGR2GRAY)
    img_gray = cv2.resize(img_gray, IMG_SIZE)
    
    features = []
    features.extend(hog(img_gray, pixels_per_cell=(16, 16), cells_per_block=(2, 2), orientations=9, visualize=False, block_norm='L2-Hys'))
    features.extend(local_binary_pattern(img_gray, P=24, R=3, method="uniform").ravel())
    features.extend(cv2.HuMoments(cv2.moments(img_gray)).flatten())
    features.append(len(cv2.ORB_create().detect(img_gray, None)))
    features.extend([np.mean(img_gray), np.std(img_gray), np.median(img_gray), skew(img_gray.flatten()), kurtosis(img_gray.flatten())])
    
    binary = cv2.threshold(img_gray, 128, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]
    thickness = np.sum(binary == 255) / np.count_nonzero(binary)
    density = np.sum(binary == 255) / binary.size
    features.extend([thickness, density])
    
    return np.array(features)

@app.route("/predict", methods=["POST"])
def predict():
    if "image1" not in request.files:
        return jsonify({"error": "Please provide an image"}), 400

    file1 = request.files["image1"]
    
    # Read the image into memory
    file_bytes = np.frombuffer(file1.read(), np.uint8)
    img_array = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)  # Decode as color image
    
    if img_array is None:
        return jsonify({"error": "Invalid image format"}), 400

    # Preprocess image for CNN
    img1 = preprocess_image(img_array)

    # Extract handcrafted features
    features1 = extract_features_from_image(img_array)
    
    # Reshape features to match model input
    features1 = np.expand_dims(features1, axis=0)

    # Ensure the feature vector length matches model expectations
    target_length = 3821  
    feature_length = features1.shape[1]

    if feature_length != target_length:
        if feature_length > target_length:
            features1 = features1[:, :target_length]  # Truncate
        else:
            padding = np.zeros((1, target_length - feature_length))
            features1 = np.concatenate([features1, padding], axis=1)  # Pad

    # Predict similarity
    prediction = model.predict([img1, features1])[0][0]

    # Set threshold (adjust based on model performance)
    threshold = 0.4  
    result = "Genuine" if prediction < threshold else "Forgery"

    return jsonify({"prediction": float(prediction), "result": result})

if __name__ == "__main__":
    app.run(debug=True)
