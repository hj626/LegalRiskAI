import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

MODEL_DIR = "./saved_mode3"

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# tokenizer 로드
tokenizer = AutoTokenizer.from_pretrained(MODEL_DIR)

# 모델 로드
model = AutoModelForSequenceClassification.from_pretrained(MODEL_DIR)
model.to(device)
model.eval()


def predict(text):
    inputs = tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        padding=True,
        max_length=512
    ).to(device)

    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.softmax(outputs.logits, dim=1)
        pred = torch.argmax(probs, dim=1).item()

    return pred, probs[0].cpu().tolist()


if __name__ == "__main__":
    test = "임대차 계약 해지 관련 분쟁입니다."
    pred, probs = predict(test)

    print("예측 클래스:", pred)
    print("확률 분포:", probs)
