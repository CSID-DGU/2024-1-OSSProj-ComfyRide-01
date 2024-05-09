import uuid
import cv2
import numpy as np
import tensorflow as tf
import firebase_admin
from firebase_admin import credentials, storage, firestore
import urllib.parse

# Firebase 초기화
cred = credentials.Certificate('Src/MLModel/ossproj-comfyride-firebase-adminsdk-f2uq6-b2aac3a165.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'ossproj-comfyride.appspot.com'
})

# Firestore 클라이언트
firestore_db = firestore.client()

# Firebase Storage 클라이언트
bucket = storage.bucket()

# 라벨 매핑
label_map = {0: 'o', 1: 'c', 2: 'f'}  # 인덱스를 문자열로 매핑

# 공개된 URL 생성
def generate_public_url_with_token(file_path):
    bucket_name = 'ossproj-comfyride.appspot.com'
    file_path_encoded = urllib.parse.quote(file_path, safe='')
    blob = bucket.blob(file_path)

    # Blob의 메타데이터에서 Access Token 가져오기
    metadata = blob.metadata or {}
    token = metadata.get('firebaseStorageDownloadTokens')
    
    if not token:
        # 토큰이 없으면 새로운 토큰 생성
        token = str(uuid.uuid4())
        metadata['firebaseStorageDownloadTokens'] = token
        blob.metadata = metadata
        blob.patch()  # 메타데이터 업데이트
        print(f"New token generated for {file_path}: {token}")
    else:
        print(f"Existing token found for {file_path}: {token}")

    public_url = f'https://firebasestorage.googleapis.com/v0/b/{bucket_name}/o/{file_path_encoded}?alt=media&token={token}'
    return public_url

# Firebase Storage에서 이미지 다운로드 및 전처리
def download_and_preprocess_image(file_path):
    blob = bucket.blob(file_path)
    local_temp_path = 'local_image.jpg'
    try:
        blob.download_to_filename(local_temp_path)
        print(f"Image downloaded from {file_path}")
    except Exception as e:
        print(f"Error downloading image {file_path}: {e}")
        return None

    image = cv2.imread(local_temp_path)
    if image is None:
        print(f"Error reading image {file_path}")
        return None

    image = cv2.resize(image, (224, 224))
    image = image.astype(np.float32) / 255.0
    return image

# Firestore에 라벨 저장
def upload_label_to_firestore(file_path, label, collection_name):
    doc_id = file_path.replace('/', '_').replace('.', '_')
    doc_ref = firestore_db.collection(collection_name).document(doc_id)
    public_url = generate_public_url_with_token(file_path)  # 공개 URL + token
    if public_url:
        doc_ref.set({
            'file_path': public_url,  # 공개 URL 저장
            'predicted_label': label  # 문자열 라벨
        })
        print(f"Label '{label}' uploaded for document '{doc_id}'")
    else:
        print(f"Unable to generate public URL for {file_path}")

# 이미지 처리 및 라벨링
def process_and_label(file_path, model):
    image = download_and_preprocess_image(file_path)
    if image is None:
        return None

    image = np.expand_dims(image, axis=0)
    prediction = model.predict(image)
    label_index = np.argmax(prediction)
    return label_map.get(label_index, 'unknown')  # 예측된 인덱스를 문자열 라벨로 변환

# Firebase Storage에서 모든 이미지 처리 및 Firestore에 결과 저장
def process_storage_images_and_save_labels(prefix_path, collection_name):
    blobs = bucket.list_blobs(prefix=prefix_path)
    model = tf.keras.models.load_model('Src/MLModel/model.h5')

    for blob in blobs:
        if not blob.name.lower().endswith(('jpg', 'jpeg', 'png')):
            continue

        file_path = blob.name
        label = process_and_label(file_path, model)
        if label is not None:
            upload_label_to_firestore(file_path, label, collection_name)

# 이미지 처리 및 Firestore에 결과 저장 실행
process_storage_images_and_save_labels('ml/', 'predicted_data')
