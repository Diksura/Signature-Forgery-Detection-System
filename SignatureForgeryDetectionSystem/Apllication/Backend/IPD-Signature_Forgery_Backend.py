import tensorflow as tf
import numpy as np
import cv2
import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename

# Load the trained Siamese model
MODEL_PATH = "/Users/pasan_diksura/Documents/SoftwareDevelopment/Projects/Signature-Forgery-Detection-System/SignatureForgeryDetectionSystem/MachineLearning/Model/signature_forgery_detection_model.h5"
model = tf.keras.models.load_model(MODEL_PATH)

# Define image dimensions (should match the training size)
IMG_SIZE = (128, 256)

app = Flask(__name__)

# Ensure upload directory exists
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def preprocess_image(image_path):
    """ Load and preprocess an image for the model. """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)  # Convert to grayscale
    img = cv2.resize(img, IMG_SIZE)  # Resize to match model input
    img = np.expand_dims(img, axis=-1)  # Add channel dimension
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    img = img / 255.0  # Normalize
    return img

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

    # Preprocess images
    img1 = preprocess_image(path1)
    img2 = preprocess_image(path2)

    # Predict similarity
    prediction = model.predict([img1, img2])[0][0]
    
    # Set threshold (adjust based on model performance)
    threshold = 0.4  
    result = "Match" if prediction < threshold else "Forgery"

    return jsonify({"prediction": float(prediction), "result": result})

if __name__ == "__main__":
    app.run(debug=True)
