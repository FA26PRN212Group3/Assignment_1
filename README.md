# CampusLost · PRN212 Assignment 1

## 1. Giới thiệu

CampusLost giúp sinh viên trong trường và ký túc xá báo mất, đăng tin nhặt được đồ và liên hệ với người đăng để trao trả. Ứng dụng có ba luồng chính:

1. Xem danh sách tin, tìm theo tên đồ vật và lọc theo loại tin.
2. Đăng tin **Bị mất** hoặc **Nhặt được**.
3. Mở chi tiết tin để xem địa điểm, mô tả và thông tin liên hệ.

| Công nghệ | Dùng để làm gì và áp dụng ở đâu |
| --- | --- |
| ASP.NET Core MVC | Tách điều hướng, xử lý yêu cầu, dữ liệu và giao diện để dễ theo dõi luồng web. Đăng ký MVC và route trong [Program.cs](PRN212_Assignment1/CampusLost/Program.cs), xử lý yêu cầu trong [PostsController.cs](PRN212_Assignment1/CampusLost/Controllers/PostsController.cs). |
| Razor Views | Kết hợp HTML với dữ liệu C# và dùng Tag Helpers để tạo form, liên kết và thông báo lỗi. Ba màn hình nằm trong [Views/Posts](PRN212_Assignment1/CampusLost/Views/Posts). |
| Entity Framework Core | Dùng LINQ để truy vấn và lưu đối tượng C#, phù hợp với các thao tác đọc, lọc và thêm tin. Provider SQL Server 8.0.25 được khai báo trong [CampusLost.csproj](PRN212_Assignment1/CampusLost/CampusLost.csproj), mapping nằm trong [CampusLostDbContext.cs](PRN212_Assignment1/CampusLost/Data/CampusLostDbContext.cs). |
| SQL Server | Lưu tin bền vững, hỗ trợ dữ liệu tiếng Việt và ràng buộc dữ liệu tại bảng. Schema và dữ liệu mẫu nằm trong [CampusLostDb.sql](CampusLostDb.sql). |
| Visual Studio | Mở solution, build và debug để theo dõi request từ controller đến database. Dùng [PRN212_Assignment1.sln](PRN212_Assignment1/PRN212_Assignment1.sln) và [launchSettings.json](PRN212_Assignment1/CampusLost/Properties/launchSettings.json). |
| Codex CLI | Hỗ trợ đọc source, sửa và build từ terminal trong Visual Studio. Ví dụ demo tập trung vào [PostsController.cs](PRN212_Assignment1/CampusLost/Controllers/PostsController.cs) và [Index.cshtml](PRN212_Assignment1/CampusLost/Views/Posts/Index.cshtml). |

## 2. Chạy lần đầu

### Chuẩn bị môi trường và clone

- Cài **.NET 8 SDK** theo target `net8.0` trong [CampusLost.csproj](PRN212_Assignment1/CampusLost/CampusLost.csproj). Kiểm tra bằng `dotnet --list-sdks`.
- Trên Windows, dùng **Visual Studio 2022** hỗ trợ .NET 8 và cài workload **ASP.NET and web development**. Chuẩn bị **SQL Server Database Engine** và **SQL Server Management Studio (SSMS)**.
- Clone repo bằng URL trên trang GitHub. Các lệnh tiếp theo trong README chạy từ thư mục gốc sau khi clone.

```powershell
git clone https://github.com/FA26PRN212Group3/Assignment_1.git CampusLost
cd CampusLost
```

### Tạo database bằng SSMS

1. Mở SSMS, kết nối **Database Engine** bằng **Windows Authentication**. Ghi lại **Server name** của instance kết nối thành công.
2. Mở [CampusLostDb.sql](CampusLostDb.sql) ở **gốc repo** bằng **File → Open → File**. Chạy toàn bộ file bằng **Execute** hoặc **F5** với tài khoản có quyền tạo database và bảng.
3. Script tạo database `CampusLostDb`, bảng `dbo.Posts` và chỉ mục sắp xếp nếu chưa có. Database mới nhận **10 tin mẫu**, gồm 5 tin Bị mất và 5 tin Nhặt được. Script chỉ thêm các tin mẫu còn thiếu dựa trên nội dung và giữ các tin đã đăng. Hai truy vấn cuối script hiển thị danh sách và kết quả tìm mẫu **Bình nước xanh**.

Chạy script trước khi mở app. `Program.cs` đăng ký kết nối EF Core và routing, không gọi migration, tạo database hay seed khi khởi động.

### Cấu hình kết nối

Trong [appsettings.Development.json](PRN212_Assignment1/CampusLost/appsettings.Development.json), cập nhật mục `ConnectionStrings` theo mẫu và giữ các mục khác trong file. Thay `YOUR_SERVER_NAME` bằng **Server name** trong SSMS. Với named instance, viết dấu gạch chéo ngược kép trong JSON, ví dụ `YOUR_SERVER_NAME\\SQLEXPRESS`.

```json
{
  "ConnectionStrings": {
    "CampusLostDb": "Server=YOUR_SERVER_NAME;Database=CampusLostDb;Trusted_Connection=True;TrustServerCertificate=True"
  }
}
```

Nếu instance đã bật **SQL Server Authentication** và login được cấp quyền đọc, ghi trong `CampusLostDb`, có thể đặt chuỗi kết nối bằng biến môi trường cục bộ. Chạy lệnh sau trong PowerShell dùng để chạy app, hoặc đặt biến cục bộ trước khi mở Visual Studio để IDE nhận biến. Thay các placeholder trên máy của bạn và giữ thông tin đăng nhập thật ngoài Git.

```powershell
$env:ConnectionStrings__CampusLostDb = 'Server=YOUR_SERVER_NAME;Database=CampusLostDb;User ID=YOUR_SQL_USER;Password=YOUR_SQL_PASSWORD;TrustServerCertificate=True'
```

### Chạy ứng dụng

- **Visual Studio** — Mở [PRN212_Assignment1/PRN212_Assignment1.sln](PRN212_Assignment1/PRN212_Assignment1.sln). Trong Solution Explorer, nhấp phải project **CampusLost** → **Set as Startup Project**. Chọn profile **CampusLost** rồi nhấn **F5** hoặc **Ctrl+F5**.
- **Terminal** — Chạy lệnh dưới đây từ gốc repo.

```powershell
dotnet run --project ./PRN212_Assignment1/CampusLost/CampusLost.csproj --launch-profile CampusLost
```

Profile **CampusLost** dùng môi trường `Development`, lắng nghe tại `http://localhost:5099` và cấu hình mở [http://localhost:5099/Posts](http://localhost:5099/Posts).

## 3. Cách dùng và luồng MVC

1. **Xem danh sách** ở `/Posts`. Tin mới nhất đứng trước theo `PostedOn`, rồi theo `Id` giảm dần nếu trùng thời điểm.
2. **Đăng tin** bằng nút **Đăng tin**. Nhập tên, chọn Bị mất hoặc Nhặt được, nhập địa điểm, mô tả và thông tin liên hệ rồi gửi form.
3. **Xem chi tiết** bằng cách bấm tên đồ vật trong danh sách. Route `/Posts/Details/{id}` hiển thị địa điểm, mô tả và thông tin liên hệ của tin. `Liên hệ ngay` dùng liên kết email hoặc điện thoại. Nếu Id không tồn tại, controller trả HTTP 404.

Khi gửi tin, [Create.cshtml](PRN212_Assignment1/CampusLost/Views/Posts/Create.cshtml) gửi form kèm token antiforgery tới `POST /Posts/Create`. [PostsController](PRN212_Assignment1/CampusLost/Controllers/PostsController.cs) kiểm tra token và chỉ bind `Title`, `Kind`, `Location`, `Description` và `Contact` từ form. Nếu `ModelState` có lỗi, controller trả lại form kèm thông báo. `Kind` thiếu, rỗng hoặc ngoài 1–2 hiện lỗi dưới hai lựa chọn. Với dữ liệu hợp lệ, controller thêm đối tượng vào `CampusLostDbContext.Posts`, gọi `SaveChangesAsync()` để ghi vào `dbo.Posts`, rồi chuyển hướng về `Index`.

| Trường | Vai trò |
| --- | --- |
| `Id` | Khóa chính `int IDENTITY` do SQL Server cấp. Route chi tiết dùng giá trị này để tìm đúng tin. |
| `Kind` | Số nguyên, `1` là **Bị mất**, `2` là **Nhặt được**. Model kiểm tra giá trị và bảng có ràng buộc `CHECK`. |
| `PostedOn` | SQL Server tự gán `SYSUTCDATETIME()` vào cột `datetime2(0)`. DbContext đánh dấu giá trị đọc ra là UTC. [Index.cshtml](PRN212_Assignment1/CampusLost/Views/Posts/Index.cshtml) và [Details.cshtml](PRN212_Assignment1/CampusLost/Views/Posts/Details.cshtml) đổi sang UTC+7 rồi định dạng cả giờ `HH:mm` và ngày `dd/MM/yyyy` từ cùng một giá trị. |

**Tìm kiếm và lọc.** Form gửi GET tới `/Posts` với `q` là một phần tên đồ vật và `kind` là loại tin. Controller trim hai đầu `q`, áp dụng `Title.Contains(...)` nếu có từ khóa và thêm điều kiện `Kind` nếu chọn `1` hoặc `2`. Hai điều kiện được kết hợp trên truy vấn EF Core trước `ToListAsync()`. Collation `Vietnamese_CI_AS` của cột `Title` giúp tìm không phân biệt hoa thường và vẫn phân biệt dấu. Form giữ lựa chọn sau khi tải lại, hiện thông báo khi không có kết quả và đưa về `/Posts` khi bấm **Xóa lọc**.

## 4. Demo dùng Codex trong Visual Studio

1. Cài Codex CLI, mở **View → Terminal** trong Visual Studio rồi chuyển đến thư mục gốc repo. Chạy `codex` và đăng nhập khi được yêu cầu. [Tài liệu Codex CLI](https://learn.chatgpt.com/docs/codex/cli)
2. Nhập yêu cầu trong phiên Codex. Dùng prompt dưới đây để minh họa yêu cầu thêm bộ lọc trên phiên bản trước khi có tính năng. Source hiện tại đã có bộ lọc này.
3. Đọc diff trong **Git Changes** hoặc bằng `git diff`. Kiểm tra điều kiện lọc nằm trước `ToListAsync()`, form dùng GET và giữ giá trị đã chọn. Build và chạy các ca lọc trong mục 6.

**Prompt mẫu**

> Thêm bộ lọc cho CampusLost ở /Posts. Form dùng GET với q và kind. Trim q, tìm theo một phần Title không phân biệt hoa thường và kết hợp loại tin Bị mất hoặc Nhặt được trong truy vấn EF Core trước ToListAsync(). Giữ giá trị trên form, hiển thị thông báo khi không có kết quả và cho Xóa lọc quay lại /Posts. Chạy build rồi thử BÌNH + Nhặt được, từ khóa không khớp và Xóa lọc.


## 5. Cấu trúc code

| Đường dẫn | Vai trò |
| --- | --- |
| [PRN212_Assignment1/PRN212_Assignment1.sln](PRN212_Assignment1/PRN212_Assignment1.sln) | Solution chứa project CampusLost. |
| [CampusLost/Program.cs](PRN212_Assignment1/CampusLost/Program.cs) | Đăng ký MVC, DbContext, cấu hình kết nối và route mặc định. |
| [CampusLost/Models/LostItemPost.cs](PRN212_Assignment1/CampusLost/Models/LostItemPost.cs) | Dữ liệu của tin và quy tắc kiểm tra form. |
| [CampusLost/Controllers/PostsController.cs](PRN212_Assignment1/CampusLost/Controllers/PostsController.cs) | Đọc danh sách, lọc, xử lý đăng tin và tìm chi tiết. |
| [CampusLost/Data/CampusLostDbContext.cs](PRN212_Assignment1/CampusLost/Data/CampusLostDbContext.cs) | Ánh xạ entity vào `dbo.Posts`. |
| [CampusLost/Views/Posts](PRN212_Assignment1/CampusLost/Views/Posts) | Ba Razor View `Index`, `Create` và `Details`. |
| [CampusLost/appsettings.Development.json](PRN212_Assignment1/CampusLost/appsettings.Development.json) | Cấu hình chuỗi kết nối cho môi trường Development. |
| [CampusLostDb.sql](CampusLostDb.sql) | Tạo database, bảng, chỉ mục và 10 data mẫu. |

## 6. Kiểm tra và xử lý lỗi

Build từ thư mục gốc repo:

```powershell
dotnet build ./PRN212_Assignment1/PRN212_Assignment1.sln
```

| Ca tự kiểm tra | Kết quả mong đợi |
| --- | --- |
| Mở `/Posts` sau khi chạy script trên database mới. | Thấy 10 tin mẫu, tin mới nhất đứng trước. Nếu đã có thêm tin, tổng số có thể lớn hơn 10. |
| Mở chi tiết **Bình nước xanh**. | Thấy địa điểm **Thư viện**, mô tả và liên hệ `thuvien@example.com`. |
| Đăng tin hợp lệ trên database dùng để thử. | Chuyển về danh sách và thấy tin vừa đăng. |
| Bỏ trống tên đồ vật rồi gửi form. | Form báo lỗi và không tạo tin. |
| Tìm `BÌNH` và chọn **Nhặt được**. | Trên bộ dữ liệu mẫu, chỉ thấy **Bình nước xanh**. Form giữ từ khóa và loại đã chọn. |
| Tìm `KhongCoVatPham123` trên dữ liệu mẫu. | Hiện **Không tìm thấy tin phù hợp**. |
| Bấm **Xóa lọc**. | Về `/Posts`, ô từ khóa trống, loại về **Tất cả loại tin** và danh sách hiện lại. |

Trong các lượt kiểm tra trước khi viết README, build bản sao source đã thành công với 0 cảnh báo và 0 lỗi. Kiểm tra HTTP và SQL Server test đã xác nhận luồng đăng tin hợp lệ, từ chối POST thiếu hoặc sai `Kind`, tìm **BÌNH + Nhặt được**, trạng thái rỗng và Xóa lọc. Hai trang danh sách và chi tiết cũng đã được kiểm tra với mốc UTC qua nửa đêm để xác nhận đổi đúng ngày khi hiển thị. Các kết quả này được ghi nhận trong phiên làm việc, chưa có log hoặc ảnh kiểm thử lưu trong repo. Checklist trên dùng để tự kiểm tra lại trên máy mới.

| Lỗi | Cách xử lý |
| --- | --- |
| Sai SQL Server instance hoặc không kết nối được | Kết nối bằng SSMS trước, kiểm tra dịch vụ SQL Server đang chạy và chép đúng **Server name** vào `Server=`. Với named instance, kiểm tra cả tên instance và dấu gạch chéo trong JSON. |
| `Login failed for user` | Với Windows Authentication, kiểm tra tài khoản Windows chạy app có quyền vào `CampusLostDb`. Với SQL Authentication, kiểm tra chế độ xác thực, thông tin login cục bộ và quyền trên database. |
| Database chưa có bảng hoặc tin mẫu | Kiểm tra app đang trỏ đúng instance và database. Chạy toàn bộ `CampusLostDb.sql` trong SSMS rồi chạy `SELECT COUNT(*) FROM CampusLostDb.dbo.Posts;` để kiểm tra số tin. |
