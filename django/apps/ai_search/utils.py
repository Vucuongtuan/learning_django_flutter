import google.generativeai as genai
import os
from .tools import AI_TOOLS

def get_embedding(text):
    """Sử dụng Gemini model 'embedding-001' để biến văn bản thành vector."""
    if not text:
        return None
    try:
        genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
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

def process_ai_command(user_message):
    """Xử lý lệnh bằng Gemini AI với khả năng gọi hàm (Agentic AI)."""
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        return "Lỗi: Chưa cấu hình GEMINI_API_KEY trong file .env"

    genai.configure(api_key=api_key)
    
    # Cấu hình AI với danh sách các Tools đã định nghĩa
    tools_list = list(AI_TOOLS.values())
    model = genai.GenerativeModel(
        model_name='gemini-1.5-flash',
        tools=tools_list
    )
    
    # Kích hoạt tính năng tự động gọi hàm
    chat = model.start_chat(enable_automatic_function_calling=True)
    
    system_instruction = (
        "Bạn là trợ lý ảo quản lý nhà trọ chuyên nghiệp. "
        "Hãy trả lời thân thiện bằng tiếng Việt. "
        "Nếu khách yêu cầu nhắn tin hay tìm hóa đơn, hãy dùng công cụ. "
        "Nếu chưa đủ thông tin, hãy hỏi lại khách."
    )
    
    try:
        response = chat.send_message(f"{system_instruction}\n\nLệnh: {user_message}")
        return response.text
    except Exception as e:
        return f"Lỗi hệ thống AI: {str(e)}"
