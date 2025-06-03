# Bài Học 1: Giới Thiệu Về Cơ Sở Dữ Liệu

Chào mừng bạn đến với bài học đầu tiên của Lộ Trình Học Oracle Database! Bài học này cung cấp một giới thiệu toàn diện về cơ sở dữ liệu, với trọng tâm đặc biệt là các nguyên tắc cơ bản và kiểu dữ liệu của Oracle Database.

## Mục Tiêu Học Tập

Sau khi hoàn thành bài học này, bạn sẽ:
- Hiểu cơ sở dữ liệu là gì và tại sao chúng quan trọng
- Biết sự khác biệt giữa cơ sở dữ liệu quan hệ và phi quan hệ
- Quen thuộc với các tính năng và khả năng chính của Oracle Database
- Hiểu vai trò của cơ sở dữ liệu trong các ứng dụng hiện đại

## Cấu Trúc Bài Học

### 1. Cơ Sở Dữ Liệu Là Gì?
**Tệp:** `1-what-is-database.md`
- Định nghĩa và tầm quan trọng của cơ sở dữ liệu
- Vai trò của cơ sở dữ liệu trong các ứng dụng hiện đại
- Cơ sở dữ liệu so với hệ thống tệp
- Các khái niệm và thuật ngữ cơ bản về cơ sở dữ liệu

### 2. Các Loại Cơ Sở Dữ Liệu
**Tệp:** `2-database-types.md`
- Cơ sở dữ liệu quan hệ (RDBMS)
- Cơ sở dữ liệu phi quan hệ (NoSQL)
- So sánh và trường hợp sử dụng
- Khi nào nên chọn từng loại

### 3. Các Tính Năng Của Oracle Database
**Tệp:** `3-oracle-database-features.md`
- **Tổng Quan Kiến Trúc Oracle Database** - Cấu trúc cây hoàn chình hiển thị:
  - Database Instance (Bộ nhớ + Các tiến trình nền)
  - Cấu trúc lưu trữ vật lý và logic
  - Các đối tượng Schema và tổ chức
  - Kết nối client và dịch vụ mạng
- Khả năng mở rộng và hiệu suất
- Tính năng khả dụng cao và bảo mật
- Khả năng đa mô hình và phân tích nâng cao
- Tích hợp cloud và các tính năng doanh nghiệp

## Ví Dụ Thực Hành

### Thực Hành Khái Niệm Cơ Sở Dữ Liệu
Mặc dù bài học này tập trung vào lý thuyết, bạn có thể khám phá các script cơ sở dữ liệu mẫu trong `../../src/` để xem các ví dụ thực tế về cách cấu trúc và sử dụng cơ sở dữ liệu.

## Điểm Chính Cần Ghi Nhớ

### Nguyên Tắc Cơ Bản Về Cơ Sở Dữ Liệu
1. **Cơ sở dữ liệu** cung cấp lưu trữ dữ liệu có cấu trúc, đáng tin cậy và hiệu quả
2. **Cơ sở dữ liệu quan hệ** sử dụng các bảng với mối quan hệ giữa chúng
3. **Oracle Database** là một RDBMS cấp doanh nghiệp với các tính năng nâng cao

### Thành Thạo Kiểu Dữ Liệu
*Lưu ý: Các kiểu dữ liệu sẽ được đề cập chi tiết trong Bài học 3 khi bạn bắt đầu tạo bảng và làm việc với SQL.*

### Thực Hành Tốt Nhất
1. **Chọn đúng kích thước kiểu dữ liệu** - đừng phân bổ quá mức
2. **Sử dụng ràng buộc** để duy trì tính toàn vẹn dữ liệu
3. **Xem xét Unicode** cho các ứng dụng quốc tế
4. **Ghi chép lựa chọn của bạn** để tham khảo sau này
5. **Kiểm tra hiệu suất** với khối lượng dữ liệu thực tế

## Bài Tập và Thực Hành

### Bài Tập 1: Khái Niệm Cơ Sở Dữ Liệu
Nghiên cứu và giải thích sự khác biệt giữa:
- Cơ sở dữ liệu RDBMS vs NoSQL
- Bảng vs Bộ sưu tập
- Ngôn ngữ truy vấn SQL vs NoSQL
- Tính chất ACID vs nguyên tắc BASE

### Bài Tập 2: Các Tính Năng Oracle Database
Liệt kê ba tính năng Oracle Database quan trọng cho:
- Một ứng dụng ngân hàng
- Một website thương mại điện tử
- Một nền tảng phân tích dữ liệu

### Bài Tập 3: Tư Duy Thiết Kế Cơ Sở Dữ Liệu
Đối với hệ thống quản lý thư viện, xác định các loại dữ liệu cần được lưu trữ và cách chúng có thể được tổ chức (chưa cần lo lắng về các kiểu dữ liệu cụ thể - điều đó sẽ được đề cập trong Bài học 3!).

## Điều Kiện Tiên Quyết
- Hiểu biết cơ bản về dữ liệu là gì
- Quen thuộc với khái niệm thông tin có cấu trúc
- Không cần kinh nghiệm cơ sở dữ liệu trước đó

## Bước Tiếp Theo
Sau khi hoàn thành bài học này, bạn sẽ sẵn sàng cho:
- **Bài học 2**: Thiết Lập Môi Trường Oracle
- Cài đặt Oracle Database hoặc sử dụng Oracle Cloud
- Cấu hình SQL client và công cụ phát triển
- Tạo schema cơ sở dữ liệu đầu tiên

## Tài Nguyên Bổ Sung

### Tài Liệu
- Oracle Database Concepts Guide
- Oracle Database SQL Language Reference
- Oracle Database Administrator's Guide

### Tài Nguyên Trực Tuyến
- Oracle Learning Library
- Oracle Database Documentation
- Oracle Community Forums

### Công Cụ
- Oracle SQL Developer
- Oracle Cloud Free Tier
- VS Code với tiện ích mở rộng Oracle

## Đánh Giá

Trước khi chuyển sang bài học tiếp theo, hãy đảm bảo bạn có thể:
- [ ] Giải thích sự khác biệt giữa cơ sở dữ liệu quan hệ và phi quan hệ
- [ ] Liệt kê các tính năng chính của Oracle Database
- [ ] Hiểu vai trò của cơ sở dữ liệu trong các ứng dụng hiện đại
- [ ] Xác định các trường hợp sử dụng phù hợp cho các loại cơ sở dữ liệu khác nhau

## Thời Gian Ước Tính
- **Đọc**: 30-45 phút
- **Bài tập**: 30-45 phút
- **Tổng cộng**: 1-1.5 giờ

---

**Sẵn sàng tiếp tục?** Chuyển sang [Bài học 2: Thiết Lập Môi Trường](../lesson-2-setting-up-environment/) để bắt đầu làm việc thực tế với Oracle Database!
