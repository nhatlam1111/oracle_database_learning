# Lộ Trình Học Oracle Database

Chào mừng bạn đến với dự án Học Oracle Database! Lộ trình này được thiết kế để hướng dẫn bạn từ người mới bắt đầu đến trình độ nâng cao trong Oracle Database và SQL. Hãy làm theo các bước được nêu dưới đây để nâng cao hiểu biết và kỹ năng của bạn.

## Kế Hoạch Học Tập

### 1. Giới Thiệu Về Cơ Sở Dữ Liệu
- **Đường Dẫn Bài Học:** `lessons/lesson-1-introduction-to-databases/`
- **Tệp Thực Hành:** `src/` (các script cơ sở dữ liệu mẫu)
- Học về:
  - Cơ sở dữ liệu là gì và tầm quan trọng của nó
  - Các loại cơ sở dữ liệu khác nhau (quan hệ và phi quan hệ)
  - Các tính năng và khả năng của Oracle Database
  - Vai trò của cơ sở dữ liệu trong các ứng dụng hiện đại

### 2. Thiết Lập Môi Trường
- **Đường Dẫn Bài Học:** `lessons/lesson-2-setting-up-environment/`
- **Tệp Thực Hành:** `src/` (các script cơ sở dữ liệu mẫu)
- Học về:
  - Các tùy chọn cài đặt Oracle (XE, Cloud, Docker)
  - Thiết lập Oracle Cloud Free Tier
  - Cấu hình SQL client (SQL Developer, VS Code)
  - Tạo các schema mẫu HR và SALES

### 3. Truy Vấn SQL Cơ Bản
- **Đường Dẫn Bài Học:** `lessons/lesson-3-basic-sql-queries/`
- **Tệp Thực Hành:** `src/basic-queries/`
- Học về:
  - **Kiểu Dữ Liệu Oracle Database** - Hướng dẫn toàn diện về các kiểu dữ liệu tích hợp:
    - Kiểu dữ liệu ký tự (VARCHAR2, CHAR, NVARCHAR2, NCHAR)
    - Kiểu dữ liệu số (NUMBER, INTEGER, FLOAT, BINARY_FLOAT, BINARY_DOUBLE)
    - Kiểu dữ liệu ngày và thời gian (DATE, TIMESTAMP, INTERVAL)
    - Kiểu dữ liệu nhị phân (RAW, LONG RAW)
    - Kiểu đối tượng lớn (CLOB, NCLOB, BLOB, BFILE)
    - Kiểu dữ liệu chuyên biệt (ROWID, UROWID, JSON)
    - Hướng dẫn lựa chọn kiểu dữ liệu và thực hành tốt nhất
  - Câu lệnh SELECT và cú pháp cơ bản
  - Lọc dữ liệu với mệnh đề WHERE
  - Sắp xếp kết quả với ORDER BY
  - Sử dụng các hàm tập hợp (COUNT, SUM, AVG, MIN, MAX)

### 4. Khái Niệm SQL Trung Cấp
- **Đường Dẫn Bài Học:** `lessons/lesson-4-intermediate-sql/`
- **Tệp Thực Hành:** `src/intermediate/`
- Học về:
  - Mối quan hệ bảng và tính toàn vẹn tham chiếu
  - Phép JOIN (INNER, LEFT, RIGHT, FULL OUTER, CROSS)
  - Kỹ thuật join nâng cao (self-joins, anti-joins, semi-joins)
  - Truy vấn con (scalar, multi-row, correlated)
  - Mẫu EXISTS và NOT EXISTS

### 5. Kỹ Thuật SQL Nâng Cao
- **Đường Dẫn Bài Học:** `lessons/lesson-5-advanced-sql/`
- **Tệp Thực Hành:** `src/advanced/`
- Học về:
  - Views và materialized views
  - Sequences, synonyms và các đối tượng cơ sở dữ liệu
  - Stored procedures và functions
  - Triggers và xử lý sự kiện
  - Lập trình PL/SQL nâng cao
  - Xử lý lỗi và debug
  - **Oracle Database Indexes** - Hướng dẫn toàn diện về các loại index và tối ưu hóa:
    - B-Tree indexes (tiêu chuẩn, duy nhất, tổng hợp, dựa trên hàm)
    - Bitmap indexes cho dữ liệu có tính chọn lọc thấp
    - Partitioned indexes và chiến lược global/local
    - Spatial và text indexes cho dữ liệu chuyên biệt
    - Nguyên tắc thiết kế index và tối ưu hóa hiệu suất
    - Bảo trì, giám sát và khắc phục sự cố index

### 6. Thực Hành và Ứng Dụng
- **Đường Dẫn Bài Học:** `lessons/lesson-6-practice-application/`
- **Tệp Thực Hành:** `src/practice/lesson6-comprehensive/`
- Học về:
  - Đánh giá kỹ năng toàn diện và phân tích khoảng cách
  - Các dự án cơ sở dữ liệu thực tế (Thương mại điện tử, HR, Hệ thống tài chính)
  - Kỹ thuật điều chỉnh hiệu suất và tối ưu hóa
  - Chuẩn bị phát triển chuyên môn và chứng chỉ
  - Phát triển dự án capstone
  - Tạo portfolio sẵn sàng cho ngành

### 7. Tài Nguyên Bổ Sung và Tham Khảo
- **Đường Dẫn Tài Liệu:** `docs/`
- **Tệp Tham Khảo:** `docs/notes.md`, liên kết bên ngoài và tài nguyên cộng đồng
- Bộ sưu tập toàn diện về:
  - **Tài Liệu Chính Thức Oracle** - Hướng dẫn tham khảo và sách hướng dẫn đầy đủ
    - Oracle Database Concepts Guide
    - Oracle Database SQL Language Reference
    - Oracle Database Administrator's Guide
    - Oracle Database PL/SQL Language Reference
    - Oracle Database Performance Tuning Guide
  - **Nền Tảng Học Trực Tuyến** - Khóa học và hướng dẫn tương tác
    - Khóa học chính thức Oracle University
    - Oracle Learning Library (tài nguyên miễn phí)
    - Khóa học Oracle Database trên LinkedIn Learning
    - Chuyên môn hóa Oracle trên Coursera
    - Khóa học Oracle thực hành trên Udemy
  - **Tài Nguyên Cộng Đồng** - Diễn đàn, blog và hiểu biết chuyên gia
    - Diễn đàn cộng đồng Oracle và thảo luận
    - Thẻ Oracle Database trên Stack Overflow
    - Cộng đồng Reddit r/oracle
    - Chương trình Oracle ACE và blog chuyên gia
    - Oracle Technology Network (OTN)
  - **Nền Tảng Thực Hành** - Môi trường học thực hành
    - Oracle Live SQL (môi trường SQL trực tuyến miễn phí)
    - Oracle Cloud Free Tier (tài nguyên luôn miễn phí)
    - Thử thách SQL trên HackerRank
    - Bài toán cơ sở dữ liệu trên LeetCode
    - Hướng dẫn tương tác SQLZoo
  - **Tài Nguyên Chứng Chỉ** - Tài liệu phát triển chuyên môn
    - Tổng quan chương trình Chứng chỉ Oracle
    - Hướng dẫn học chính thức cho chứng chỉ
    - Bài thi thực hành và bài thi thử
    - Khóa học chuẩn bị chứng chỉ
    - Lộ trình phát triển chuyên môn
  - **Công Cụ và Tiện Ích Mở Rộng** - Nâng cao năng suất phát triển
    - Oracle SQL Developer (IDE miễn phí)
    - Tiện ích mở rộng Oracle cho VS Code
    - Hỗ trợ Oracle trên DataGrip
    - Toad for Oracle (thương mại)
    - Oracle Enterprise Manager
  - **Sách và Xuất Bản Phẩm** - Tài liệu học tập sâu sắc
    - "Oracle Database 19c: The Complete Reference" của Bob Bryla
    - "Expert Oracle Database Architecture" của Thomas Kyte
    - "Oracle PL/SQL Programming" của Steven Feuerstein
    - "Oracle Performance Tuning" của Richard Niemiec
    - Báo cáo chính thức Oracle và tài liệu kỹ thuật

### 8. Học Tập Liên Tục và Phát Triển Nghề Nghiệp
- **Đường Dẫn Bài Học:** `lessons/lesson-8-continuous-learning/`
- **Tài Nguyên Nghề Nghiệp:** Hướng dẫn phát triển chuyên môn và cơ hội thực tế
- Phát triển toàn diện về:
  - **Kỹ Năng Nâng Cao và Chuyên Môn** - Lộ trình từ trung cấp đến chuyên gia
    - Kỹ thuật điều chỉnh hiệu suất nâng cao và phân tích chi tiết
    - Chiến lược quản trị cơ sở dữ liệu cấp doanh nghiệp
    - Kiến trúc dữ liệu và khoa học dữ liệu với Oracle
    - Triển khai Oracle Cloud và migration strategies
    - Bảo mật cơ sở dữ liệu và quản lý tuân thủ
    - Tự động hóa DevOps và quản lý vòng đời ứng dụng
  - **Công Nghệ Mới Nổi** - Xu hướng tương lai và đổi mới
    - Tích hợp Oracle với Machine Learning và AI
    - Kiến trúc microservices với Oracle Database
    - Blockchain và công nghệ sổ cái phân tán
    - Xử lý dữ liệu thời gian thực và phân tích luồng
    - Oracle Autonomous Database và tự động hóa thông minh
    - Serverless computing và cloud-native architectures
  - **Lộ Trình Chứng Chỉ** - Phát triển chuyên môn có cấu trúc
    - Oracle Database SQL Certified Associate (OCA)
    - Oracle Database Administrator Certified Professional (OCP)
    - Oracle Database Expert Certified Master (OCM)
    - Oracle Cloud Infrastructure certifications
    - Chứng chỉ chuyên biệt (Performance Tuning, Security, Cloud)
    - Kế hoạch học tập và timeline thực tế
  - **Thực Hành và Tiêu Chuẩn Ngành** - Phương pháp chuyên nghiệp
    - Phương pháp luận quản lý dự án cơ sở dữ liệu
    - Thực hành code review và kiểm soát chất lượng
    - Quy trình backup, recovery và disaster planning
    - Chiến lược capacity planning và scaling
    - Tuân thủ bảo mật và audit trails
    - Tài liệu kỹ thuật và knowledge management
  - **Networking và Cộng Đồng** - Kết nối chuyên nghiệp
    - Tham gia Oracle User Groups (OUG) và hội nghị kỹ thuật
    - Đóng góp cho dự án mã nguồn mở và GitHub repositories
    - Viết blog kỹ thuật và chia sẻ kiến thức
    - Mentoring và leadership trong cộng đồng công nghệ
    - Tham gia OpenWorld, Oracle conferences và sự kiện ngành
    - Xây dựng thương hiệu cá nhân trong lĩnh vực Oracle
  - **Kế Hoạch Học Tập Cá Nhân** - Hướng dẫn tự định hướng
    - Đánh giá kỹ năng định kỳ và thiết lập mục tiêu
    - Xây dựng thói quen học tập hàng ngày và hàng tuần
    - Tạo lab environment cá nhân và môi trường thực nghiệm
    - Theo dõi các xu hướng công nghệ và cập nhật kiến thức
    - Tham gia hackathons, challenges và dự án thực tế
    - Phát triển side projects và opensource contributions

## Cấu Trúc Thư Mục

```
oracle-database-learning/
├── README.md                          # Hướng dẫn chính
├── lessons/                           # Tất cả nội dung bài học
│   ├── lesson-1-introduction-to-databases/
│   ├── lesson-2-setting-up-environment/
│   ├── lesson-3-basic-sql-queries/
│   ├── lesson-4-intermediate-sql/
│   ├── lesson-5-advanced-sql/
│   ├── lesson-6-practice-application/
│   ├── lesson-7-additional-resources/
│   └── lesson-8-continuous-learning/
├── src/                               # Tệp SQL thực hành
│   ├── basic-queries/
│   ├── intermediate/
│   ├── advanced/
│   └── practice/
└── docs/                              # Tài liệu bổ sung
    ├── notes.md
    └── references.md
```

## Cách Bắt Đầu

1. **Bắt đầu với Lesson 1** để hiểu các khái niệm cơ bản về cơ sở dữ liệu
2. **Tiến tới Lesson 2** để thiết lập môi trường học tập của bạn
3. **Thực hành với các tệp SQL** trong thư mục `src/` tương ứng với mỗi bài học
4. **Hoàn thành các bài tập** và thử thách trong mỗi bài học
5. **Tham khảo tài liệu bổ sung** khi cần thiết
6. **Tham gia cộng đồng** để hỗ trợ và thảo luận

## Đóng Góp

Chúng tôi hoan nghênh sự đóng góp! Vui lòng đọc hướng dẫn đóng góp và gửi pull request để cải thiện nội dung học tập này.

## Giấy Phép

Dự án này được cấp phép theo Giấy phép MIT - xem tệp [LICENSE](LICENSE) để biết chi tiết.

---

*Chúc bạn học tập vui vẻ với Oracle Database! 🚀*