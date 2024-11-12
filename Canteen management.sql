create database Assignment
use Assignment

create table Nhanvien
(
	manv varchar(10) primary key,
	hoten nvarchar(30),
	dienthoai varchar(10),
	gioitinh varchar(10),
	ngayvao date,
	luong float,
	loainv nvarchar(10)
)

create table Leader
(
	manv varchar(10) primary key,
	hoten nvarchar(30),
	dienthoai varchar(10),
	gioitinh varchar(10),
	ngayvao date,
	luong float,
	loainv nvarchar(10),
	Ngaynhan date,
	Thanhtich nvarchar(30),
)

create table Quay
(
	Maquay varchar(10) primary key,
	Maleader varchar(10) foreign key references Leader(Manv),
	Tenquay nvarchar(30)
)

create table Sanpham
(
	Masp varchar(10) primary key,
	Maquay varchar(10) foreign key references Quay(Maquay),
	Tensp nvarchar(30),
	sl int,
	dongia float
)

create table Nhacungcap
(
	Tenncc nvarchar(30),
	Diachi nvarchar(30),
	Hotline varchar(10)
)

create table Hoadon
(
	Mahd varchar(10) primary key,
	Ngayxuat date,
	Tongtien float,
	Tienkd float,
	Tienthua float
)

create table CTHD
(
	Masp varchar(10) foreign key references Sanpham(Masp),
	Mahd varchar(10) foreign key references Hoadon(Mahd),
	primary key(Masp, Mahd),
	sl int,
	dongia float
)
--4b. Function
create function mahdMax() -- function 1
returns varchar(10)
as
begin
	return(select top 1 mahd from Hoadon order by mahd desc)
end
go

create proc addMahd @ngayxuat date, @tongtien float, @tienkd float, @tienthua float
as
	declare @mahd varchar(10)
	set @mahd = dbo.mahdMax()
	declare @stt  int
	if (select count(*) from Hoadon) = 0
		begin
			set @stt = 1
		end
	else
		begin
			set @stt = cast(right(@mahd, 4) as int) + 1
		end

	if @stt < 10
		begin
			set @mahd = 'HD000' + cast (@stt as varchar(1))
		end
	else if @stt < 100
		begin
			set @mahd = 'HD00' + cast (@stt as varchar(2))
		end
	else if @stt < 1000
		begin
			set @mahd = 'HD0' + cast (@stt as varchar(3))
		end
	else
		begin
			set @mahd = 'HD' + cast (@stt as varchar(4))
		end

	insert into Hoadon values (@mahd, @ngayxuat, @tongtien, @tienkd, @tienthua)
go

drop proc addMahd
drop function mahdMax

-- kiểm tra phát sinh tự động Mahd
EXEC addMahd '2022-12-05', 180000, 200000, 20000
EXEC addMahd '2022-12-05', 145000, 150000, 5000
select * from Hoadon

--function 2
create function manvMax()	-- function 2
returns varchar(10)
as
begin
	return(select top 1 manv from Nhanvien order by manv desc)
end
go

create proc addManv @hoten nvarchar(30), @dienthoai varchar(10), @gt varchar(10), @ngayvao date, @luong float, @lnv nvarchar(10)
as
	declare @manv varchar(10)
	set @manv = dbo.manvMax()
	declare @stt  int
	if (select count(*) from Nhanvien) = 0
		begin
			set @stt = 1
		end
	else
		begin
			set @stt = cast(right(@manv, 3) as int) + 1
		end

	if @stt < 10
		begin
			set @manv = 'NV00' + cast (@stt as varchar(1))
		end
	else if @stt < 100
		begin
			set @manv = 'NV0' + cast (@stt as varchar(2))
		end
	else
		begin
			set @manv = 'NV' + cast (@stt as varchar(3))
		end

	insert into Nhanvien values (@manv, @hoten, @dienthoai, @gt, @ngayvao, @luong, @lnv)
go


drop proc addManv
drop function manvMax
-- kiểm tra phát sinh tự động Manv
EXEC addManv N'Nguyễn Triệu Vy', '0984763826', 'female', '2022-11-05', 19000, N'phục vụ'
EXEC addManv N'Phạm Trần Nhật Thiên', '0984763776', 'male', '2022-10-15', 23000, N'pha chế'
EXEC addManv N'Đặng Song Luân', '0973223890', 'male', '2022-11-07', 22000, N'pha chế'

select * from Nhanvien

--4c. Trigger
-- drop foreign key để dùng trigger
Alter table CTHD
drop constraint [FK__CTHD__Mahd__35BCFE0A]
Alter table CTHD
drop constraint [FK__CTHD__Masp__34C8D9D1]

create Trigger Tr_checkMasp on CTHD --kiểm tra ràng buộc khóa ngoại
for insert, update
as
	declare @masp varchar(10)
	select @masp = masp from inserted
	if (select count(*) from sanpham where masp = @masp) = 0
		begin
			print('Ma san pham khong ton tai')
			rollback tran
		end

create Trigger Tr_checkSlCTHD on CTHD	--kiểm tra ràng buộc miền giá tri
for insert, update
as
	declare @sl int
	select @sl = sl from inserted
	if (@sl <= 0)
		begin
			print('So luong phai > 0')
			rollback tran
		end

--insert một số dữ liệu để kiểm tra chương trình
insert into Leader values ('NV001', N'Phạm Trần Nhật Thiên', '0984763776', 'male', '2022-10-15', 23000, N'pha chế', '2022-12-05', 'NVSX T11')
insert into Quay values('PC', 'NV001', N'Pha chế')
insert into Sanpham values('SP001', 'PC', N'Trà sữa Matcha', 60, 35000)
insert into Sanpham values('SP002', 'PC', N'Trà sữa trà lài', 40, 35000)
select * from leader
select * from quay
select * from sanpham

-- insert để kiểm tra trigger
insert into CTHD values('SP005', 'HD0001', 2, 35000)
insert into CTHD values('SP002', 'HD0001', 0, 35000)

