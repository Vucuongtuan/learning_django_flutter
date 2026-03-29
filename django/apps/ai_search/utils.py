import google.generativeai as genai
from django.conf import settings
import os

# Lấy API Key từ .env (Bạn cần thêm GEMINI_API_KEY vào .env nhé!)
api_key = os.getenv('GEMINI_API_KEY')
if api_key:
    genai.configure(api_key=api_key)

def get_embedding(text):
    """Sử dụng Gemini model 'embedding-001' để biến văn bản thành vector."""
    if not text:
        return None
    try:
        # Gemini thường trả về vector 768 chiều cho model này
        result = genai.embed_content(
            model="models/embedding-001",
            content=text,
            task_type="retrieval_document",
            title="Room search"
        )
        return result['embedding']
    except Exception as e:
        print(f"Lỗi khi lấy embedding: {e}")
        return None
