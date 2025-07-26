**1) Hãy viết câu query lấy ra thông tin nhân viên của những nhân viên có join date từ năm 2010**
    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
 
   **Lưu ý**: 
        - join date, left date format "dd/mm/yyyy"
        - status = A thì hiển thị 'Đang làm việc', status = R thì hiển thị 'Đã nghỉ việc'

**2) Hãy viết câu query lấy ra thông tin nhân viên của những nhân viên có join date trong vòng 6 tháng gần nhất tính tại thời điểm hiện tại (sysdate) về trước 6 tháng**
    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
 
   **Lưu ý**: 
        - join date, left date format "dd/mm/yyyy"
        - status = A thì hiển thị 'Đang làm việc', status = R thì hiển thị 'Đã nghỉ việc'

**3) Hãy viết câu query lấy ra thông tin nhân viên và thâm niên của tất cả nhân viên**
    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
    - thâm niên

**Lưu ý**: 
        - join date, left date format "dd/mm/yyyy"
        - status = A thì hiển thị 'Đang làm việc', status = R thì hiển thị 'Đã nghỉ việc'
        - thâm niên hiển thị 3 cột theo số ngày, số tháng (months_between) , số năm (months_between chia cho 12) làm tròn 2 số thập phân


**4) bổ sung thêm vào câu 3 cột tiền thâm niên**
    Thông tin gồm:
    - Emp id
    - full name
    - join date
    - left date
    - status 
    - thâm niên
    - tiền thâm niên

**Lưu ý**: 
        - join date, left date format "dd/mm/yyyy"
        - status = A thì hiển thị 'Đang làm việc', status = R thì hiển thị 'Đã nghỉ việc'
        - thâm niên hiển thị 3 cột theo số ngày, số tháng, số năm làm tròn 2 số thập phân
        - tiền thâm niên, tính theo tháng:
        
          - >= 6 và < 12: 50k
          - >=12 và < 24: 100k
          - >=24 và < 36: 150k
          - mỗi năm tiếp theo sẽ tăng thêm 50k 
