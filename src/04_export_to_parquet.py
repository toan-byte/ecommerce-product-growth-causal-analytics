# src/04_export_to_parquet.py
import duckdb
import os
import time

db_path = 'data/warehouse/ecommerce.duckdb'
export_folder = 'export'
os.makedirs(export_folder, exist_ok=True)

print("=== HỆ THỐNG KIỂM TRA & XUẤT DỮ LIỆU DUCKDB ===")
print(f"Đang kết nối tới database tại: {db_path}")
con = duckdb.connect(database=db_path, read_only=True)

print("\n--- [BƯỚC 1]: KIỂM TRA CÁC BẢNG HIỆN CÓ ---")
try:
    tables_df = con.execute("SHOW ALL TABLES").df()
    if tables_df.empty:
        print("CẢNH BÁO: Database của bạn hoàn toàn TRỐNG RỖNG!")
        print("Gợi ý: Hãy chắc chắn bạn đã di chuyển vào thư mục 'ecommerce_analytics' và chạy lệnh 'dbt run' thành công.")
        con.close()
        exit()
    else:
        print(tables_df[['schema', 'name']])
except Exception as e:
    print(f"Không thể truy vấn danh sách bảng. Lỗi: {e}")
    con.close()
    exit()

sample_mart = 'mart_daily_kpis'
match = tables_df[tables_df['name'] == sample_mart]

if match.empty:
    print(f"\n[LỖI]: Không tìm thấy bảng '{sample_mart}' trong database này.")
    print("Vui lòng kiểm tra xem bạn đã chạy lệnh 'dbt run' thành công chưa.")
    con.close()
    exit()

schema_name = match.iloc[0]['schema']
print(f"\n-> Xác định các bảng Mart đang nằm trong Schema: '{schema_name}'")

# THÊM BẢNG INTERMEDIATE VÀO DANH SÁCH XUẤT TẠI ĐÂY
marts_to_export = [
    'mart_daily_kpis',
    'mart_funnel',
    'mart_retention',
    'mart_customer_segments',
    'mart_causal_did',
    'mart_brand_performance',
    'int_daily_category_metrics' # Đã bổ sung bảng chẩn đoán ngành hàng toàn diện!
]

print("\n--- [BƯỚC 2]: BẮT ĐẦU XUẤT FILE PARQUET ---")
start_time = time.time()

for mart in marts_to_export:
    if mart in tables_df['name'].values:
        # Tự động xác định schema thực tế của bảng đó từ danh sách SHOW ALL TABLES
        current_schema = tables_df[tables_df['name'] == mart].iloc[0]['schema']
        mart_start = time.time()
        output_path = os.path.join(export_folder, f"{mart}.parquet")
        
        print(f"Đang xuất: {current_schema}.{mart} -> {output_path}...")
        con.execute(f"COPY {current_schema}.{mart} TO '{output_path}' (FORMAT 'PARQUET', COMPRESSION 'SNAPPY')")
        print(f"-> Xuất thành công trong {time.time() - mart_start:.2f} giây")
    else:
        print(f"Bỏ qua {mart} (Không tìm thấy bảng trong database)")

con.close()
print(f"\n=== HOÀN THÀNH TRONG {time.time() - start_time:.2f} GIÂY ===")