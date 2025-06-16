# Bài 5: Kỹ Thuật SQL Nâng Cao

Chào mừng đến với cấp độ nâng cao của lập trình Oracle Database! Bài học này bao gồm các khái niệm lập trình cơ sở dữ liệu tinh vi bao gồm stored procedures, functions, triggers, views và lập trình PL/SQL nâng cao.

## 🎯 Mục Tiêu Học Tập

Sau khi hoàn thành bài học này, bạn sẽ có thể:

1. **Tạo và quản lý stored procedures** cho logic business phức tạp
2. **Viết custom functions** cho các tính toán và thao tác có thể tái sử dụng
3. **Triển khai triggers** cho xử lý sự kiện cơ sở dữ liệu tự động
4. **Thiết kế và sử dụng views** cho trừu tượng hóa dữ liệu và bảo mật
5. **Làm việc với sequences và synonyms** cho quản lý đối tượng cơ sở dữ liệu
6. **Thành thạo lập trình PL/SQL** với cấu trúc điều khiển nâng cao
7. **Triển khai xử lý lỗi phù hợp** và kỹ thuật debugging
8. **Áp dụng chiến lược tối ưu hóa hiệu suất** cho SQL nâng cao

## 📚 Điều Kiện Tiên Quyết

Trước khi bắt đầu bài học này, hãy đảm bảo bạn đã hoàn thành:
- ✅ Bài 1: Giới Thiệu về Cơ Sở Dữ Liệu
- ✅ Bài 2: Thiết Lập Môi Trường  
- ✅ Bài 3: Truy Vấn SQL Cơ Bản
- ✅ Bài 4: Khái Niệm SQL Trung Cấp

**Kiến Thức Cần Thiết:**
- Thành thạo các thao tác SELECT, INSERT, UPDATE, DELETE
- Hiểu về JOINs và subqueries
- Quen thuộc với aggregate functions và GROUP BY
- Hiểu biết cơ bản về nguyên tắc thiết kế cơ sở dữ liệu

## 📖 Cấu Trúc Bài Học

### **Phần A: Đối Tượng Cơ Sở Dữ Liệu và Views**
1. **[Views và Materialized Views](1-views-materialized-views.md)**
   - Tạo và quản lý views
   - Materialized views cho hiệu suất
   - Bảo mật và quyền hạn view

2. **[Sequences và Synonyms](2-sequences-synonyms.md)**
   - Sequences tự động tăng
   - Bí danh đối tượng cơ sở dữ liệu với synonyms
   - Thực hành tốt cho đặt tên đối tượng

### **Phần B: Stored Procedures và Functions**
3. **[Stored Procedures](3-stored-procedures.md)**
   - Tạo và thực thi procedures
   - Xử lý parameters và variables
   - Triển khai logic business phức tạp

4. **[Functions và Packages](4-functions-packages.md)**
   - User-defined functions
   - Tạo packages để tổ chức
   - Quyết định Function vs procedure

### **Phần C: Triggers và Tự Động Hóa**
5. **[Triggers](5-triggers.md)**
   - Database event triggers
   - BEFORE, AFTER, và INSTEAD OF triggers
   - Thực hành tốt và hiệu suất trigger

### **Phần D: PL/SQL Nâng Cao**
6. **[Lập Trình PL/SQL Nâng Cao](6-advanced-plsql.md)**
   - Cấu trúc điều khiển và loops
   - Collections và cursors
   - Lập trình Dynamic SQL

7. **[Xử Lý Lỗi và Debugging](7-error-handling-debugging.md)**
   - Chiến lược xử lý exception
   - Kỹ thuật debugging
   - Logging và monitoring

### **Phần E: Tối Ưu Hóa Hiệu Suất**
8. **[Oracle Database Indexes](8-oracle-database-indexes.md)**
   - Các loại index và nguyên tắc thiết kế
   - B-Tree và Bitmap indexes
   - Bảo trì và tối ưu hóa index
   - Giám sát hiệu suất và khắc phục sự cố

## 💻 File Thực Hành

Nằm trong `src/advanced/`:

1. **`views-materialized-views.sql`** - Ví dụ view toàn diện
2. **`sequences-synonyms.sql`** - Quản lý đối tượng cơ sở dữ liệu
3. **`stored-procedures.sql`** - Tạo và thực thi procedure
4. **`functions-packages.sql`** - Ví dụ function và package
5. **`triggers.sql`** - Ví dụ triển khai trigger
6. **`advanced-plsql.sql`** - Lập trình PL/SQL phức tạp
7. **`error-handling.sql`** - Mẫu xử lý exception
8. **`oracle-indexes.sql`** - Ví dụ tạo và tối ưu hóa index
9. **`lesson5-combined-practice.sql`** - Bài tập nâng cao tích hợp

## 🏗️ Cấu Trúc Project

```
lesson-5-advanced-sql/
├── README.md                           # File này
├── 1-views-materialized-views.md       # Lý thuyết views và materialized views
├── 2-sequences-synonyms.md             # Lý thuyết sequences và synonyms
├── 3-stored-procedures.md              # Lý thuyết stored procedures
├── 4-functions-packages.md             # Lý thuyết functions và packages
├── 5-triggers.md                       # Lý thuyết triggers
├── 6-advanced-plsql.md                 # Lý thuyết PL/SQL nâng cao
├── 7-error-handling-debugging.md       # Lý thuyết xử lý lỗi
└── 8-oracle-database-indexes.md        # Tối ưu hóa và thiết kế index
```

## 🎯 Lộ Trình Học Tập

### **Tiến Triển từ Cơ Bản đến Nâng Cao:**

1. **Bắt đầu với Views** (Dễ nhất)
   - Hiểu khái niệm trừu tượng hóa dữ liệu
   - Thực hành tạo view đơn giản

2. **Chuyển sang Sequences và Synonyms**
   - Học quản lý đối tượng cơ sở dữ liệu
   - Hiểu mẫu auto-increment

3. **Thành thạo Stored Procedures**
   - Triển khai logic business trong cơ sở dữ liệu
   - Thực hành truyền parameter

4. **Tiến đến Functions và Packages**
   - Tạo các thành phần code có thể tái sử dụng
   - Tổ chức code một cách chuyên nghiệp

5. **Triển khai Triggers** (Độ khó Trung bình)
   - Tự động hóa các thao tác cơ sở dữ liệu
   - Xử lý kịch bản sự kiện phức tạp

6. **Lập trình PL/SQL Nâng cao** (Thách thức)
   - Thành thạo cấu trúc điều khiển phức tạp
   - Làm việc với collections và cursors

7. **Xử lý Lỗi và Debugging** (Nâng cao nhất)
   - Quản lý lỗi cấp độ chuyên nghiệp
   - Kỹ thuật tối ưu hóa hiệu suất

## ⚡ Kỹ Năng Chính Được Phát Triển

### **Kỹ năng Lập trình Cơ sở dữ liệu:**
- **Lập trình Thủ tục**: Viết logic business phức tạp trong PL/SQL
- **Lập trình Hướng sự kiện**: Tạo database triggers responsive
- **Lập trình Modular**: Tổ chức code với packages và functions
- **Lập trình Hiệu suất**: Tối ưu hóa các thao tác cơ sở dữ liệu

### **Kỹ năng Phát triển Chuyên nghiệp:**
- **Tổ chức Code**: Cấu trúc ứng dụng cơ sở dữ liệu lớn
- **Quản lý Lỗi**: Xử lý exception chuyên nghiệp
- **Tài liệu**: Viết code cơ sở dữ liệu có thể bảo trì
- **Testing**: Debugging và xác thực chương trình cơ sở dữ liệu

## 🔧 Công Cụ và Công Nghệ

### **Tính năng Oracle Database:**
- **PL/SQL Developer**: Chỉnh sửa và debugging code nâng cao
- **Oracle SQL Developer**: GUI cho phát triển cơ sở dữ liệu
- **TOAD/SQL Navigator**: Môi trường phát triển thay thế
- **Oracle Enterprise Manager**: Giám sát và tuning cơ sở dữ liệu

### **Khái niệm Oracle Nâng cao:**
- **Oracle Optimizer**: Hiểu execution plans
- **Oracle Memory Management**: Tối ưu hóa SGA và PGA
- **Oracle Security**: Kiểm soát truy cập dựa trên role
- **Oracle Performance**: Indexing và query tuning

## 📊 Đánh Giá và Thực Hành

### **Dự án Thực hành:**
1. **Hệ thống Quản lý Nhân viên**: Triển khai procedure/function hoàn chỉnh
2. **Hệ thống Theo dõi Hàng tồn kho**: Tự động hóa dựa trên trigger
3. **Framework Báo cáo**: Views và materialized views
4. **Hệ thống Logging Lỗi**: Xử lý lỗi chuyên nghiệp

### **Thách thức Hiệu suất:**
- Tối ưu hóa procedures chạy chậm
- Thiết kế hệ thống trigger hiệu quả
- Tạo views hiệu suất cao
- Triển khai xử lý lỗi có thể mở rộng

## 🚀 Bước Tiếp Theo

Sau khi hoàn thành bài học này:

1. **Bài 6: Thực Hành và Ứng Dụng**
   - Triển khai dự án thực tế
   - Bài tập tuning hiệu suất
   - Review và tối ưu hóa code

2. **Chủ đề Nâng cao để Khám phá:**
   - Oracle Advanced Queuing
   - Oracle Spatial và Graph
   - Oracle Analytics và Data Mining
   - Tích hợp Oracle Cloud Infrastructure

## 💡 Mẹo Học Tập

### **Cho Stored Procedures và Functions:**
- Bắt đầu với procedures đơn giản, dần dần tăng độ phức tạp
- Thực hành truyền parameter kỹ lưỡng
- Tập trung vào các mẫu code có thể tái sử dụng

### **Cho Triggers:**
- Hiểu chuỗi thực thi trigger
- Cẩn thận với tác động hiệu suất của trigger
- Thực hành với kịch bản business thực tế

### **Cho PL/SQL Nâng cao:**
- Thành thạo xử lý cursor cho bộ dữ liệu lớn
- Thực hành xử lý exception một cách toàn diện
- Học dynamic SQL từ từ

### **Cho Hiệu suất:**
- Luôn kiểm tra với khối lượng dữ liệu thực tế
- Sử dụng EXPLAIN PLAN để phân tích truy vấn
- Giám sát tài nguyên hệ thống trong khi testing

## 🔗 Tài Nguyên Bổ Sung

- **Oracle Documentation**: PL/SQL Language Reference
- **Oracle Live SQL**: Môi trường thực hành trực tuyến miễn phí
- **Oracle Learning Library**: Tài liệu đào tạo chính thức
- **Oracle Community**: Forums và nhóm người dùng
- **Oracle University**: Lộ trình chứng chỉ chuyên nghiệp

---

**Sẵn sàng trở thành chuyên gia Oracle Database?** Hãy cùng khám phá các kỹ thuật lập trình SQL nâng cao sẽ nâng kỹ năng cơ sở dữ liệu của bạn lên tầm chuyên nghiệp!

**Thời gian Ước tính**: 20-25 giờ để thành thạo hoàn toàn
**Cấp độ Khó**: Nâng cao (7-9/10)
**Điều kiện tiên quyết**: Cần nền tảng SQL vững chắc
