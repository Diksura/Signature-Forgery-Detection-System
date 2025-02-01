import tensorflow as tf
from tensorflow import keras
from keras import layers

import matplotlib.pyplot as plt
from sklearn.metrics import classification_report
import numpy as np
from sklearn.metrics import confusion_matrix
import seaborn as sns

# --------------------------------------------------------------------------------------------------------------------------------------------
# Define the CNN model
def build_cnn_model(input_shape=(128, 256, 1)):
    model = keras.Sequential([
        layers.Conv2D(32, (3, 3), activation='relu', input_shape=input_shape),
        layers.MaxPooling2D((2, 2)),

        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),

        layers.Conv2D(128, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),

        layers.Flatten(),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(1, activation='sigmoid')  # Binary classification (Genuine vs. Forgery)
    ])

    model.compile(optimizer='adam',
                  loss='binary_crossentropy',
                  metrics=['accuracy'])
    
    return model

# --------------------------------------------------------------------------------------------------------------------------------------------
from keras._tf_keras.keras.preprocessing.image import ImageDataGenerator

# Define data directories
train_dir = "./Signature-Forgery-Detection-System/Dataset/Dataset_Split/Train"
test_dir = "./Signature-Forgery-Detection-System/Dataset/Dataset_Split/Test"

# Data preprocessing & augmentation
datagen = ImageDataGenerator(rescale=1./255)

train_generator = datagen.flow_from_directory(
    train_dir,
    target_size=(128, 256),
    batch_size=32,
    class_mode='binary',
    color_mode='grayscale'
)

test_generator = datagen.flow_from_directory(
    test_dir,
    target_size=(128, 256),
    batch_size=32,
    class_mode='binary',
    color_mode='grayscale'
)

# --------------------------------------------------------------------------------------------------------------------------------------------
# Initialize model
cnn_model = build_cnn_model()

# Train model
history = cnn_model.fit(
    train_generator,
    epochs=10,
    validation_data=test_generator
)

# Save the trained model
cnn_model.save("signature_cnn_model.keras")


# --------------------------------------------------------------------------------------------------------------------------------------------
# EVALUATION AND VALIDATION ACCURACY
# --------------------------------------------------------------------------------------------------------------------------------------------

# Plot training & validation accuracy
plt.plot(history.history['accuracy'], label='Train Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()
plt.title("Model Accuracy")
plt.show()

# Plot training & validation loss
plt.plot(history.history['loss'], label='Train Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.title("Model Loss")
plt.show()




# --------------------------------------------------------------------------------------------------------------------------------------------
# Load the model
model = tf.keras.models.load_model("signature_cnn_model.h5")

# Generate predictions
y_true = test_generator.classes  # True labels
y_pred = model.predict(test_generator)  # Predicted probabilities
y_pred = np.where(y_pred > 0.5, 1, 0)  # Convert probabilities to binary labels

# Print classification report
print(classification_report(y_true, y_pred, target_names=["Genuine", "Forgery"]))



# --------------------------------------------------------------------------------------------------------------------------------------------
# Compute confusion matrix
cm = confusion_matrix(y_true, y_pred)

# Plot confusion matrix
plt.figure(figsize=(6,5))
sns.heatmap(cm, annot=True, fmt="d", cmap="Blues", xticklabels=["Genuine", "Forgery"], yticklabels=["Genuine", "Forgery"])
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.title("Confusion Matrix")
plt.show()