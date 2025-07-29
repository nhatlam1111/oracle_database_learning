**Lưu ý:**

    - Tên cột (alias) có thể đặt tự do miễn thể hiện đúng ý nghĩa
    - Lưu Ý Quan Trọng Khi Sử Dụng WHERE tại bải 3-where-clause-filtering
    - Các hàm convert kiểu dữ liệu có thể tham khảo bên bài tham khảo 1-oracle-datatypes-conversion-functions
    - tham khảo các hàm được sử dụng trong bài tập bên dưới cuối bài tập

# QUERY CƠ BẢN (SELECT ... FROM ... WHERE ...)

## Câu 1 - 5 sử dụng table THR_EMPLOYEE

### 1) Hãy viết câu query lấy ra thông tin nhân viên của những nhân viên có join date từ năm 2010

    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
 
**Lưu ý**:

    - join date, left date format về định dạng text "dd/mm/yyyy"
    - status = A hoặc có left date > sysdate thì hiển thị 'Đang làm việc', status = R và có left date <= sysdate thì hiển thị 'Đã nghỉ việc'

**Gợi ý:**

    - Cột join date, left date đang là kiểu varchar có giá trị định dạng 'YYYYMMDD' nên sử dụng TO_DATE đưa về kiểu DATE, sau đó TO_CHAR lại để đưa về "dd/mm/yyyy"
    - cột status đang có 2  giá trị là 'A' và 'R', hãy sử dụng CASE ... WHEN ... (mục 11.Logic Điều Kiện với CASE tại bài 2-select-statements)

### 2) Từ câu query của bài 1 thay thế điều kiệu join date từ năm 2010 thanh join date trong vòng 6 tháng gần nhất tính tại thời điểm hiện tại (sysdate) về trước 6 tháng

**Gợi ý:**
    - Sử dụng hàm ADD_MONTHS để tính toán thời gian 6 tháng trước sysdate


### 3) Từ câu query của bài 1 bổ sung điều kiện (3.1, 3.2 là 2 câu query):

    3.1) nhân viên có tên bắt đầu bằng họ "Nguyễn" 
    3.2) nhân viên có tên "Hà" với họ và tên đệm bất kỳ

**Gợi ý:**

    - Sử dụng LIKE để tìm kiếm họ hoặc tên nhân viên

### 4) Hãy viết câu query lấy ra thông tin nhân viên và thâm niên của tất cả nhân viên

    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
    - thâm niên

**Lưu ý**:

    - thâm niên tính đến thời điểm hiện tại (sysdate), nếu nhân viên đã nghỉ việc thì tính đến left date (left date phải <= sysdate)
    - thâm niên hiển thị 3 cột theo số ngày, số tháng, số năm làm tròn 2 số thập phân (nếu có)

**Gợi ý:**

    - Cột join date, left date đang là kiểu varchar có giá trị định dạng 'YYYYMMDD' nên sử dụng TO_DATE đưa về kiểu DATE
    - tính thâm niên bằng cách lấy sysdate hoặc left date trừ đi join date (cùng kiểu DATE)
    - Sử dụng hàm MONTHS_BETWEEN để tính số tháng thâm niên, sau đó sử dụng hàm ROUND để làm tròn 2 số thập phân
    - tính số năm thâm niên bằng cách lấy số tháng thâm niên chia cho 12, sau đó sử dụng hàm ROUND để làm tròn 2 số thập phân

### 5) bổ sung thêm vào câu 4 cột tiền thâm niên

    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
    - thâm niên
    - tiền thâm niên

**Lưu ý**:

      - thâm niên hiển thị 3 cột theo số ngày, số tháng, số năm làm tròn 2 số thập phân
      - tiền thâm niên, tính theo tháng:        
        * >= 6 và < 12: 50k
        * >=12 và < 24: 100k
        * >=24 và < 36: 150k
        * mỗi năm tiếp theo sẽ tăng thêm 50k 

**Gợi ý:**
    - Sử dụng CASE ... WHEN ... để tính tiền thâm niên theo từng khoảng thời gian
    - Tiền thâm niên được tính theo tháng, nên cần lấy số tháng thâm niên từ câu 4

## Tham Khảo Hàm Được Sử Dụng Trong Bài Tập

### Hàm Chuyển Đổi Ngày Tháng 
- **TO_DATE(string, format)**: Chuyển đổi chuỗi văn bản thành kiểu dữ liệu DATE
- **TO_CHAR(date, format)**: Chuyển đổi ngày tháng thành chuỗi văn bản với định dạng chỉ định
- **[ADD_MONTHS(date, number)](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/ADD_MONTHS.html#GUID-B8C74443-DF32-4B7C-857F-28D557381543)**: Thêm hoặc bớt số tháng từ một ngày

### Hàm Tính Toán Thời Gian
- **[MONTHS_BETWEEN(date1, date2)](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/MONTHS_BETWEEN.html#GUID-E4A1AEC0-F5A0-4703-9CC8-4087EB889952)**: Tính số tháng giữa hai ngày
- **SYSDATE**: Lấy ngày giờ hiện tại của hệ thống
- **date1 - date2**: Tính số ngày giữa hai ngày (kiểu DATE)

### Hàm Tìm Kiếm Chuỗi
- **LIKE**: Tìm kiếm theo mẫu với ký tự đại diện (% cho nhiều ký tự, _ cho một ký tự)

### Logic Điều Kiện
- **CASE WHEN ... THEN ... ELSE ... END**: Tạo điều kiện phân nhánh trong SQL

### Hàm Làm Tròn
- **ROUND(number, decimal_places)**: Làm tròn số với số chữ số thập phân chỉ định
- **FLOOR(number)**: Làm tròn xuống số nguyên gần nhất

# QUERY VỚI GROUP BY VÀ ORDER BY

## Câu 6 - 10 sử dụng table THR_MONTH_SALARY

### 6) Hãy viết câu query lấy ra thông tin lương thực lãnh của một nhân viên cụ thể trong toàn bộ thời gian làm việc

    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - tháng lương 
    - NET amt

### 7.a) từ câu query của bài 6, bỏ cột tháng lương và NET amt và các cột thông tin nhân viên, tính tổng lương, lương trung bình, lương cao nhất, lương thấp nhất của nhân viên đó

    Thông tin gồm:
    - tổng lương
    - lương trung bình
    - lương cao nhất
    - lương thấp nhất

**Gợi ý:**

    - Phần note trong Mệnh Đề GROUP BY về select KHÔNG sử dụng GROUP BY trong bài 5-group-by-and-aggregate-functions
    - Sử dụng hàm SUM, AVG, MAX, MIN để tính tổng lương, lương trung bình, lương cao nhất, lương thấp nhất

### 7.b) từ câu query của bài 6, loại bỏ điều kiện nhân viên cụ thể, tính tổng lương, lương trung bình, lương cao nhất, lương thấp nhất theo từng nhân viên, sắp xếp tăng dần theo mã nhân viên

    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - tổng lương
    - lương trung bình
    - lương cao nhất
    - lương thấp nhất

 **Gợi ý:**

    - Mệnh Đề GROUP BY và lưu ý Phần note trong Mệnh Đề GROUP BY về select CÓ sử dụng GROUP BY trong bài 5-group-by-and-aggregate-functions
    - Group by theo thông tin nhân viên Emp id, full name, join date, left date
    - Sử dụng hàm SUM, AVG, MAX, MIN để tính tổng lương, lương trung bình, lương cao nhất, lương thấp nhất

### 8) Thống kê lương thực lãnh của từng nhân viên trong một năm cụ thể, hiển thị 12 cột tháng lương của nhân viên đó, sắp xếp theo tổng lương giảm dần

    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - tháng 1
    - tháng 2
    - tháng 3
    - tháng 4
    - tháng 5
    - tháng 6
    - tháng 7
    - tháng 8
    - tháng 9
    - tháng 10
    - tháng 11
    - tháng 12
    - Tổng lương

**Gợi ý:**

    - Tương tự như câu 7.b, mỗi tháng lương sẽ là một cột, kết hợp hàm SUM và hàm CASE ... WHEN ... để phân tách theo từng tháng 

### 9) Thống kê lương trong một tháng cụ thể bộ phận (3 cấp bộ phận), sắp xếp lại theo sequence của bộ phận (3 cấp bộ phận)

    thông tin gồm:
    - ORG_LEVEL1_NM
    - ORG_LEVEL2_NM
    - ORG_LEVEL3_NM
    - tổng số lượng nhân viên
    - số lượng nhân viên nghỉ việc
    - tổng lương

### 10) sử dụng câu query của bài 9, bổ sung thêm điều kiện lọc bộ phận có tổng lương <= 100 triệu và tổng số lượng nhân viên <= 10

    thông tin gồm:
    - ORG_LEVEL1_NM
    - ORG_LEVEL2_NM
    - ORG_LEVEL3_NM
    - tổng số lượng nhân viên
    - số lượng nhân viên nghỉ việc
    - tổng lương



## Tham Khảo Hàm Được Sử Dụng Trong Bài Tập

### Hàm Tổng Hợp (Aggregate Functions)
- **SUM()**: Tính tổng các giá trị
- **AVG()**: Tính giá trị trung bình
- **MAX()**: Tìm giá trị lớn nhất
- **MIN()**: Tìm giá trị nhỏ nhất
- **COUNT()**: Đếm số lượng bản ghi

### Nhóm Dữ Liệu
- **GROUP BY**: Nhóm các bản ghi theo một hoặc nhiều cột để sử dụng với hàm tổng hợp

