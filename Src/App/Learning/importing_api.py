from google.cloud import vision
import io

def detect_labels(path):
    """이미지 파일에서 라벨을 감지하고 출력합니다."""
    client = vision.ImageAnnotatorClient()

    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.label_detection(image=image)
    labels = response.label_annotations

    print('Labels:')
    for label in labels:
        print(label.description, label.score)

# 예시 파일 경로
file_path = 'path/to/your/image.jpg'
detect_labels(file_path)
