# 📄 Tài liệu Kỹ thuật API - Hệ thống Quản lý Nhà trọ Thông minh (AI-Powered)

**Đối tượng:** Developer Frontend, AI Agents, Hệ thống tích hợp.
**Base URL:** `http://localhost:8000/api/`
**Định dạng:** JSON (UTF-8)

---

## 🔐 1. Xác thực & Bảo mật (Authentication)
Hệ thống sử dụng **JSON Web Token (JWT)** cho tất cả các yêu cầu.

### Quy trình đăng ký & Kích hoạt
1. **Đăng ký:** `POST /api/register/` (Gửi thông tin user, tài khoản sẽ ở trạng thái chờ).
2. **Kích hoạt:** Admin click link trong email (`GET /api/activate/<uid>/<token>/`) để kích hoạt tài khoản.
3. **Đăng nhập:** `POST /api/token/` để lấy Access Token.

### Cách sử dụng Token
Thêm vào Header của mọi request:
* **Header:** `Authorization: Bearer <access_token>`

---

## 🤖 2. Tính năng AI & Vector Search (RAG)
Hệ thống tích hợp Gemini AI và PostgreSQL `pgvector` để tìm kiếm theo ý nghĩa (Semantic Search).

### 2.1 Tìm kiếm phòng thông minh
Tìm kiếm phòng dựa trên nhu cầu ngôn ngữ tự nhiên thay vì chỉ dùng filter cứng.
* **Endpoint:** `POST /api/ai/search_rooms/`
* **Payload:** 
  ```json
  {
    "query": "Tìm phòng giá rẻ dưới 3 triệu cho 2 người ở, có ban công",
    "limit": 5
  }
  ```
* **Cơ chế:** AI sẽ biến `query` thành vector và so sánh với vector của các phòng trong DB để tìm kết quả phù hợp nhất.

### 2.2 Tự động tạo Embedding (Background Task)
* Mỗi khi thêm/sửa Phòng (`Room`), hệ thống sẽ tự động gửi một task vào **Celery (Redis)** để gọi Gemini API lấy Vector.
* Quá trình này diễn ra ngầm, không làm chậm tốc độ phản hồi của API chính.

---

## 🏗️ 3. Các Module Nghiệp vụ Chính

### 3.1 Quản lý Phòng (`/rooms/`)
* **Trạng thái (`status`):** `available` (Trống), `booked` (Đã cọc), `occupied` (Đang ở), `maintenance` (Bảo trì).
* **Lưu ý:** Khi tạo Hợp đồng (`Lease`) ở trạng thái `active`, phòng sẽ tự chuyển sang `occupied`.

### 3.2 Khách thuê (`/tenants/`)
* Quản lý thông tin định danh và hồ sơ khách hàng.
* Mỗi khách thuê có thể liên kết với một User account để nhận thông báo.

### 3.3 Hợp đồng thuê (`/leases/`)
* Kết nối khách thuê và phòng. 
* Chứa thông tin ngày dọn vào, tiền thuê, tiền cọc.

### 3.4 Ghi chỉ số Điện/Nước (`/utilities/`)
* **Endpoint:** `POST /api/utilities/readings/`
* **Quy tắc:** `current_reading` phải >= `previous_reading`. 
* **Tháng tính:** `billing_month` định dạng `YYYY-MM-01`.

### 3.5 Hóa đơn & Thanh toán (`/billing/`)
Hỗ trợ quản lý hóa đơn tháng và giảm giá.

* **Tự động tạo hóa đơn:** `POST /api/billing/invoices/generate/`
  * Payload: `{"lease_id": 1, "billing_month": "2024-03-01"}`
  * Logic: Tự gom tiền phòng + tiền điện + tiền nước - giảm giá.
* **Xác nhận thanh toán:** `POST /api/billing/invoices/{id}/mark_as_paid/`
  * Hệ thống sẽ tự gửi thông báo Push (FCM) và thông báo trong app cho khách thuê.
* **Giảm giá hàng loạt:** `POST /api/billing/discounts/bulk_apply/`
  * Áp dụng giảm giá cho toàn bộ phòng hoặc một danh sách phòng cụ thể (ví dụ: Giảm 200k tiền phòng dịp Tết).

---

## 🔔 4. Thông báo (Notifications)
Hệ thống hỗ trợ thông báo đa kênh:
* **In-app:** Lưu trong DB, xem tại `/api/notifications/`.
* **Push Notification:** Tích hợp Firebase Cloud Messaging (FCM).
* **Tự động:** Hệ thống tự gửi thông báo khi: Thay đổi giá phòng, Có hóa đơn mới, Thanh toán thành công, Nhắc nợ.

---

## 🛠️ 5. Công cụ Hỗ trợ (CLI & Docker)
Dành cho người quản trị vận hành hệ thống qua Docker:

* **Khởi động:** `docker-compose up -d`
* **Đồng bộ AI Vector (cho dữ liệu cũ):** 
  ```bash
  docker-compose exec web python manage.py sync_embeddings
  ```
* **Xem Log AI Worker:**
  ```bash
  docker-compose logs -f worker
  ```

---

## 📦 6. Bảng mã lỗi (Response Codes)
* `200 OK`: Thành công.
* `201 Created`: Tạo mới thành công.
* `400 Bad Request`: Lỗi dữ liệu đầu vào (Ví dụ: Chỉ số điện mới nhỏ hơn chỉ số cũ).
* `401 Unauthorized`: Token hết hạn hoặc không hợp lệ.
* `403 Forbidden`: Không có quyền truy cập (Ví dụ: Khách thuê sửa hóa đơn của chủ nhà).
* `500 Internal Server Error`: Lỗi hệ thống hoặc lỗi kết nối AI API.
