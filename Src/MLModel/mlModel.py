import cv2
import numpy as np
import requests
from io import BytesIO
import firebase_admin
from firebase_admin import credentials, firestore
import tensorflow as tf

# Firebase 초기화
cred = credentials.Certificate('Src\MLModel\ossproj-comfyride-firebase-adminsdk-f2uq6-b2aac3a165.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# 이미지 다운로드 및 전처리 함수
def download_and_preprocess_image(image_url):
    response = requests.get(image_url)
    image = np.array(bytearray(response.content), dtype=np.uint8)
    image = cv2.imdecode(image, cv2.IMREAD_COLOR)
    image = cv2.resize(image, (224, 224))  # 이미지 리사이징
    image = image / 255.0  # 정규화
    return image

# Firestore에서 데이터 불러오기 및 이미지 처리
def load_data_from_firestore():
    docs = db.collection('data_').stream()
    images = []
    labels = []
    label_map = {'o': 0, 'c': 1, 'f': 2}  # 라벨 매핑

    for doc in docs:
        data = doc.to_dict()
        image_url = data['img']
        label = label_map[data['code']]
        image = download_and_preprocess_image(image_url)
        images.append(image)
        labels.append(label)

    return np.array(images), np.array(labels)

# 모델 구성 및 학습
def build_and_train_model(images, labels):
    model = tf.keras.Sequential([
        tf.keras.layers.Conv2D(32, (3, 3), activation='relu', input_shape=(224, 224, 3)),
        tf.keras.layers.MaxPooling2D(2, 2),
        tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
        tf.keras.layers.MaxPooling2D(2, 2),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(3, activation='softmax')
    ])
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    model.fit(images, labels, epochs=10)
    return model

# 데이터 로딩 및 모델 학습
images, labels = load_data_from_firestore()
model = build_and_train_model(images, labels)
model.save('Src\MLModel\model.h5')