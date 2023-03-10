USE [CHUKCOFFEE]
GO
/****** Object:  UserDefinedFunction [dbo].[getDoanhThu]    Script Date: 12/27/2022 8:10:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getDoanhThu] ()
RETURNS  @tableDoanhThu Table (ProductName nvarchar(30), Quantity int , PayMent float)
as
BEGIN
	insert into @tableDoanhThu
		select ProductName, Count(amount) as Quanity, Count(amount) * Price as PayMent from Products, Orders, OrderDetail
		where Products.ProductID = OrderDetail.ProductID and Orders.OrderID = OrderDetail.OrderID
		group by OrderDetail.ProductID, ProductName, Price
		Order by Quanity

	RETURN
END;
GO
/****** Object:  UserDefinedFunction [dbo].[getListLineToDay]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[getListLineToDay] (@daytime date)
returns @table table(IdEmp int, EmpName nvarchar(30), Position nvarchar(20),NameLine nvarchar(20), TimeBegin int, TimeEnd int)
as
begin
	insert into @table
		select Employees.EmployeeID as 'Mã số nhân viên', FullName as 'Họ Tên', Position as 'Vị Trí', Salary.SalaryName as 'Ca làm', TimeBegin as 'Giờ Bắt Đầu', TimeEnd as 'Giờ kết thúc' from Employees, Salary
		where Salary.DateWork = '2022/12/7' and Salary.EmployeeID = Employees.EmployeeID
	return
end
GO
/****** Object:  UserDefinedFunction [dbo].[getSPBanChay]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getSPBanChay] ()
RETURNS  @tableDoanhThu Table (ProductName nvarchar(30), Quantity int , PayMent float)
as
BEGIN
	insert into @tableDoanhThu
		select ProductName, Count(amount) as Quanity, Count(amount) * Price as PayMent from Products, Orders, OrderDetail
		where Products.ProductID = OrderDetail.ProductID and Orders.OrderID = OrderDetail.OrderID
		group by OrderDetail.ProductID, ProductName, Price
		having Count(amount) >= ALL(Select Count(amount) from Products, Orders, OrderDetail
								where Products.ProductID = OrderDetail.ProductID and Orders.OrderID = OrderDetail.OrderID
								group by OrderDetail.ProductID, ProductName, Price) 

	RETURN
END;
GO
/****** Object:  Table [dbo].[Products]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](30) NULL,
	[Price] [float] NULL,
	[InStock] [nvarchar](30) NULL,
	[SupplierID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustommerID] [int] NULL,
	[OrderDay] [datetime] NULL,
	[Totail] [float] NULL,
	[Discount] [float] NULL,
	[EmployeeID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetail]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetail](
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[amount] [int] NULL,
 CONSTRAINT [pk] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[view_PrDaily]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_PrDaily]
as
SELECT       Products.ProductName, SUM(OrderDetail.amount) AS Quanity, SUM(OrderDetail.amount) * dbo.Products.Price AS PayMent
FROM            Products , OrderDetail , Orders                        
WHERE        (DAY(Orders.OrderDay) = DAY(GETDATE())) and OrderDetail.OrderID = Orders.OrderID and Products.ProductID = OrderDetail.ProductID
GROUP BY Products.ProductName , OrderDetail.amount , Products.Price
GO
/****** Object:  View [dbo].[view_Max]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_Max] 
as
select ProductName , Sum(OrderDetail.amount)  as 'Amount' , (Sum(OrderDetail.amount) * Products.Price) as 'Sales' 
from OrderDetail, Orders , Products 		
where OrderDetail.OrderID = Orders.OrderID and OrderDetail.ProductID = Products.ProductID  and Month(Orders.OrderDay) = MONTH(GETDATE())
group by ProductName,Products.Price
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](30) NULL,
	[BirthOfDay] [datetime] NULL,
	[Address] [nvarchar](50) NULL,
	[Position] [nvarchar](20) NULL,
	[NumberPhone] [varchar](20) NULL,
	[Gender] [nvarchar](5) NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Salary]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Salary](
	[SalaryID] [int] IDENTITY(1,1) NOT NULL,
	[SalaryName] [varchar](20) NULL,
	[Totail] [int] NULL,
	[DateWork] [date] NULL,
	[TimeEnd] [int] NULL,
	[TimeBegin] [int] NULL,
	[EmployeeID] [int] NULL,
	[ToTalSalary] [float] NULL,
	[mucLuong] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalaryDetail]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalaryDetail](
	[SalaryID] [int] NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[TotailTimeWorking] [int] NULL,
	[TotailSalary] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC,
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Custommers]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Custommers](
	[CustommerID] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](30) NULL,
	[PhoneNumber] [varchar](11) NULL,
	[Points] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[CustommerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Supplier]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Supplier](
	[SupplierID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierName] [nvarchar](30) NULL,
	[Address] [nvarchar](50) NULL,
	[Email] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_1]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_1]
AS
SELECT       dbo.OrderDetail.ProductID
FROM            dbo.OrderDetail INNER JOIN
                         dbo.SalaryDetail INNER JOIN
                         dbo.Custommers INNER JOIN
                         dbo.Orders ON dbo.Custommers.CustommerID = dbo.Orders.CustommerID INNER JOIN
                         dbo.Employees ON dbo.Orders.EmployeeID = dbo.Employees.EmployeeID ON dbo.SalaryDetail.EmployeeID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.Salary ON dbo.SalaryDetail.SalaryID = dbo.Salary.SalaryID ON dbo.OrderDetail.OrderID = dbo.Orders.OrderID INNER JOIN
                         dbo.Products INNER JOIN
                         dbo.Supplier ON dbo.Products.SupplierID = dbo.Supplier.SupplierID ON dbo.OrderDetail.ProductID = dbo.Products.ProductID
GO
/****** Object:  View [dbo].[vReportLuong]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vReportLuong]
as
	select Employees.FullName as 'Tên Nhân Viên', count(DateWork) as 'Số Ngày Làm Việc' , Sum(Totail) as 'Tổng giờ làm việc' , COUNT(Salary.DateWork) * (sum(Totail) * mucLuong) as 'Tổng lương'
		from Salary, Employees
		where Salary.EmployeeID = Employees.EmployeeID and MONTH(Salary.DateWork) = MONTH(GETDATE())
		group by Salary.EmployeeID,Employees.FullName, Salary.mucLuong
GO
/****** Object:  View [dbo].[vReportDoanhThuNgay]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vReportDoanhThuNgay]
as
	select ProductName , Count(amount) as 'Số lượng', COUNT(amount) * Price as 'Doanh Thu'  from Orders, OrderDetail, Products
	where DAY(OrderDay) = DAY(GETDATE()) and OrderDetail.OrderID = Orders.OrderID and Products.ProductID = OrderDetail.ProductID
	group by ProductName, Price, Discount
GO
/****** Object:  Table [dbo].[Account]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[EmployeeID] [int] NULL,
	[UserName] [varchar](20) NOT NULL,
	[Password] [varchar](20) NOT NULL,
	[Permisstion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRo]    Script Date: 12/27/2022 8:10:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Account] ([EmployeeID], [UserName], [Password], [Permisstion]) VALUES (1, N'Admin', N'123123', 1)
INSERT [dbo].[Account] ([EmployeeID], [UserName], [Password], [Permisstion]) VALUES (14, N'Dat', N'1', 1)
INSERT [dbo].[Account] ([EmployeeID], [UserName], [Password], [Permisstion]) VALUES (1014, N'DatVo', N'1', 1)
INSERT [dbo].[Account] ([EmployeeID], [UserName], [Password], [Permisstion]) VALUES (4, N'staff', N'123123', -1)
GO
SET IDENTITY_INSERT [dbo].[Custommers] ON 

INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (1, N'No MememberShip', N'1122334455', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (2, N'Nguyen Thanh Hai', N'1122334466', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (3, N'Nguyen Thanh Dat', N'1122334477', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (4, N'Do Tan Dat', N'1122334488', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (5, N'Nguyen Phuc Vinh', N'0123456789', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (6, N'Cao Coffee', N'147258369', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (7, N'Vinh', N'20130213213', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (8, N'', N'', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (9, N'Vinhh', N'20130213213', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (10, N'dsdd', N'0123456789', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (11, N'asdsa', N'0123456789', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (12, N'dsadsd', N'2132112000', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (13, N'Nguyen Phuc Vinh', N'0792649405', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (14, N'sadasdsa', N'2321323123', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (1014, N'ABc', N'123', 0)
INSERT [dbo].[Custommers] ([CustommerID], [FullName], [PhoneNumber], [Points]) VALUES (1015, N'', N'', 0)
SET IDENTITY_INSERT [dbo].[Custommers] OFF
GO
SET IDENTITY_INSERT [dbo].[Employees] ON 

INSERT [dbo].[Employees] ([EmployeeID], [FullName], [BirthOfDay], [Address], [Position], [NumberPhone], [Gender]) VALUES (1, N'Nguyen Thanh Hai', CAST(N'2002-01-01T00:00:00.000' AS DateTime), N'TP.HCM', N'Nhan Vien', NULL, NULL)
INSERT [dbo].[Employees] ([EmployeeID], [FullName], [BirthOfDay], [Address], [Position], [NumberPhone], [Gender]) VALUES (4, N'Nguyen Phuc Vinh', CAST(N'2022-12-01T00:00:00.000' AS DateTime), N'Long An', N'Manager', N'852951753', N'Nam')
INSERT [dbo].[Employees] ([EmployeeID], [FullName], [BirthOfDay], [Address], [Position], [NumberPhone], [Gender]) VALUES (14, N'Đỗ Tấn Đạt', CAST(N'2002-01-01T00:00:00.000' AS DateTime), N'HCMC', N'Manager', N'1471472583', N'Nam')
INSERT [dbo].[Employees] ([EmployeeID], [FullName], [BirthOfDay], [Address], [Position], [NumberPhone], [Gender]) VALUES (1014, N'Võ Thành Đạt', CAST(N'2022-11-28T00:00:00.000' AS DateTime), N'Vũng Tàu', N'Manager', N'123654789', N'Nam')
INSERT [dbo].[Employees] ([EmployeeID], [FullName], [BirthOfDay], [Address], [Position], [NumberPhone], [Gender]) VALUES (1015, N'', CAST(N'1900-01-01T00:00:00.000' AS DateTime), N'', N'', N'', N'')
SET IDENTITY_INSERT [dbo].[Employees] OFF
GO
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (2, 1, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (3, 8, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (4, 9, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (5, 1, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (5, 8, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (6, 1, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (6, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (6, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (6, 10, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (6, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (6, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (7, 9, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (8, 1, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (9, 1, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (10, 3, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (11, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (12, 1, 4)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (13, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (14, 7, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (15, 12, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (20, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (21, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (22, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (23, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (24, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (25, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (26, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (27, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (28, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (28, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (29, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (29, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (30, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (30, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (31, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (31, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (31, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (32, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (32, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (32, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (32, 14, 3)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (33, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (33, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (34, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (34, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (34, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (34, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (34, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (35, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (35, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (35, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (36, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (36, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (36, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (36, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (36, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (37, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (37, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (37, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (38, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (38, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (38, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (38, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (41, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (41, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (41, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 3, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 10, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (42, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 1, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 3, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (43, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 1, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 3, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (44, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (45, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (46, 9, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (46, 10, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (46, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (46, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (46, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (46, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 1, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 3, 1)
GO
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 8, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (47, 9, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (48, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (48, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (48, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (48, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (48, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (48, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 3, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 7, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 10, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (50, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (51, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (52, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (53, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (54, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (56, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (57, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (58, 13, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (59, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (59, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (59, 19, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (60, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (60, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (61, 3, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (61, 5, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (62, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (62, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (63, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (63, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (64, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (64, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (65, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (65, 5, 5)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (65, 10, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (65, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (65, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (66, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (67, 10, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (67, 11, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (67, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (67, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (68, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (68, 11, 4)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (68, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (68, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (74, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (74, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (75, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (76, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (77, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (78, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (79, 1, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (79, 2, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1066, 13, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1068, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1068, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1069, 13, 4)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1069, 14, 5)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1069, 23, 9)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1078, 6, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1079, 4, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1080, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1081, 15, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1081, 16, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1081, 17, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1082, 4, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1083, 12, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1084, 14, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1085, 1, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1085, 2, 1000)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1086, 1, 1000)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1086, 2, 1000)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1086, 4, 2)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1086, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1087, 12, 3)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1088, 11, 1)
INSERT [dbo].[OrderDetail] ([OrderID], [ProductID], [amount]) VALUES (1090, 1029, 1)
GO
SET IDENTITY_INSERT [dbo].[Orders] ON 

INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (2, NULL, CAST(N'2022-11-23T13:58:27.483' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (3, NULL, CAST(N'2022-11-23T13:58:40.667' AS DateTime), 100000, 10, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (4, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 100000, 10, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (5, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 200000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (6, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 300000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (7, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 55000, 0, 4)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (8, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 45000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (9, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (10, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 70000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (11, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 35000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (12, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 180000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (13, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 55000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (14, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (15, NULL, CAST(N'2022-11-23T14:00:14.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (16, NULL, CAST(N'2022-11-27T14:34:25.887' AS DateTime), NULL, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (17, 1, CAST(N'2022-11-28T18:43:21.000' AS DateTime), 0, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (18, 1, CAST(N'2022-11-28T19:53:15.000' AS DateTime), 55000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (19, 1, CAST(N'2022-11-28T20:47:29.000' AS DateTime), 55000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (20, 1, CAST(N'2022-11-28T20:50:41.000' AS DateTime), 45000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (21, 1, CAST(N'2022-11-28T20:53:40.000' AS DateTime), 0, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (22, 1, CAST(N'2022-11-28T20:53:45.000' AS DateTime), 35000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (23, 1, CAST(N'2022-11-28T20:54:10.000' AS DateTime), 0, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (24, 1, CAST(N'2022-11-28T21:04:21.000' AS DateTime), 55000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (25, 1, CAST(N'2022-11-28T21:04:53.000' AS DateTime), 55000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (26, 1, CAST(N'2022-11-28T21:05:00.000' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (27, 1, CAST(N'2022-11-29T10:45:03.000' AS DateTime), 100000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (28, 1, CAST(N'2022-11-29T11:13:38.000' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (29, 1, CAST(N'2022-11-29T11:27:02.000' AS DateTime), 100000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (30, 1, CAST(N'2022-11-29T11:27:43.000' AS DateTime), 100000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (31, 1, CAST(N'2022-11-29T12:15:12.000' AS DateTime), 155000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (32, 1, CAST(N'2022-11-29T12:25:08.000' AS DateTime), 100000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (33, 1, CAST(N'2022-11-29T13:17:12.000' AS DateTime), 80000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (34, 1, CAST(N'2022-11-30T12:18:32.000' AS DateTime), 300000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (35, 1, CAST(N'2022-11-30T12:21:25.000' AS DateTime), 135000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (36, 1, CAST(N'2022-11-30T12:21:35.000' AS DateTime), 145000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (37, 1, CAST(N'2022-11-30T12:21:46.000' AS DateTime), 155000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (38, 1, CAST(N'2022-11-30T12:23:37.000' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (39, 5, CAST(N'2022-12-01T23:41:47.000' AS DateTime), 145000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (40, 5, CAST(N'2022-12-01T23:42:33.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (41, 5, CAST(N'2022-12-01T23:43:15.000' AS DateTime), 155000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (42, 5, CAST(N'2022-12-01T23:48:20.000' AS DateTime), -21000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (43, 5, CAST(N'2022-12-01T23:55:27.000' AS DateTime), 56000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (44, 5, CAST(N'2022-12-01T23:56:24.000' AS DateTime), 51000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (45, 5, CAST(N'2022-12-01T23:57:30.000' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (46, 5, CAST(N'2022-12-01T23:58:25.000' AS DateTime), 32000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (47, 5, CAST(N'2022-12-01T23:59:45.000' AS DateTime), 131000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (48, 5, CAST(N'2022-12-02T00:00:21.000' AS DateTime), 0, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (49, 5, CAST(N'2022-12-02T00:01:58.000' AS DateTime), 95000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (50, 5, CAST(N'2022-12-02T00:02:40.000' AS DateTime), 150000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (51, 5, CAST(N'2022-12-02T11:38:30.000' AS DateTime), 145000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (52, 1, CAST(N'2022-12-02T11:49:46.000' AS DateTime), 90000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (53, 1, CAST(N'2022-12-02T11:53:20.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (54, 1, CAST(N'2022-12-02T11:54:59.000' AS DateTime), 165000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (55, 1, CAST(N'2022-12-02T11:56:17.000' AS DateTime), 65000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (56, 1, CAST(N'2022-12-02T11:57:12.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (57, 1, CAST(N'2022-12-02T12:00:43.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (58, 1, CAST(N'2022-12-02T12:32:06.000' AS DateTime), 110000, 0, NULL)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (59, 1, CAST(N'2022-12-05T13:47:03.000' AS DateTime), 100001, 0, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (60, 1, CAST(N'2022-12-05T13:50:37.000' AS DateTime), 90000, 0, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (61, 1, CAST(N'2022-12-05T13:52:32.000' AS DateTime), 70000, 0, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (62, 1, CAST(N'2022-12-05T13:56:25.000' AS DateTime), 100000, 0.5, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (63, 1, CAST(N'2022-12-05T14:00:42.000' AS DateTime), 50000, 50000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (64, 1, CAST(N'2022-12-05T14:05:30.000' AS DateTime), 10000, 10000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (65, 1, CAST(N'2022-12-06T09:14:42.000' AS DateTime), 52250, 2750, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (66, 5, CAST(N'2022-12-09T13:28:44.000' AS DateTime), -14, 6750, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (67, 1, CAST(N'2022-12-09T13:29:20.000' AS DateTime), 11637, 612.5, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (68, 5, CAST(N'2022-12-09T13:29:43.000' AS DateTime), 308750, 16250, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (69, 1, CAST(N'2022-12-12T00:37:23.127' AS DateTime), 0, 715002, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (70, 1, CAST(N'2022-12-12T00:48:18.303' AS DateTime), 0, 135000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (71, 1, CAST(N'2022-12-12T00:49:18.143' AS DateTime), 0, 90000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (72, 1, CAST(N'2022-12-12T13:42:31.320' AS DateTime), 0, 80000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (73, 1, CAST(N'2022-12-12T13:44:33.920' AS DateTime), 0, 35000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (74, 1, CAST(N'2022-12-12T13:47:23.000' AS DateTime), 0, 100000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (75, 1, CAST(N'2022-12-12T13:49:06.000' AS DateTime), 0, 35000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (76, 1, CAST(N'2022-12-12T13:52:49.000' AS DateTime), 0, 35000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (77, 1, CAST(N'2022-12-12T13:59:29.000' AS DateTime), 0, 35000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (78, 1, CAST(N'2022-12-12T14:01:18.000' AS DateTime), 0, 35000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (79, 1, CAST(N'2022-12-12T15:27:58.000' AS DateTime), 0, 80000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1066, 1, CAST(N'2022-12-19T10:04:31.000' AS DateTime), 0, 210000, 1014)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1067, 1, CAST(N'2022-12-19T10:08:47.400' AS DateTime), 0, 200000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1068, 1, CAST(N'2022-12-19T00:00:00.000' AS DateTime), 0, 80000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1069, 1, CAST(N'2022-12-20T00:00:00.000' AS DateTime), 19800, 2200, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1070, 1, CAST(N'2022-12-20T00:00:00.000' AS DateTime), 0, 9, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1071, 5, CAST(N'2022-12-20T00:00:00.000' AS DateTime), -30875, 225000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1072, 1, CAST(N'2022-12-20T00:00:00.000' AS DateTime), 0, 275000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1073, 1, CAST(N'2022-12-20T21:14:12.563' AS DateTime), 0, 110000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1074, 1, CAST(N'2022-12-20T22:23:12.120' AS DateTime), 0, 90000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1075, 1, CAST(N'2022-12-20T22:25:35.393' AS DateTime), 0, 70000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1076, 1, CAST(N'2022-12-20T22:28:27.113' AS DateTime), 0, 45000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1077, 1, CAST(N'2022-12-20T22:29:46.160' AS DateTime), 0, 90000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1078, 1, CAST(N'2022-12-20T22:32:11.573' AS DateTime), 0, 55000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1079, 1, CAST(N'2022-12-20T22:32:15.787' AS DateTime), 0, 35000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1080, 1, CAST(N'2022-12-20T22:32:19.320' AS DateTime), 0, 55000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1081, 1, CAST(N'2022-12-20T23:09:53.800' AS DateTime), 0, 135000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1082, 1, CAST(N'2022-12-20T23:10:15.623' AS DateTime), 0, 70000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1083, 1, CAST(N'2022-12-20T23:10:39.283' AS DateTime), 0, 55000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1084, 1, CAST(N'2022-12-20T23:11:24.150' AS DateTime), 10237, 5512.5, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1085, 1, CAST(N'2022-12-22T14:00:12.433' AS DateTime), 0, 80045000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1086, 1, CAST(N'2022-12-22T14:01:20.393' AS DateTime), 0, 80115000, 1)
GO
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1087, 1014, CAST(N'2022-12-22T14:01:54.097' AS DateTime), 0, 165000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1088, 1, CAST(N'2022-12-26T13:04:49.000' AS DateTime), 0, 45000, 1)
INSERT [dbo].[Orders] ([OrderID], [CustommerID], [OrderDay], [Totail], [Discount], [EmployeeID]) VALUES (1090, 1, CAST(N'2022-12-27T20:08:29.073' AS DateTime), 0, 50, 1)
SET IDENTITY_INSERT [dbo].[Orders] OFF
GO
SET IDENTITY_INSERT [dbo].[PRo] ON 

INSERT [dbo].[PRo] ([id], [name]) VALUES (1, N'A')
SET IDENTITY_INSERT [dbo].[PRo] OFF
GO
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (1, N'Cà Phê Sữa Đá', 45000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (2, N'Cà Phê Sữa Nóng', 35000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (3, N'Bạc Sỉu', 35000, N'Hết Hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (4, N'Bạc Sỉu Nóng', 35000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (5, N'Cà Phê Đen Đá', 35000, N'Hết Hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (6, N'Caramel Macchiato Đá', 55000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (7, N'Caramel Macchiato Nóng', 55000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (8, N'Latte Đá', 55000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (9, N'Latte Nóng', 55000, N'Hết Hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (10, N'Americano Đá', 45000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (11, N'Americano Nóng', 45000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (12, N'Cappucino Đá', 55000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (13, N'Cappuchio Nóng', 55000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (14, N'Espresso Nóng', 45000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (15, N'Espresso Đá', 45000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (16, N'Cold Brew Truyền Thống', 45000, N'Còn Hàng', NULL)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (17, N'Cold Brew Phúc Bồn Tử', 45000, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (18, N'Nguyễn Phúc Vinh', 1, N'Hết hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (19, N'Võ Thành Đạt', 1, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (20, N'Nguyễn Đức Khang', 1, N'Hết hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (21, N'Đỗ Tấn Đạt', 1, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (22, N'Tea Matcha', 45000, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (23, N'Tea Hi', 1, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (24, N'Tea Brown', 1, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (25, N'Tea Cheer', 21000, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (26, N'Cà Phê Socola', 1000, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (1025, N'Cà Phê Việt Nam Truyền Thống', 35000, N'Còn hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (1026, N'1ee12', 123, N'Hết hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (1027, N'ABC', 35000, N'Còn Hàng', 1)
INSERT [dbo].[Products] ([ProductID], [ProductName], [Price], [InStock], [SupplierID]) VALUES (1029, N'ADC', 50, N'Còn Hàng', 1)
SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[Salary] ON 

INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (1, N'Open', 0, CAST(N'2022-12-07' AS Date), 7, 13, NULL, NULL, NULL)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (2, N'Open', -5, CAST(N'2022-12-07' AS Date), 7, 12, NULL, NULL, NULL)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (3, N'Open', 6, CAST(N'2022-12-07' AS Date), 13, 7, NULL, NULL, NULL)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (19, N'Mid', 6, CAST(N'2022-12-07' AS Date), 13, 7, 5, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (21, N'Mid', 6, CAST(N'2022-12-07' AS Date), 13, 7, 1, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (22, N'Mid', 6, CAST(N'2022-12-08' AS Date), 13, 7, 5, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (23, N'Mid', 6, CAST(N'2022-12-08' AS Date), 13, 7, 5, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (24, N'Mid', 6, CAST(N'2022-12-08' AS Date), 13, 7, 1, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (25, N'Mid', 6, CAST(N'2022-12-08' AS Date), 13, 7, 1, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (27, N'Mid', 6, CAST(N'2022-12-09' AS Date), 13, 7, 4, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (29, N'Mid', 6, CAST(N'2022-12-09' AS Date), 13, 7, 7, 138000, 23000)
INSERT [dbo].[Salary] ([SalaryID], [SalaryName], [Totail], [DateWork], [TimeEnd], [TimeBegin], [EmployeeID], [ToTalSalary], [mucLuong]) VALUES (1004, N'', 0, CAST(N'1900-01-01' AS Date), 0, 0, 0, 0, 23000)
SET IDENTITY_INSERT [dbo].[Salary] OFF
GO
SET IDENTITY_INSERT [dbo].[Supplier] ON 

INSERT [dbo].[Supplier] ([SupplierID], [SupplierName], [Address], [Email]) VALUES (1, N'Coffee Nhà Làm', N'Long An', N'coffeenhalam@gmail.com')
SET IDENTITY_INSERT [dbo].[Supplier] OFF
GO
ALTER TABLE [dbo].[Custommers] ADD  DEFAULT ((0)) FOR [Points]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT (getdate()) FOR [OrderDay]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [fk] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [fk]
GO
ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Orders]
GO
ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Products]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customer] FOREIGN KEY([CustommerID])
REFERENCES [dbo].[Custommers] ([CustommerID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customer]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Employee] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Employee]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Supplier] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Supplier] ([SupplierID])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Supplier]
GO
ALTER TABLE [dbo].[SalaryDetail]  WITH CHECK ADD  CONSTRAINT [FK_SalaryDetail_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[SalaryDetail] CHECK CONSTRAINT [FK_SalaryDetail_Employees]
GO
ALTER TABLE [dbo].[SalaryDetail]  WITH CHECK ADD  CONSTRAINT [FK_SalaryDetail_Salary] FOREIGN KEY([SalaryID])
REFERENCES [dbo].[Salary] ([SalaryID])
GO
ALTER TABLE [dbo].[SalaryDetail] CHECK CONSTRAINT [FK_SalaryDetail_Salary]
GO
/****** Object:  StoredProcedure [dbo].[AddNewCus]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[AddNewCus] @pName nvarchar(30), @pPhone nvarchar(30), @pPoint int = 0
as
begin
	insert into Custommers
	values(@pName,@pPhone,@pPoint)
end
GO
/****** Object:  StoredProcedure [dbo].[checkPhone]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[checkPhone] @pPhone nvarchar(30)
as
begin
	select Count(CustommerID) from Custommers
	where PhoneNumber = @pPhone ;
end
GO
/****** Object:  StoredProcedure [dbo].[delEmp]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[delEmp] @pId int
as
begin
	update Orders
	set EmployeeID = null
	where EmployeeID = @pId

	delete from Employees
	where Employees.EmployeeID = @pId
end
GO
/****** Object:  StoredProcedure [dbo].[delLine]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[delLine] @pIdEmp int ,@pDay date
as
begin 
	delete from Salary
	where Salary.EmployeeID = @pIdEmp and Salary.DateWork = @pDay

end
GO
/****** Object:  StoredProcedure [dbo].[findCustommers]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[findCustommers] @pPhone nvarchar(30)
as
begin
	select * from Custommers
	Where PhoneNuMber = @pPhone
end
GO
/****** Object:  StoredProcedure [dbo].[findPoints]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[findPoints] @pPhone nvarchar(30)
as
begin
	select * from Custommers
	Where PhoneNuMber = @pPhone
end
GO
/****** Object:  StoredProcedure [dbo].[getCusID]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[getCusID] @cusName nvarchar(30)
as	
begin
	select CustommerID from Custommers 
	Where Custommers.FullName = @cusName
end
GO
/****** Object:  StoredProcedure [dbo].[getDaySalary]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[getDaySalary] @pDay Date
as
begin
	select Employees.FullName as 'Tên' , Salary.DateWork , Salary.SalaryName as 'Line', TimeBegin as 'Bắt đầu', TimeEnd as 'Kết Thúc' from Salary , Employees
	where Salary.DateWork = @pDay and Salary.EmployeeID = Employees.EmployeeID
end
GO
/****** Object:  StoredProcedure [dbo].[getIdEmp]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[getIdEmp] @pName nvarchar(30)
as
begin
	select EmployeeID from Employees
	where Employees.FullName = @pName
end
GO
/****** Object:  StoredProcedure [dbo].[getIDStaff]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[getIDStaff] @username nvarchar(30)
as
begin
	select Employees.EmployeeID from Employees , Account Where Employees.EmployeeID = Account.EmployeeID and Account.UserName = @username
end
GO
/****** Object:  StoredProcedure [dbo].[getOrderID]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[getOrderID] @orderDay Datetime
as
begin
	select OrderID from Orders
	where OrderDay = @orderDay
end
GO
/****** Object:  StoredProcedure [dbo].[getPerMisstion]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[getPerMisstion] @pUsername nvarchar(30)
as
begin
	select Permisstion from account
	where UserName = @pUsername
end
GO
/****** Object:  StoredProcedure [dbo].[GetProductList]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetProductList]
as
begin
	select ProductID , ProductName , Price , InStock from Products
end
GO
/****** Object:  StoredProcedure [dbo].[getReportForBill]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[getReportForBill] @pDay datetime
as
begin
	select OrderDay, ProductName, OrderDetail.amount, Orders.Totail from Orders,OrderDetail, Products
	where OrderDay = '2022-11-30 12:21:35.000' and OrderDetail.OrderID = Orders.OrderID and Products.ProductID = OrderDetail.ProductID
end
GO
/****** Object:  StoredProcedure [dbo].[getSalaryID]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[getSalaryID] @pIdEmp int, @day date 
as
begin
	select Salary.SalaryID from Salary
	where  Salary.EmployeeID = @pIdEmp and Salary.DateWork = @day
end
GO
/****** Object:  StoredProcedure [dbo].[getThongKeLuongThang]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[getThongKeLuongThang] @pMonth int
as
begin 
	select Employees.FullName as 'Tên Nhân Viên', count(DateWork) as 'Số Ngày Làm Việc' , Sum(Totail) as 'Tổng giờ làm việc' , COUNT(Salary.DateWork) * (sum(Totail) * mucLuong) as 'Tổng lương'
		from Salary, Employees
		where Salary.EmployeeID = Employees.EmployeeID and MONTH(Salary.DateWork) = @pMonth
		group by Salary.EmployeeID,Employees.FullName, Salary.mucLuong
end
GO
/****** Object:  StoredProcedure [dbo].[iDelete]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[iDelete] @pId int
as	
begin 
	delete  from Employees
	where EmployeeID = @pId
end
GO
/****** Object:  StoredProcedure [dbo].[iFindCus]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[iFindCus] @pFind nvarchar(30)
as
begin
	Select * from Custommers
	Where Custommers.FullName Like '%'+@pFind+'%'
end
GO
/****** Object:  StoredProcedure [dbo].[iFindEmp]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[iFindEmp] @pFind nvarchar(30)
as
begin
	Select * from Employees
	Where Employees.FullName Like '%'+@pFind+'%'
end
GO
/****** Object:  StoredProcedure [dbo].[iFindProduct]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[iFindProduct] @pFind nvarchar(30)
as
begin
	Select * from Products
	Where ProductName Like '%'+@pFind+'%'
end
GO
/****** Object:  StoredProcedure [dbo].[insertLine]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[insertLine] @pName nvarchar(20), @pDay Date, @pEnd int, @pBegin int, @pIdEmp int
as
begin
	insert into Salary
	values(@pName,'', @pDay,@pBegin,@pEnd, @pIdEmp,'',23000);
end
GO
/****** Object:  StoredProcedure [dbo].[iUpdate]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[iUpdate] @pId int,
@pName nvarchar(30), @pDay date, @pAddr nvarchar(30),  @pPosition varchar(10), @pPhone varchar(11), @pGender nvarchar(5)
as
begin
	update Employees
	set FullName = @pName, BirthOfDay = @pDay, Address = @pAddr,Position = @pPosition, NumberPhone = @pPhone, Gender = @pGender 
	where EmployeeID = @pId ;
end
GO
/****** Object:  StoredProcedure [dbo].[iUpdatePro]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[iUpdatePro] @pId int,
@pName nvarchar(30), @pPrice float, @pStatus nvarchar(20), @sup int
as
begin
	update Products
	set ProductName = @pName, Price = @pPrice, InStock = @pStatus, SupplierID = @sup
	where ProductID = @pId ;
end
GO
/****** Object:  StoredProcedure [dbo].[newAccount]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[newAccount] @pID int,
@pUserName varchar(20), @pPassword varchar(20), @pPer int 
as
begin
	insert into Account
	values (@pID,@pUserName,@pPassword,@pPer)
end
GO
/****** Object:  StoredProcedure [dbo].[newEmployee]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[newEmployee] 
@pName nvarchar(30), @pDay date, @pAddress nvarchar(50), @pPosition nvarchar(20), @pPhone varchar(20), @pGender nvarchar(5)
as
begin
	insert into Employees
	values(@pName,@pDay,@pAddress,@pPosition,@pPhone,@pGender)
end
GO
/****** Object:  StoredProcedure [dbo].[newPro]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[newPro] @pName nvarchar(30),  @pPrice float , @pInStock nvarchar(20), @pSup int null
as
begin
	insert into Products
	values(@pName,@pPrice,@pInStock,@pSup)
end
GO
/****** Object:  StoredProcedure [dbo].[proLogIn]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[proLogIn]
@username nvarchar(100), @password nvarchar(100)
as
begin
	select * from Account where Account.UserName = @username and Account.Password = @password 
end
GO
/****** Object:  StoredProcedure [dbo].[rpOrders]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[rpOrders] @orderID int
as
begin
	select ProductName, amount, Price from OrderDetail , Orders, Products
	where OrderDetail.OrderID = Orders.OrderID
	and Orders.OrderID = 31 
	and Products.ProductID = OrderDetail.ProductID
end
GO
/****** Object:  StoredProcedure [dbo].[saveOrderDetails]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[saveOrderDetails] @OrderID int , @ProductID int , @Quantity int
as
begin
	insert into OrderDetail
	values(@OrderID,@ProductID,@Quantity)
end
GO
/****** Object:  StoredProcedure [dbo].[SaveOrders]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SaveOrders]  @CusID int , @OrderDay DateTime , @totail int , @discount money , @EmpID int
as
begin
	insert into Orders
	values (@CusID,@OrderDay,@totail,@discount,@EmpID)
end
GO
/****** Object:  StoredProcedure [dbo].[UpdateLine]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[UpdateLine] @pid int ,@pName nvarchar(20), @pDay Date, @pEnd int, @pBegin int, @pIdEmp int
as
begin
	update Salary
	set SalaryName = @pName , DateWork = @pDay , TimeEnd = @pEnd , TimeBegin = @pBegin , EmployeeID = @pIdEmp
	where SalaryID = @pid
end


GO
/****** Object:  StoredProcedure [dbo].[updatePoints]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[updatePoints] @pPhone varchar(30), @pPoint float
as
begin
	update Custommers
	set Points += @pPoint
	where Custommers.PhoneNumber = @pPhone
end
GO
/****** Object:  StoredProcedure [dbo].[updatePointsZero]    Script Date: 12/27/2022 8:10:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[updatePointsZero] @pPhone varchar(30), @pPoint float
as
begin
	update Custommers
	set Points = @pPoint
	where Custommers.PhoneNumber = @pPhone
end
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[86] 4[5] 2[5] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OrderDetail"
            Begin Extent = 
               Top = 186
               Left = 305
               Bottom = 308
               Right = 475
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SalaryDetail"
            Begin Extent = 
               Top = 264
               Left = 166
               Bottom = 394
               Right = 355
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Custommers"
            Begin Extent = 
               Top = 40
               Left = 51
               Bottom = 170
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 79
               Left = 519
               Bottom = 209
               Right = 689
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Employees"
            Begin Extent = 
               Top = 20
               Left = 330
               Bottom = 150
               Right = 500
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Salary"
            Begin Extent = 
               Top = 329
               Left = 0
               Bottom = 459
               Right = 170
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 335
               Left = 566
               Bottom = 497
               Right = 736
            End
            Display' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'Flags = 280
            TopColumn = 0
         End
         Begin Table = "Supplier"
            Begin Extent = 
               Top = 202
               Left = 699
               Bottom = 332
               Right = 869
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
