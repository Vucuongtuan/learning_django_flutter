import os
import asyncio
from django.core.management.base import BaseCommand
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters
from apps.ai_search.utils import process_ai_command

class Command(BaseCommand):
    help = 'Chạy Telegram Bot để điều khiển nhà trọ bằng AI'

    def handle(self, *args, **options):
        token = os.getenv('TELEGRAM_BOT_TOKEN')
        admin_id = os.getenv('TELEGRAM_ADMIN_ID') # Bảo mật: Chỉ ID này mới được ra lệnh

        if not token:
            self.stdout.write(self.style.ERROR("Lỗi: Chưa có TELEGRAM_BOT_TOKEN trong .env"))
            return

        async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
            # Kiểm tra quyền (chỉ cho phép Admin)
            user_id = str(update.effective_user.id)
            if admin_id and user_id != admin_id:
                await update.message.reply_text("Xin lỗi, tôi chỉ phục vụ chủ nhà (Admin) thôi ạ. ID của bạn là: " + user_id)
                return

            text = update.message.text
            await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")
            
            # Gọi bộ não AI xử lý
            response = process_ai_command(text)
            
            await update.message.reply_text(response)

        async def main():
            application = ApplicationBuilder().token(token).build()
            
            text_handler = MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message)
            application.add_handler(text_handler)
            
            print("--- Telegram Bot đã khởi động! Sẵn sàng nhận lệnh ---")
            await application.run_polling()

        try:
            asyncio.run(main())
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"Bot dừng do lỗi: {e}"))
