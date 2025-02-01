import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers


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
from tensorflow.keras.preprocessing.image import ImageDataGenerator

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
cnn_model.save("signature_cnn_model.h5")

# --------------------------------------------------------------------------------------------------------------------------------------------

