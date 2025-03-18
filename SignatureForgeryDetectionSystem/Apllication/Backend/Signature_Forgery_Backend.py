from fastapi import FastAPI, UploadFile, File
import cv2
import numpy as np
import tensorflow as tf
import pandas as pd
from skimage.feature import hog, local_binary_pattern
from scipy.stats import kurtosis, skew
from io import BytesIO

app = FastAPI()

# Load trained model
model = tf.keras.models.load_model("../Model/signature_forgery_detection_model.h5")

# Feature extraction functions
def extract_features_from_image(img):
    img = cv2.imdecode(np.frombuffer(img.read(), np.uint8), cv2.IMREAD_GRAYSCALE)
    img = cv2.resize(img, (256, 128))
    
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

# API Endpoint
@app.post("/verify")
async def verify_signature(original: UploadFile = File(...), test: UploadFile = File(...)):
    # Extract features
    original_features = extract_features_from_image(original)
    test_features = extract_features_from_image(test)
    
    # Convert features to proper shape
    handcrafted_features = np.expand_dims(test_features, axis=0)
    handcrafted_features = handcrafted_features.reshape(handcrafted_features.shape[0], handcrafted_features.shape[1], 1)
    
    # Convert image to CNN input format
    test_img = cv2.imdecode(np.frombuffer(test.file.read(), np.uint8), cv2.IMREAD_COLOR)
    test_img = cv2.resize(test_img, (299, 299))
    test_img = tf.keras.applications.inception_v3.preprocess_input(test_img)
    test_img = np.expand_dims(test_img, axis=0)
    
    # Model Prediction
    prediction = model.predict([test_img, handcrafted_features])
    is_genuine = bool(prediction[0][0] > 0.5)
    
    return {"genuine": is_genuine, "confidence": float(prediction[0][0])}
