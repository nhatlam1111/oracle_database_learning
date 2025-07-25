/*
    1) viết câu query để lấy ra thông tin nhân viên (mã nhân viên, họ tên, ngày sinh, giới tính, join date) 
    của những nhân viên có join date từ 2010 trở đi   
    Lưu ý: - join date hiển thị theo định dạng 'DD-MM-YYYY'.
*/


/*
    2) viết câu query để lấy ra thông tin nhân viên (mã nhân viên, họ tên, ngày sinh, giới tính, join date) 
    của những nhân viên có join date trong khoảng 6 tháng gần nhất (tính từ ngày hiện tại).
    Lưu ý: - join date hiển thị theo định dạng 'DD-MM-YYYY'.

    Gợi ý:  - sử dụng hàm ADD_MONTHS để tính ngày join date 6 tháng trước theo SYSDATE.
            - ngày hiện tại có thể sử dụng  SYSDATE.
*/



/*
    3) viết câu query để lấy ra thông tin nhân viên (mã nhân viên, họ tên, ngày sinh, giới tính, join date, thâm niên) 
    của những nhân viên hiện đang làm việc (status = 'A'). 
    Lưu ý: - tính thâm niên của nhân viên đến ngày hiện tại và tính theo cả 3 đơn vị (năm, tháng, ngày) và round 2.
           - join date hiển thị theo định dạng 'DD-MM-YYYY'.
           

    Gợi ý:- sử dụng hàm MONTHS_BETWEEN để tính số tháng.
          - ngày hiện tại có thể sử dụng  SYSDATE.
          - Cùng kiểu dữ liệu Date thì có thể cộng/trừ trực tiếp để tính số ngày.          
*/



/*
    4) viết câu query để lấy ra thông tin nhân viên (mã nhân viên, họ tên, ngày sinh, giới tính, join date, left date, thâm niên, status) 
    của tất cả nhân viên trong bảng nhân viên.
    Lưu ý: - tính thâm niên của nhân viên đến ngày hiện tại và tính theo cả 3 đơn vị (năm, tháng, ngày) và round 2.
           - status của nhân viên là 'A' thì tính thâm niên đến ngày hiện tại, 'R' thì tính thâm niên đến ngày nghỉ việc (left_dt).
           - status của nhân viên là 'A' thì hiển thị 'Đang làm việc', 'R' thì hiển thị 'Đã nghỉ việc'
           - join date hiển thị theo định dạng 'DD-MM-YYYY'.

    Gợi ý:- sử dụng decode status để phân loại status hiển thị.
          - sử dụng decode status để phân loại ngày tính thâm niên
*/


/*
    5) sử dụng câu query ở bài 4, bổ sung thêm cột tiền thâm niên của nhân viên
    Lưu ý: - tiền thâm niên được tính theo công thức: 
            - dưới 6 tháng: 0 đồng
            - từ 6 tháng đến dưới 1 năm: 500.000 đồng
            - từ 1 năm đến dưới 2 năm: 1.000.000 đồng
            - từ 2 năm đến dưới 3 năm: 1.500.000 đồng
            - từ 3 năm trở lên: 2.000.000 đồng

    Gợi ý: - sử dụng hàm case when để phân loại tính tiền thâm niên.
*/


/*
    6) sử dụng câu query ở bài 4, bổ sung thêm điều kiện lọc để chỉ lấy ra những nhân viên có thâm niên từ 5 năm đến dưới 10 năm.

    Gợi ý: - sử dụng between ... and ... để lọc.
*/


/*
    7) viết câu query để lấy thông tin nhân viên của một mã nhân viên cụ thể để hiển thị thông tin trên report hợp đồng dạng file WORD.
    Thông tin hiển thị bao gồm:
    - Mã nhân viên
    - Họ tên
    - Ngày (dd), tháng (mm), năm (yyyy) sinh (3 cột riêng biệt)
    - Giới tính
    - Ngày bắt đầu hợp đồng (định dạng 'DD-MM-YYYY')
    - Ngày kết thúc hợp đồng (định dạng 'DD-MM-YYYY')
    - địa chỉ
    - Số điện thoại
    - mức lương cơ bản (format tiền tệ, có dấu phân cách hàng nghìn, làm tròn 2 chữ số thập phân)

    Gợi ý: - sử dụng hàm to_char kết hợp to_date để định dạng ngày tháng.
           - sử dụng hàm to_char với định dạng tiền tệ để hiển thị mức lương cơ bản.
           - sử dụng hàm substr để lấy ngày, tháng, năm từ ngày sinh, hoặc to_date sau đó to_char.
*/


/*
    8) sử dụng bảng thr_month_salary để lấy ra lương thực lãnh (net_amt) của 1 nhân viên cụ thể tất cả các tháng làm việc.
    thông tin hiển thị bao gồm:
    - Mã nhân viên
    - Họ tên
    - Tháng lương(mm/yyyy)
    - lương net

    gợi ý: - sử dụng hàm to_char kết hợp to_date để định dạng tháng lương.
*/


/*
    9) từ câu query ở bài 8, thể hiện lương thực lãnh lớn nhất, nhỏ nhất, trung bình đã nhận của nhân viên đó.
    thông tin hiển thị bao gồm:
    - Mã nhân viên
    - Họ tên
    - Lương thực lãnh lớn nhất
    - Lương thực lãnh nhỏ nhất
    - Lương thực lãnh trung bình

    Gợi ý: - sử dụng hàm max, min, avg để tính lương thực lãnh lớn nhất, nhỏ nhất, trung bình.
*/


/*
    10) từ câu query ở bài 9, thay vì điều kiện lọc theo một mã nhân viên cụ thể, hãy thể hiện lương thực lãnh lớn nhất, nhỏ nhất, trung bình của tất cả nhân viên.
    thông tin hiển thị bao gồm:
    - Mã nhân viên
    - Họ tên
    - Lương thực lãnh lớn nhất
    - Lương thực lãnh nhỏ nhất
    - Lương thực lãnh trung bình

    Gợi ý: - sử dụng hàm max, min, avg để tính lương thực lãnh lớn nhất, nhỏ nhất, trung bình.
           - sử dụng group by để nhóm theo mã nhân viên.
*/