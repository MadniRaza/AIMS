USE [MMR_AIMS_DEV]
GO
/****** Object:  UserDefinedTableType [dbo].[PaymentData]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[PaymentData] AS TABLE(
	[VendorId] [int] NULL,
	[Amount] [decimal](10, 2) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[PurchaseInvoiceData]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[PurchaseInvoiceData] AS TABLE(
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[CostPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[PurchaseReturnData]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[PurchaseReturnData] AS TABLE(
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[Tax] [decimal](10, 2) NULL,
	[CostPrice] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ReceiptData]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[ReceiptData] AS TABLE(
	[CustomerId] [int] NULL,
	[Amount] [decimal](10, 2) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[SaleInvoiceData]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[SaleInvoiceData] AS TABLE(
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[SellPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[SaleReturnData]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[SaleReturnData] AS TABLE(
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[SellPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ShipmentCharges]    Script Date: 08/01/2021 11:43:13 pm ******/
CREATE TYPE [dbo].[ShipmentCharges] AS TABLE(
	[CustomerId] [int] NULL,
	[Amount] [decimal](10, 2) NULL,
	[CarrierId] [int] NULL
)
GO
/****** Object:  StoredProcedure [dbo].[sp_BackupDB]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_BackupDB]
As
BEGIN
DECLARE @FilePath VARCHAR(MAX);
DECLARE @FileName VARCHAR(MAX);
DECLARE @SQL  VARCHAR(MAX);
SET @FilePath = dbo.GetSysIniValue('BAK_PATH');
SELECT @FileName = CONCAT(@FilePath,FORMAT(GETDATE(),'ddMMyyyyHHmmss'),'.bak');

SELECT @FileName;
SELECT @FilePath;
SET @SQL = 'BACKUP DATABASE MMR_AIMS_DEV ';
SET @SQL = @SQL + ' TO  DISK = N'''+@FileName + '''';
SET @SQL = @SQL + ' WITH CHECKSUM; ';

EXEC (@SQL);
SELECT @SQL as a;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetActiveFiscalYear]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetActiveFiscalYear] 
AS
BEGIN
	SELECT DBO.GetActiveFiscalYearFromDate() FromDate,DBO.GetActiveFiscalYearToDate() ToDate; 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllMenus]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetAllMenus]
AS
BEGIN
SELECT M.MenuId, M.ParentId, MenuName, MG.MenuGroupId, MG.MenuGroupName, MenuPath FROM tMenus M
LEFT JOIN tMenuGroups MG ON MG.MenuGroupId = M.MenuGroupId
WHERE Active = 1
ORDER BY M.MenuOrder ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetBadInventory]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetBadInventory] @RecordId BIGINT
AS
BEGIN
		SELECT Bi.RecordId, BI.ItemId, BI.BadInventoryNumber, ItemName, DBO.GetCategoryHeirarchy(I.ItemId) Category,  Qty, Remarks FROM tBadInventories BI
		INNER JOIN tItems I ON I.ItemId = BI.ItemId
		
		 WHERE RecordId = @RecordId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetBadInventoryList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetBadInventoryList]
AS
BEGIN

DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();


SELECT RecordId, BadInventoryNumber, ItemName, Qty FROM tBadInventories BI
INNER JOIN tItems I ON I.ItemId = BI.ItemId

WHERE CAST(BI.CreatedOn as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(BI.CreatedOn as Date) <= CAST(@FiscalYearToDate as DATE)
ORDER BY BI.RecordId DESC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCarrier]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCarrier] @CarrierId INT
AS
BEGIN
		SELECT CarrierId, CarrierName,  Active FROM tCarriers
		 WHERE CarrierId = @CarrierId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCarrierList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCarrierList]
AS
BEGIN

SELECT CarrierId, CarrierName, IIF(Active = 1, 'Y','N') Active FROM tCarriers
ORDER BY CarrierName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCarriers]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCarriers]
AS
BEGIN

SELECT CarrierId, CarrierName FROM tCarriers
WHERE Active = 1
ORDER BY CarrierName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCategories]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCategories]
AS
BEGIN
		SELECT CategoryId, ParentId, CategoryName FROM tCategories
		WHERE Active = 1;
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCategory]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCategory] @CategoryId INT
AS
BEGIN
		SELECT CategoryId, CategoryName, ParentId, Active FROM tCategories
		 WHERE CategoryId = @CategoryId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCategoryList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCategoryList]
AS
BEGIN

SELECT DBO.GetCategoryHeirarchy(CategoryId) ParentName, CategoryId, CategoryName, IIF(Active = 1, 'Y','N') Active FROM tCategories
ORDER BY CategoryName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCategoryTree]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCategoryTree]
as
BEGIN
;WITH C
(
CategoryId,
ParentId,
CategoryName
)
as
(
SELECT CategoryId, ParentId, CAST(CategoryName as NVARCHAR(MAX))  FROM tCategories WHERE ParentId = 0
UNION ALL
SELECT A.CategoryId, A.ParentId, CAST(C.CategoryName + ':' + A.CategoryName as NVARCHAR(MAX)) FROM tCategories  A
INNER JOIN C ON C.CategoryId =A.ParentId
)
SELECT CategoryId, CategoryName FROM C ORDER BY CategoryName ASC;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCOA]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCOA] @COAId BIGINT
AS
BEGIN

SELECT COAID, COAName, COACode, COATypeId FROM tCOA WHERE COAID = @COAId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCompanyInfo]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCompanyInfo]
as
BEGIN
SELECT *, CONCAT(AddressLine1,' ', AddressLine2) Address, CONCAT('Tel: ',TelNo, ' Email: ', Email) ContactInfo FROM tCompanyInfo;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomer]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCustomer] @CustomerId INT
AS
BEGIN

SELECT CustomerId, BillingName, BillingAddress1, BillingAddress2, ShippingName, ShippingAddress1, ShippingAddress2, PhoneNo, TelNo, NTNNo, STRNo,  Active FROM tCustomers WHERE CustomerId = @CustomerId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomerBalance]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCustomerBalance] @CustomerId INT, @Timestamp DATETIME
as
BEGIN
DECLARE @COAId BIGINT;
DECLARE @RecordId BIGINT;
DECLARE @PreviousBalance DECIMAL(10,2);
SET @COAId = DBO.GetCOAIdByRefId('CUSTOMER', @CustomerId);


	SELECT @PreviousBalance =   ISNULL(SUM(Debit-Credit),0)
 	FROM tGL 
	WHERE COAID = @COAId AND TransactionDate < @Timestamp;

	SELECT @PreviousBalance as PreviousBalance, 0 As GrossAmount, 0 As NetBalance;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomerLedger]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCustomerLedger] @CustomerId INT,@FromDate  DATETIME, @ToDate DATETIME
as
BEGIN
DECLARE @COAId BIGINT;
DECLARE @OpeningBalance DECIMAL(10,2);
DECLARE @EndingBalance DECIMAL(10,2);
SET @COAId = DBO.GetCOAIdByRefId('CUSTOMER', @CustomerId);





	SELECT @OpeningBalance = ISNULL(SUM(Debit-Credit),0)
	FROM tGL
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) <CAST(@FromDate as Date));
	
	SELECT @EndingBalance = @OpeningBalance + ISNULL(SUM(Debit-Credit),0)
	FROM tGL 
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));

	SELECT  @OpeningBalance OpeningBalance, @EndingBalance EndingBalance, @FromDate FromDate, @ToDate ToDate;

	SELECT ROW_NUMBER() OVER (Order By GL.TransactionDate, RecordId) as SerialNumber, GL.TransactionDate, DBO.GetRefNumberByRefId(RefType, RefID) RefNumber, GL.Remarks, Debit, Credit,
	@OpeningBalance + SUM(Debit - Credit) OVER (PARTITION BY COAId ORDER BY GL.TransactionDate, RecordId)  as Balance
	FROM tGL GL
	WHERE GL.COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomerList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCustomerList]
AS
BEGIN

SELECT CustomerId, BillingName, IIF(Active = 1, 'Y','N') Active FROM tCustomers
ORDER BY BillingName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomerOB]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCustomerOB] @CustomerId BIGINT
as
BEGIN

DECLARE @COAId BIGINT;
SET @COAId = dbo.GetCOAIdByRefId('CUSTOMER', @CustomerId);


SELECT C.CustomerId as RefId, @COAId as COAId, C.BillingName, IsNULL(CASE WHEN Debit> 0 THEN Amount WHEN Credit > 0 THEN Amount *-1 END,0) OB FROM tCustomers C
LEFT JOIN tGL GL ON GL.COAID = @COAId AND GL.RefType = 'OB-CUSTOMER' AND GL.RefID = C.CustomerId
WHERE C.CustomerId = @CustomerId;



END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomers]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetCustomers] 
AS
BEGIN
SELECT CustomerId, BillingName, BillingAddress1, PhoneNo FROM tCustomers WHERE ACtive = 1
ORDER BY BillingName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetFiscalYear]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetFiscalYear] @FiscalYearId INT
AS
BEGIN
		SELECT FiscalYearId, FromDate, ToDate, Active FROM tFiscalYears
		 WHERE FiscalYearId = @FiscalYearId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetFiscalYearList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetFiscalYearList]
AS
BEGIN

SELECT FiscalYearId,FromDate, ToDate, IIF(Active = 1, 'Y','N') Active FROM tFiscalYears
ORDER BY ToDate DESC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetGeneralLedger]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetGeneralLedger] @COAId BIGINT,@FromDate  DATETIME, @ToDate DATETIME
as
BEGIN

DECLARE @OpeningBalance DECIMAL(10,2);
DECLARE @EndingBalance DECIMAL(10,2);
DECLARE @COATypeValue VARCHAR(10);

SELECT @COATypeValue = dbo.GetCOATypeValue(@COAId);

IF(@COATypeValue = 'DEBIT')
BEGIN

	SELECT @OpeningBalance = ISNULL(SUM(Debit-Credit),0)
	FROM tGL
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) <CAST(@FromDate as Date));
	
	SELECT @EndingBalance = @OpeningBalance + ISNULL(SUM(Debit-Credit),0)
	FROM tGL 
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));

	SELECT  @OpeningBalance OpeningBalance, @EndingBalance EndingBalance, CAST(@FromDate as Date) FromDate, CAST(@ToDate as Date) ToDate;

	SELECT ROW_NUMBER() OVER (Order By GL.TransactionDate, RecordId) as SerialNumber, GL.TransactionDate, DBO.GetRefNumberByRefId(RefType, RefID) RefNumber, GL.Remarks, Debit, Credit,
	@OpeningBalance + SUM(Debit - Credit) OVER (PARTITION BY COAId ORDER BY GL.TransactionDate, RecordId)  as Balance
	FROM tGL GL
	WHERE GL.COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));
END
ELSE 
BEGIN

	SELECT @OpeningBalance = ISNULL(SUM(Credit-Debit),0)
	FROM tGL
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) <CAST(@FromDate as Date));
	
	SELECT @EndingBalance = @OpeningBalance + ISNULL(SUM(Credit-Debit),0)
	FROM tGL 
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));

	SELECT  @OpeningBalance OpeningBalance, @EndingBalance EndingBalance, @FromDate FromDate, @ToDate ToDate;

	SELECT ROW_NUMBER() OVER (Order By GL.TransactionDate, RecordId) as SerialNumber, GL.TransactionDate, DBO.GetRefNumberByRefId(RefType, RefID) RefNumber, GL.Remarks, Debit, Credit,
	@OpeningBalance + SUM(Credit - Debit) OVER (PARTITION BY COAId ORDER BY GL.TransactionDate, RecordId)  as Balance
	FROM tGL GL
	WHERE GL.COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));
END

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetGLAccounts]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetGLAccounts]
as
BEGIN
SELECT COAID, COAName, COACode, ISNULL(COAType,'') COAType  FROM tCOA  C
LEFT JOIN tCOATypes T ON C.COATypeId = T.COATypeId
WHERE C.COACode NOT IN('Vendor','Customer');

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetItem]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetItem] @ItemId INT
AS
BEGIN

SELECT ItemId, ItemName, CategoryId , DBO.GetCategoryHeirarchy(CategoryId) Category, CostPrice, SellPrice, TaxTypeId, ImagePath, Active FROM tItems WHERE ItemId = @ItemId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemAvgCostPriceList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetItemAvgCostPriceList]
as
BEGIN
SELECT I.ItemId, I.ItemName, S.AvgCostPrice FROM vItemAvgCostPrice S
INNER JOIN tItems I ON I.ItemId = S.ItemId
WHERE I.Active = 1
ORDER BY S.AvgCostPrice, I.ItemName ASC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemLedger]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_GetItemLedger] @ItemId INT, @FromDate DATETIME, @ToDate DATETIME
AS
BEGIN
	DECLARE @OpeningBalance DECIMAL(10, 2);
	DECLARE @EndingBalance DECIMAL(10, 2);

	SELECT @OpeningBalance = ISNULL(SUM(Qty), 0)
	FROM tItemStock
	WHERE ItemId = @ItemId
		AND (CAST(CreatedOn AS DATE) < CAST(@FromDate AS DATE));

	SELECT @EndingBalance = @OpeningBalance + ISNULL(SUM(Qty), 0)
	FROM tItemStock
	WHERE ItemId = @ItemId
		AND (
			CAST(CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
			AND CAST(CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
			);

	SELECT @OpeningBalance OpeningBalance, @EndingBalance EndingBalance, @FromDate FromDate, @ToDate ToDate;

	SELECT ROW_NUMBER() OVER (
			ORDER BY GL.CreatedOn, GL.RecordId
			) AS SerialNumber,
			 GL.CreatedOn,
			  DBO.GetRefNumberByRefId(RefType, RefID) RefNumber,
			  CASE GL.RefType WHEN 'PI' THEN 'Purchase' WHEN 'PR' THEN 'Purchase Return' WHEN 'SI' THEN 'Sales' WHEN 'SR' THEN 'Sale Return' WHEN 'BI' THEN 'Bad Inventory' END RefType,
			   IIF(GL.RefType = 'PI' OR GL.RefType = 'PR',V.BillingName,IIF(GL.RefType = 'SI' OR GL.RefType = 'SR', C.BillingName,'N/A')) PartyName,
			   CASE GL.RefType WHEN  'PI' THEN IRD.CostPrice WHEN 'PR' THEN PRD.CostPrice END CostPrice,
			   CASE GL.RefType WHEN  'SI' THEN DCD.SellPrice WHEN 'SR' THEN SRD.SellPrice END SellPrice,
			   IIF(Direction = 1, GL.Qty, 0) QtyIN, IIF(Direction = 2, ABS(GL.Qty), 0) QtyOUT, @OpeningBalance + SUM(GL.Qty) OVER (
			PARTITION BY GL.ItemId ORDER BY GL.CreatedOn, GL.RecordId
			) AS Balance
	FROM tItemStock GL
	LEFT JOIN tPurchaseInvoices IR ON IR.PurchaseInvoiceId = GL.RefId
		AND GL.RefType = 'PI'
		LEFT JOIN tPurchaseInvoiceDetail IRD ON IRD.PurchaseInvoiceId = IR.PurchaseInvoiceId AND IRD.ItemId = GL.ItemId

	LEFT JOIN tPurchaseReturns PR ON PR.PurchaseReturnId = GL.RefId
		AND GL.RefType = 'PR'
		LEFT JOIN tPurchaseReturnDetail PRD ON PRD.PurchaseReturnId = PR.PurchaseReturnId AND PRD.ItemId = GL.ItemId
	LEFT JOIN tSaleInvoices DC ON DC.SaleInvoiceId = GL.RefId
		AND GL.RefType = 'SI'
		LEFT JOIN tSaleInvoiceDetail DCD ON DCD.SaleInvoiceId = DC.SaleInvoiceId AND DCD.ItemId = GL.ItemId
	LEFT JOIN tSaleReturns SR ON SR.SaleReturnId = GL.RefId
		AND GL.RefType = 'SR'
		LEFT JOIN tSaleReturnDetail SRD On SRD.SaleReturnId = SR.SaleReturnId AND SRD.ItemId = GL.ItemId
	LEFT JOIN tBadInventories BI ON BI.RecordId = GL.RefId
		AND GL.RefType = 'BI'
	LEFT JOIN tVendors V ON (
			V.VendorId = PR.VendorId
			AND GL.RefType = 'PR'
			)
		OR (
			V.VendorId = IR.VendorId
			AND GL.RefType = 'PI'
			)
	LEFT JOIN tCustomers C ON (
			C.CustomerId = DC.CustomerId
			AND GL.RefType = 'SI'
			)
		OR (
			C.CustomerId = SR.CustomerId
			AND GL.RefType = 'SR'
			)
	WHERE GL.ItemId = @ItemId
		AND (
			CAST(GL.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
			AND CAST(GL.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
			);
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetItemList]
AS
BEGIN

SELECT ItemId, DBO.GetCategoryHeirarchy(CategoryId) Category, ItemName,  IIF(Active = 1, 'Y','N') Active FROM tItems
ORDER BY ItemName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemReport]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetItemReport] @CategoryId BIGINT
as
BEGIN

;WITH C
(
Id,
ParentId,
Name
)
as
(
SELECT CategoryId, ParentId, CategoryName  FROM tCategories WHERE CategoryId = @CategoryId OR @CategoryId = 0
UNION ALL
SELECT CategoryId, A.ParentId, A.CategoryName FROM tCategories  A
INNER JOIN C ON C.Id =A.ParentId
)
SELECT  ROW_NUMBER() OVER (Order By I.ItemId) as SerialNumber, I.ItemId,DBO.GetCategoryHeirarchy(I.CategoryId) Category ,ItemName,  ISNULL(S.Qty,0) Qty FROM C
INNER JOIN tItems I ON I.CategoryId = C.Id
LEFT JOIN vItemStock S ON S.ItemId = I.ItemId
WHERE I.Active = 1; 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetItems]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetItems]
AS

BEGIN

SELECT I.ItemId,DBO.GetCategoryHeirarchy(CategoryId) Category,ItemName, ISNULL(s.Qty,0) StockQty, I.CostPrice, I.SellPrice, ISNULL(T.TaxPercentage,0) TaxPercentage FROM tItems I
LEFT JOIN tTaxTypes T ON T.TaxTypeId = I.TaxTypeId
LEFT JOIN vItemStock S ON S.ItemId = I.ItemId
WHERE I.Active = 1
ORDER BY ItemName ASC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemStockList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetItemStockList]
as
BEGIN
SELECT I.ItemId, DBO.GetCategoryHeirarchy(I.CategoryId) Category, I.ItemName,  S.Qty FROM vItemStock S
INNER JOIN tItems I ON I.ItemId = S.ItemId

WHERE I.Active = 1
ORDER BY I.ItemName ASC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetJournalVoucher]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetJournalVoucher]
@JVId BIGINT
As
BEGIN

SELECT JV.JVId, JVNumber, Amount, JVDate, Remarks,JV.DebitCOAId, jv.CreditCOAId, C.COAName CreditCOAName, d.COAName DebitCOAName FROM tJournalVouchers JV
INNER JOIN tCOA D On D.COAID = JV.DebitCOAId
INNER JOIN tCOA C On C.COAID = JV.CreditCOAId
WHERE JVId = @JVId;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetJournalVoucherList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetJournalVoucherList]
As
BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();
SELECT JV.JVId, JVNumber, Amount, JVDate, DebitCOA.COAName DebitCOAName, CreditCOA.COAName CreditCOAName FROM tJournalVouchers JV
INNER JOIN tCOA DebitCOA ON DebitCOA.COAID = JV.DebitCOAId
INNER JOIN tCOA CreditCOA ON CreditCOA.COAID = JV.CreditCOAId
WHERE CAST(JV.JVDate as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(JV.JVDate as Date) <= CAST(@FiscalYearToDate as DATE) 
ORDER BY JVDate DESC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetJVAccounts]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetJVAccounts]
as
BEGIN
SELECT COAID, COAName, COACode, ISNULL(COAType,'') COAType  FROM tCOA  C
LEFT JOIN tCOATypes T ON C.COATypeId = T.COATypeId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetOBList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetOBList] @COAType VARCHAR(20)
AS
BEGIN

IF( @COAType = 'CUSTOMER')
BEGIN
	SELECT C.CustomerId RefId, C.BillingName, IsNULL(CASE WHEN Debit> 0 THEN Amount WHEN Credit > 0 THEN Amount *-1 END,0) OB FROM tCustomers C
	INNER JOIN tCOA COA On COA.RefID = C.CustomerId AND COA.COACode = 'CUSTOMER'
	LEFT JOIN tGL GL ON GL.RefID = C.CustomerId AND GL.RefType = 'OB-CUSTOMER' AND GL.COAID = COA.COAID
	WHERE C.Active  = 1
	ORDER BY BillingName ASC;
END
ELSE IF( @COAType = 'VENDOR')
BEGIN
	SELECT C.VendorId RefId, C.BillingName, IsNULL(CASE WHEN Credit> 0 THEN Amount WHEN Debit > 0 THEN Amount *-1 END,0) OB FROM tVendors C
	INNER JOIN tCOA COA On COA.RefID = C.VendorId AND COA.COACode = 'VENDOR'
	LEFT JOIN tGL GL ON GL.RefID = C.VendorId AND GL.RefType = 'OB-VENDOR' AND GL.COAID = COA.COAID
	WHERE C.Active  = 1
	ORDER BY BillingName ASC;
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetPaymentVoucher]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetPaymentVoucher]
@VoucherId BIGINT
AS

BEGIN

SELECT VR.VoucherId,  VR.VoucherNumber, VR.PaidOn, VR.TotalAmount, Remarks FROM tPaymentVouchers VR
WHERE VoucherId = @VoucherId;

SELECT BillingName, V.VendorId, Amount FROM tPaymentVoucherDetail VR
INNER JOIN tVendors V ON V.VendorId = VR.VendorId WHERE VoucherId = @VoucherId;


END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetPaymentVoucherList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetPaymentVoucherList]
AS

BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();
SELECT VR.VoucherId, VR.VoucherNumber, VR.Remarks, VR.PaidOn, VR.TotalAmount FROM tPaymentVouchers VR
WHERE CAST(VR.PaidOn as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(VR.PaidOn as Date) <= CAST(@FiscalYearToDate as DATE)
ORDER BY PaidOn DESC;
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetPurchaseInvoice]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_GetPurchaseInvoice] @PurchaseInvoiceId BIGINT
AS
BEGIN
	SELECT PurchaseInvoiceId, PurchaseInvoiceNumber, V.VendorId, R.Remarks, V.BillingName, PurchaseInvoiceDate, AdditionalDiscount, R.TotalAmount, (SELECT SUM(Qty) FROM tPurchaseInvoiceDetail WHERE PurchaseInvoiceId = R.PurchaseInvoiceId) TotalQty
	FROM tPurchaseInvoices R
	INNER JOIN tVendors V ON V.VendorId = R.VendorId
	WHERE PurchaseInvoiceId = @PurchaseInvoiceId;

	SELECT ROW_NUMBER() OVER (
			ORDER BY D.ItemId
			) AS SerialNumber, d.PurchaseInvoiceId,DBO.GetCategoryHeirarchy(categoryid) Category,  D.ItemId, I.ItemName, D.CostPrice, D.Qty, D.Tax, D.Discount, D.Amount
	FROM tPurchaseInvoiceDetail D
	INNER JOIN tItems I ON I.ItemId = D.ItemId
	WHERE PurchaseInvoiceId = @PurchaseInvoiceId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetPurchaseInvoiceList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetPurchaseInvoiceList]
AS

BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();

SELECT PurchaseInvoiceId, PurchaseInvoiceNumber,V.VendorId,V.BillingName, PurchaseInvoiceDate ,PO.TotalAmount FROM tPurchaseInvoices PO
INNER JOIN tVendors V ON V.VendorId = PO.VendorId
WHERE CAST(PO.PurchaseInvoiceDate as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(PO.PurchaseInvoiceDate as Date) <= CAST(@FiscalYearToDate as DATE) 
ORDER BY PO.PurchaseInvoiceDate DESC;
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetPurchaseReturn]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetPurchaseReturn]
@PurchaseReturnId BIGINT

AS
BEGIN

SELECT PurchaseReturnId, PurchaseReturnNumber, V.VendorId, V.BillingName, ReturnDate,Remarks,  TotalAmount,(SELECT SUM(Qty) FROM tPurchaseReturnDetail WHERE PurchaseReturnId = R.PurchaseReturnId) TotalQty FROM tPurchaseReturns R
 INNER JOIN tVendors V ON V.VendorId = R.VendorId
 WHERE PurchaseReturnId = @PurchaseReturnId;


SELECT ROW_NUMBER() OVER (Order By D.ItemId) as SerialNumber,DBO.GetCategoryHeirarchy(categoryid) Category, PurchaseReturnId, D.ItemId, I.ItemName,  D.CostPrice, D.Qty, D.Tax, D.Discount, D.Amount FROM tPurchaseReturnDetail D
INNER JOIN tItems I ON I.ItemId = D.ItemId

WHERE PurchaseReturnId = @PurchaseReturnId;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetPurchaseReturnableItems]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetPurchaseReturnableItems] @VendorId INT
as

BEGIN

SELECT I.ItemId,ISNULL(t.TaxPercentage,0) TaxPercentage,  I.CostPrice, DBO.GetCategoryHeirarchy(I.CategoryId) Category, ItemName, ISNULL(S.Qty,0) StockQty, D.Qty ReturnableQty FROM vPurchaseReturnableItems D
INNER JOIN tItems I ON I.ItemId = D.ItemId
LEFT JOIN tTaxTypes T ON t.TaxTypeId = i.TaxTypeId
LEFT JOIN vItemStock S On S.ItemId = I.ItemId
WHERE D.VendorId = @VendorId;




END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetPurchaseReturnList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetPurchaseReturnList]
AS

BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();

SELECT PurchaseReturnId, PurchaseReturnNumber,V.VendorId,V.BillingName, ReturnDate ,PO.TotalAmount   FROM tPurchaseReturns PO
INNER JOIN tVendors V ON V.VendorId = PO.VendorId
WHERE CAST(PO.ReturnDate as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(PO.ReturnDate as Date) <= CAST(@FiscalYearToDate as DATE)
ORDER BY PO.ReturnDate  DESC;



END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetReceiptVoucher]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetReceiptVoucher]
@VoucherId BIGINT
AS

BEGIN

SELECT VR.VoucherId,  VR.VoucherNumber, VR.ReceivedOn, VR.TotalAmount, Remarks FROM tReceiptVouchers VR

WHERE VoucherId = @VoucherId;

SELECT C.CustomerId, BillingName, Amount FROM tReceiptVoucherDetail VR
INNER JOIN tCustomers C On C.CustomerId = VR.CustomerId
WHERE vr.VoucherId = @VoucherId;
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetReceiptVoucherList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetReceiptVoucherList]
AS

BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();

SELECT VR.VoucherId, VR.VoucherNumber,  VR.ReceivedOn, VR.TotalAmount FROM tReceiptVouchers VR

WHERE CAST(VR.ReceivedOn as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(VR.ReceivedOn as Date) <= CAST(@FiscalYearToDate as DATE)
ORDER BY ReceivedOn DESC;

END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetSaleInvoice]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_GetSaleInvoice] @SaleInvoiceId BIGINT
AS
BEGIN
	SELECT SaleInvoiceId
		,SaleInvoiceNumber
		,DC.CustomerId
		,C.BillingName
		,SaleInvoiceDate
		,AdditionalDiscount
		,DC.Remarks
		,DC.TotalAmount,
		(SELECT SUM(Qty) FROM tSaleInvoiceDetail WHERE SaleInvoiceId = DC.SaleInvoiceId) TotalQty 
	FROM tSaleInvoices DC
	INNER JOIN tCustomers C ON C.CustomerId = DC.CustomerId
	
	WHERE SaleInvoiceId = @SaleInvoiceId;

	SELECT ROW_NUMBER() OVER (
			ORDER BY D.ItemId
			) AS SerialNumber
		,SaleInvoiceId
		,D.ItemId
		,I.ItemName
		,DBO.GetCategoryHeirarchy(categoryid) Category,
		D.SellPrice
		,D.Qty
		,D.Tax
		,D.Discount
		,D.Amount
		
	FROM tSaleInvoiceDetail D
	INNER JOIN tItems I ON I.ItemId = D.ItemId
	
	WHERE SaleInvoiceId = @SaleInvoiceId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetSaleInvoiceList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_GetSaleInvoiceList]
AS
BEGIN
	DECLARE @FiscalYearFromDate DATE;
	DECLARE @FiscalYearToDate DATE;

	SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
	SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();

	SELECT SaleInvoiceId, SaleInvoiceNumber, V.BillingName, SaleInvoiceDate, SO.TotalAmount
	FROM tSaleInvoices SO
	INNER JOIN tCustomers V ON V.CustomerId = SO.CustomerId
	WHERE CAST(SO.SaleInvoiceDate AS DATE) >= CAST(@FiscalYearFromDate AS DATE)
		AND CAST(SO.SaleInvoiceDate AS DATE) <= CAST(@FiscalYearToDate AS DATE)
	ORDER BY SO.SaleInvoiceDate DESC;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetSaleReturn]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetSaleReturn]
@SaleReturnId BIGINT

AS
BEGIN

SELECT SaleReturnId, SaleReturnNumber, DC.CustomerId,C.BillingName, ReturnDate, Remarks,  DC.TotalAmount,(SELECT SUM(Qty) FROM tSaleReturnDetail WHERE SaleReturnId = DC.SaleReturnId) TotalQty FROM tSaleReturns DC
INNER JOIN tCustomers C ON C.CustomerId = DC.CustomerId
WHERE SaleReturnId = @SaleReturnId;


SELECT ROW_NUMBER() OVER (Order By D.ItemId) as SerialNumber,SaleReturnId,DBO.GetCategoryHeirarchy(categoryid) Category, D.ItemId, I.ItemName, D.SellPrice, D.Qty, D.Tax, D.Discount, D.Amount FROM tSaleReturnDetail D
INNER JOIN tItems I ON I.ItemId = D.ItemId

WHERE SaleReturnId = @SaleReturnId;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetSaleReturnableItems]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetSaleReturnableItems] @CustomerId INT
as
BEGIN
SELECT I.ItemId, ISNULL(t.TaxPercentage,0) TaxPercentage,  I.SellPrice, DBO.GetCategoryHeirarchy(I.CategoryId) Category, ItemName, ISNULL(S.Qty,0) StockQty, D.Qty ReturnableQty FROM vSaleReturnableItems D
INNER JOIN tItems I ON I.ItemId = D.ItemId
LEFT JOIN vItemStock S On S.ItemId = I.ItemId
LEFT JOIN tTaxTypes T ON t.TaxTypeId = i.TaxTypeId
WHERE D.CustomerId = @CustomerId;
;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetSaleReturnList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetSaleReturnList]
AS

BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();

SELECT SaleReturnId, SaleReturnNumber,V.CustomerId,V.BillingName, ReturnDate ,SO.TotalAmount   FROM tSaleReturns SO
INNER JOIN tCustomers V ON V.CustomerId = SO.CustomerId
WHERE CAST(ReturnDate as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(ReturnDate as Date) <= CAST(@FiscalYearToDate as DATE)
ORDER BY SO.ReturnDate DESC;


END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetShipmentCharges]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetShipmentCharges]
@SCId BIGINT
AS

BEGIN

SELECT VR.SCId,  VR.SCNumber, VR.SCDate, VR.TotalAmount, Remarks FROM tShipmentCharges VR

WHERE SCId = @SCId;

SELECT C.CustomerId, BillingName, Amount, CR.CarrierId, CR.CarrierName FROM tShipmentChargesDetail VR
INNER JOIN tCarriers CR On CR.CarrierId = VR.CarrierId
INNER JOIN tCustomers C On C.CustomerId = VR.CustomerId
WHERE vr.SCId = @SCId;
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetShipmentChargesList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetShipmentChargesList]
AS

BEGIN
DECLARE @FiscalYearFromDate DATE;
DECLARE @FiscalYearToDate DATE;
SET @FiscalYearFromDate = DBO.GetActiveFiscalYearFromDate();
SET @FiscalYearToDate = DBO.GetActiveFiscalYearToDate();

SELECT VR.SCId, VR.SCNumber,  VR.SCDate, VR.TotalAmount FROM tShipmentCharges VR

WHERE CAST(VR.SCDate as Date) >= CAST(@FiscalYearFromDate as DATE) 
AND CAST(VR.SCDate as Date) <= CAST(@FiscalYearToDate as DATE)
ORDER BY SCDate DESC;

END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetStockItems]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetStockItems]
as
BEGIN
SELECT I.ItemId,DBO.GetCategoryHeirarchy(I.CategoryId)Category ,  ItemName,  S.Qty FROM vItemStock S
INNER JOIN tItems I ON I.ItemId = S.ItemId

WHERE I.Active = 1
ORDER BY ItemName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetTaxType]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetTaxType] @TaxTypeId INT
AS
BEGIN
		SELECT TaxTypeId, TaxTypeName, TaxPercentage FROM tTaxTypes
		 WHERE TaxTypeId = @TaxTypeId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetTaxTypeList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetTaxTypeList]
AS
BEGIN

SELECT TaxTypeId, TaxTypeName, TaxPercentage FROM tTaxTypes;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetTaxTypes]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetTaxTypes] 
AS
BEGIN

SELECT TaxTypeId, TaxTypeName FROM tTaxTypes;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetVendor]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetVendor] @VendorId INT
AS
BEGIN

SELECT VendorId, BillingName, BillingAddress1, BillingAddress2, PhoneNo, TelNo, NTNNo, STRNo,  Active FROM tVendors WHERE VendorId = @VendorId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetVendorBalance]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetVendorBalance] @VendorId INT, @Timestamp DATETIME
as
BEGIN
DECLARE @COAId BIGINT;
DECLARE @RecordId BIGINT;
	DECLARE @PreviousBalance DECIMAL(10, 2);

SET @COAId = DBO.GetCOAIdByRefId('VENDOR', @VendorId);



	SELECT @PreviousBalance =  ISNULL(SUM(Credit-Debit),0)
	FROM tGL
	WHERE COAID = @COAId AND TransactionDate < @Timestamp; 

	SELECT @PreviousBalance AS PreviousBalance, 0 AS GrossAmount, 0 AS NetBalance;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetVendorLedger]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetVendorLedger] @VendorId INT,@FromDate  DATETIME, @ToDate DATETIME
as
BEGIN
DECLARE @COAId BIGINT;
DECLARE @OpeningBalance DECIMAL(10,2);
DECLARE @EndingBalance DECIMAL(10,2);
SET @COAId = DBO.GetCOAIdByRefId('Vendor', @VendorId);





	SELECT @OpeningBalance = ISNULL(SUM(Credit-Debit),0)
	FROM tGL
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) <CAST(@FromDate as Date));
	
	SELECT @EndingBalance = @OpeningBalance + ISNULL(SUM(Credit-Debit),0)
	FROM tGL 
	WHERE COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));
	
	SELECT  @OpeningBalance OpeningBalance, @EndingBalance EndingBalance, @FromDate FromDate, @ToDate ToDate;
	

	SELECT ROW_NUMBER() OVER (Order By GL.TransactionDate, GL.RecordId) as SerialNumber, GL.TransactionDate, DBO.GetRefNumberByRefId(RefType, RefID) RefNumber, GL.Remarks, Debit, Credit,
	@OpeningBalance + SUM(Credit - Debit) OVER (PARTITION BY COAId ORDER BY GL.TransactionDate, GL.RecordId)  as Balance
	FROM tGL GL
	WHERE GL.COAID = @COAId AND (CAST(TransactionDate as Date) >=CAST(@FromDate as Date) AND CAST(TransactionDate as Date) <=CAST(@ToDate as Date));
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetVendorList]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetVendorList]
AS
BEGIN

SELECT VendorId, BillingName, IIF(Active = 1, 'Y','N') Active FROM tVendors
ORDER BY BillingName ASC;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetVendorOB]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetVendorOB] @VendorId BIGINT
as
BEGIN

DECLARE @COAId BIGINT;
SET @COAId = dbo.GetCOAIdByRefId('VENDOR', @VendorId);


SELECT @COAId as COAId, C.VendorId as RefId, C.BillingName, IsNULL(CASE WHEN Credit> 0 THEN Amount WHEN Debit > 0 THEN Amount *-1 END,0) OB FROM tVendors C
LEFT JOIN tGL GL ON GL.COAID = @COAId AND GL.RefType = 'OB-VENDOR' AND GL.RefID = C.VendorId
WHERE C.VendorId = @VendorId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetVendors]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetVendors] 
AS
BEGIN
SELECT VendorId, BillingName, BillingAddress1, PhoneNo  FROM tVendors WHERE ACtive = 1;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveBadInventory]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveBadInventory] @RecordId BIGINT, @ItemId INT, @Qty INT, @Remarks VARCHAR(200), @TransactedBy INT
AS
BEGIN
	DECLARE @StockQty BIGINT;

	IF (@RecordId = 0)
	BEGIN
		--SET @StockQty = ISNULL((
		--			SELECT SUM(Qty)
		--			FROM vItemStock
		--			WHERE ItemId = @ItemId
		--			), 0);

		--IF (@Qty > @StockQty)
		--BEGIN
		--	EXEC sp_SendError 'Qty Exceeded.';
		--END

		INSERT INTO tBadInventories (BadInventoryNumber, ItemId, Qty, Remarks, CreatedBy, CreatedOn)
		VALUES (DBO.GetAGNumber('BI'), @ItemId, @Qty, @Remarks, @TransactedBy, GETDATE());

		SELECT @RecordId = IDENT_CURRENT('tBadInventories');

		EXEC sp_SaveInventory @ItemId, @RecordId, 'BI', 2, @Qty, @TransactedBy;
	END
	ELSE
	BEGIN
		DELETE
		FROM tItemStock
		WHERE RefId = @RecordId
			AND RefType = 'BI';

		--SET @StockQty = ISNULL((
		--			SELECT SUM(Qty)
		--			FROM vItemStock
		--			WHERE ItemId = @ItemId
		--			), 0);

		--IF (@Qty > @StockQty)
		--BEGIN
		--	EXEC sp_SendError 'Qty Exceeded.';
		--END

		UPDATE tBadInventories
		SET Qty = @Qty, Remarks = @Remarks, UpdatedOn = GETDATE(), UpdatedBy = @TransactedBy
		WHERE RecordId = @RecordId;

		EXEC sp_SaveInventory @ItemId, @RecordId, 'BI', 2, @Qty, @TransactedBy;
	END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveCarrier]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveCarrier]
@CarrierId INT,
@CarrierName VARCHAR(50),
@Active BIT,
@TransactedBy INT
AS

BEGIN
DECLARE @COAId BIGINT;
IF @CarrierId = 0
BEGIN

	INSERT INTO tCarriers(CarrierName, CreatedOn, Active)
	VALUES(@CarrierName, GETDATE(), @Active);

	SELECT @CarrierId = IDENT_CURRENT('tCarriers');
	EXEC sp_SaveExternalCOA @CarrierId, 'CARRIER', @CarrierName, @COAId, @TransactedBy; 
	
	END
ELSE
BEGIN

	UPDATE tCarriers
	SET CarrierName = @CarrierName,
	Active = @Active
	WHERE CarrierId = @CarrierId;

	EXEC sp_SaveExternalCOA @CarrierId, 'CARRIER', @CarrierName, @COAId, @TransactedBy; 
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveCategory]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveCategory]
@CategoryId INT,
@ParentId INT,
@CategoryName VARCHAR(50),
@Active BIT,
@TransactedBy INT
AS

BEGIN
IF @CategoryId = 0
BEGIN

	INSERT INTO tCategories(CategoryName, ParentId, CreatedOn, Active)
	VALUES(@CategoryName, @ParentId,  GETDATE(), @Active);
	
	END
ELSE
BEGIN

	UPDATE tCategories
	SET CategoryName = @CategoryName,
	ParentId = @ParentId,
	Active = @Active
	WHERE CategoryId = @CategoryId;
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveCompanyInfo]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveCompanyInfo] @CompanyName VARCHAR(50),
@AddressLine1 VARCHAR(100), 
@AddressLine2 VARCHAR(100),
@NTNNo VARCHAR(25),
@STRNo VARCHAR(25),
@TelNo VARCHAR(20),
@ContactPerson VARCHAR(20),
@LogoPath VARCHAR(200),
@Email VARCHAR(50),
@ShortDesc VARCHAR(500),
@InvoiceFooterRemarks NVARCHAR(500),
@Slogan NVARCHAR(500)
AS
BEGIN

IF((SELECT COUNT(*) FROM tCompanyInfo) = 0)
BEGIN
	INSERT INTO tCompanyInfo(CompanyName, AddressLine1, AddressLine2, NTNNo, STRNo, TelNo, ContactPerson, LogoPath, Email, InvoiceFooterRemarks, ShortDesc, Slogan)
	VALUES(@CompanyName, @AddressLine1, @AddressLine2, @NTNNo, @STRNo, @TelNo, @ContactPerson, @LogoPath, @Email, @InvoiceFooterRemarks, @ShortDesc, @Slogan);

END
ELSE
BEGIN
		UPDATE tCompanyInfo
		SET
		CompanyName = @CompanyName,
		AddressLine1 = @AddressLine1,
		AddressLine2 = @AddressLine2,
		NTNNo = @NTNNo,
		STRNo = @STRNo,
		TelNo = @TelNo,
		ContactPerson = @ContactPerson,
		LogoPath = @LogoPath,
		ShortDesc = @ShortDesc,
		InvoiceFooterRemarks = @InvoiceFooterRemarks,
		Email  = @Email, Slogan = @Slogan
		
END


END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveCustomer]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveCustomer]
@CustomerId INT,
@BillingName VARCHAR(50),
@BillingAddress1 VARCHAR(100),
@BillingAddress2 VARCHAR(100),
@ShippingName VARCHAR(50),
@ShippingAddress1 VARCHAR(100),
@ShippingAddress2 VARCHAR(100),
@PhoneNo VARCHAR(100),
@TelNo VARCHAR(100),
@NTNNo varchar(50),
@STRNo varchar(50),
@Active BIT,
@TransactedBy INT
AS

BEGIN
DECLARE @COAId BIGINT;

IF @CustomerId = 0
BEGIN
	IF((SELECT COUNT(*) FROM tCustomers WHERE BillingName  = @BillingName) > 0)
	BEGIN
		EXEC sp_SendError 'Record Already Exists.';
	END
	INSERT INTO tCustomers(BillingName, BillingAddress1, BillingAddress2, ShippingName, ShippingAddress1, ShippingAddress2, NTNNo, STRNo, PhoneNo, TelNo,  Active, CreatedBy, CreatedOn)
	VALUES(@BillingName, @BillingAddress1, @BillingAddress2,@ShippingName, @ShippingAddress1, @ShippingAddress2, @PhoneNo, @TelNo, @NTNNo, @STRNo,  @Active, @TransactedBy, GETDATE());

	SELECT @CustomerId = IDENT_CURRENT('tCustomers');
	EXEC sp_SaveExternalCOA @CustomerId, 'CUSTOMER', @BillingName, @COAId, @TransactedBy; 
	END
	ELSE
	BEGIn
	IF((SELECT COUNT(*) FROM tCustomers WHERE BillingName  = @BillingName AND CustomerId <> @CustomerId) > 0)
	BEGIN
		EXEC sp_SendError 'Record Already Exists.';
	END
	UPDATE tCustomers
	SET BillingName = @BillingName,
	BillingAddress1 = @BillingAddress1,
	BillingAddress2 = @BillingAddress2,
	ShippingName = @ShippingName,
	ShippingAddress1 = @ShippingAddress1,
	ShippingAddress2 = @ShippingAddress2,
	PhoneNo = @PhoneNo,
	TelNo = @TelNo,
		NTNNo = @NTNNo,
	STRNo = @STRNo,

	Active = @Active,
	UpdatedBy = @TransactedBy,
	UpdatedOn  = GETDATE()
	WHERE CustomerId = @CustomerId
	EXEC sp_SaveExternalCOA @CustomerId, 'CUSTOMER', @BillingName, @COAId, @TransactedBy; 
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveExternalCOA]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveExternalCOA] @RefId BIGINT, @COACOde VARCHAR(10), @RefName VARCHAR(50), @COAId BIGINT OUTPUT, @TransactedBy INT
as
BEGIN

		IF((SELECT COUNT(*) FROM tCOA WHERE RefID = @RefId AND COACode = @COACOde)  = 0)
		BEGIN
			INSERT INTO tCOA(COAName, RefID, COACode, CreatedOn , CreatedBy)
			VALUES (@RefName,  @RefId, @COACOde, GETDATE(), @TransactedBy);
		END

		SELECT @COAId =  COAID FROM tCOA WHERE RefID = @RefId AND COACode = @COACOde;


END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveFiscalYear]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveFiscalYear]
@FiscalYearId INT,
@FromDate DATETIME,
@ToDate DATETIME,
@Active BIT,
@TransactedBy INT
AS

BEGIN
IF @FiscalYearId = 0
BEGIN
IF(@Active = 1) 
BEGIN
	UPDATE tFiscalYears SET Active = 0;
END
	INSERT INTO tFiscalYears(FromDate, ToDate, Active)
	VALUES(@FromDate, @ToDate, @Active);
	
	END
ELSE
BEGIN
IF(@Active = 1) 
BEGIN
	UPDATE tFiscalYears SET Active = 0;
END
	UPDATE tFiscalYears
	SET FromDate = @FromDate,
	ToDate = @ToDate,
	Active = @Active
	WHERE FiscalYearId = @FiscalYearId;
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveGL]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveGL] @COAId BIGINT, @RefType VARCHAR(50), @RefId BIGINT, @TransactionDate DATETIME, @Remarks VARCHAR(300), @Debit DECIMAL(10,2), @Credit DECIMAL(10,2), @Amount DECIMAL(10,2), @TransactedBy INT
AS

BEGIN
INSERT INTO tGL(COAID, RefType, RefID, TransactionDate, Remarks, Debit, Credit, Amount, CreatedBy, CreatedOn)
VALUES(@COAId, @RefType, @RefId, @TransactionDate, @Remarks, @Debit, @Credit, @Amount,@TransactedBy, GETDATE() );
END


GO
/****** Object:  StoredProcedure [dbo].[sp_SaveGLOpeningBalance]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveGLOpeningBalance] @COAId BIGINT,@COACode VARCHAR(20), @RefId BIGINT, @Debit DECIMAL(10,2), @Credit DECIMAL(10,2), @Amount DECIMAL(10,2), @TransactedBy INT
AS

BEGIN
DECLARE @RecordId BIGINT;
SELECT @RecordId = COUNT(*) FROM tGL WHERE RefID = @RefId AND RefType = CONCAT('OB-',@COACode) AND COAID = @COAId;
DECLARE @SaleCOAId BIGINT;
DECLARE @CashCOAId BIGINT;
DECLARE @PurchaseCOAId BIGINT;
DECLARE @SystemStartDate DATETIME;
SET @SystemStartDate = dbo.GetSysIniValue('SYS_START_DATE');

SET @SaleCOAId  = DBO.GetCOAIdByCode('SALE');
SET @CashCOAId  = DBO.GetCOAIdByCode('CASH');
SET @PurchaseCOAId  = DBO.GetCOAIdByCode('PURCHASE');
SELECT @RecordId, @SaleCOAId, @CashCOAId, @RefId, @COAId, @COACode;

IF(@RecordId  = 0)
BEGIN



	 IF(@COACode = 'CUSTOMER')
	 BEGIN
		 IF(@Debit > 0)
		 BEGIN
		 --Customer Debit
		 -- Sales Credit
			 EXEC sp_SaveGL @COAId,'OB-CUSTOMER',@RefId, @SystemStartDate, 'Opening Balance',@Debit, 0, @Amount, @TransactedBy
			 EXEC sp_SaveGL @SaleCOAId,'OB-CUSTOMER',@RefId, @SystemStartDate, 'Opening Balance',0, @Debit,  @Amount, @TransactedBy
		 END
		 ELSE
		 BEGIN
		 SET @Debit = ABS(@Debit);
		 SET @Amount = ABS(@Amount);
		 -- Cash Debit 
		 -- Customer Credit
			 EXEC sp_SaveGL @CashCOAId,'OB-CUSTOMER',@RefId, @SystemStartDate, 'Opening Balance',@Debit, 0, @Amount, @TransactedBy
			 EXEC sp_SaveGL @COAId,'OB-CUSTOMER',@RefId, @SystemStartDate, 'Opening Balance',0, @Debit,  @Amount, @TransactedBy
		 END
	 END
	 ELSE IF(@COACode = 'VENDOR')
	 BEGIN
	 IF(@Credit > 0)
		 BEGIN
		 -- Purchase Debit
		 -- Vendor Credit
		EXEC sp_SaveGL @PurchaseCOAId,'OB-VENDOR',@RefId, @SystemStartDate, 'Opening Balance',@Credit, 0, @Amount, @TransactedBy
			 EXEC sp_SaveGL @COAId,'OB-VENDOR',@RefId, @SystemStartDate, 'Opening Balance',0, @Credit,  @Amount, @TransactedBy
		 END
		 ELSE
		 BEGIN
		 SET @Credit = ABS(@Credit);
		 SET @Amount = ABS(@Amount);
		 -- Vendor Debit
		 -- Cash Credit
		 	 EXEC sp_SaveGL @COAId,'OB-VENDOR',@RefId, @SystemStartDate, 'Opening Balance',@Credit, 0, @Amount, @TransactedBy
			 EXEC sp_SaveGL @CashCOAId,'OB-VENDOR',@RefId, @SystemStartDate, 'Opening Balance',0, @Credit,  @Amount, @TransactedBy
			 
		 END
	 END

END
ELSE
BEGIN
	 IF(@COACode = 'CUSTOMER')
	 BEGIN
		 IF(@Debit > 0)
		 BEGIN
		 	UPDATE tGL
			SET Debit = @Debit ,
			Credit = 0,
			Amount = @Amount
			WHERE RefID = @RefId AND RefType = 'OB-CUSTOMER' AND COAID = @COAId;

			UPDATE tGL
			SET Debit = 0,
			Credit = @Debit,
			Amount = @Amount,
			COAID = @SaleCOAId
			WHERE RefID = @RefId AND RefType = 'OB-CUSTOMER' AND COAID <> @COAId;
		 END
		 ELSE
		 BEGIN
		 SET @Debit = ABS(@Debit);
		 SET @Amount = ABS(@Amount);
			 UPDATE tGL
			SET Debit = @Debit ,
			Credit = 0,
			Amount = @Amount,
			COAID = @CashCOAId
			WHERE RefID = @RefId AND RefType = 'OB-CUSTOMER' AND COAID <> @COAId;

			UPDATE tGL
			SET Debit = 0,
			Credit = @Debit,
			Amount = @Amount
			WHERE RefID = @RefId AND RefType = 'OB-CUSTOMER' AND COAID = @COAId;
		 END
	 END
	 ELSE IF(@COACode = 'VENDOR')
	 BEGIN
	 IF(@Credit > 0)
		 BEGIN
			UPDATE tGL
			SET Debit =@Credit ,
			Credit = 0,
			Amount = @Amount,
			COAID = @PurchaseCOAId
			WHERE RefID = @RefId AND RefType = 'OB-VENDOR' AND COAID <> @COAId;

			UPDATE tGL
			SET Debit = 0,
			Credit = @Credit,
			Amount = @Amount
			WHERE RefID = @RefId AND RefType = 'OB-VENDOR' AND COAID = @COAId;
		 END
		 ELSE
		 BEGIN
		 SET @Credit = ABS(@Credit);
		 SET @Amount = ABS(@Amount);
		 	UPDATE tGL
			SET Debit = @Credit ,
			Credit = 0,
			Amount = @Amount
			WHERE RefID = @RefId AND RefType = 'OB-VENDOR' AND COAID = @COAId;

			UPDATE tGL
			SET Debit = 0,
			Credit = @Credit,
			Amount = @Amount,
			COAID = @CashCOAId
			WHERE RefID = @RefId AND RefType = 'OB-VENDOR' AND COAID  <> @COAId;
			 
		 END
	 END


END



END


GO
/****** Object:  StoredProcedure [dbo].[sp_SaveInventory]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveInventory] @ItemId INT,  @RefId BIGINT, @RefType VARCHAR(2), @Direction INT, @Qty DECIMAL(10,2), @TransactedBy INT
AS
BEGIN

INSERT INTO tItemStock(ItemId,  RefId, RefType, Direction, Qty, CreatedOn, CreatedBy)
VALUES(@ItemId, @RefId, @RefType, @Direction,IIF(@Direction = 2, @Qty * -1, @Qty), GETDATE(),@TransactedBy);


END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveItem]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveItem] @ItemId INT
	,@ItemName VARCHAR(50)
	,@CategoryId INT
	,@CostPrice DECIMAL(10, 2)
	,@SellPrice DECIMAL(10, 2)
	,@TaxTypeId INT
	,@Active BIT
	,@ImagePath VARCHAR(200)
	,@CreatedBy INT
AS
BEGIN
	IF @ItemId = 0
	BEGIN
		IF (
				(
					SELECT COUNT(*)
					FROM tItems
					WHERE ItemName = @ItemName
					) > 0
				)
		BEGIN
			EXEC sp_SendError 'Record Already Exists.';
		END

		INSERT INTO tItems (
			ItemName
			,CategoryId
			,CostPrice
			,SellPrice
			,TaxTypeId
			,ImagePath
			,Active
			,CreatedBy
			,CreatedOn
			)
		VALUES (
			@ItemName
			,@CategoryId
			,@CostPrice
			,@SellPrice
			,@TaxTypeId
			,@ImagePath
			,@Active
			,@CreatedBy
			,GETDATE()
			);
	END
	ELSE
	BEGIN
		IF (
				(
					SELECT COUNT(*)
					FROM tItems
					WHERE ItemName = @ItemName
						AND ItemId <> @ItemId
					) > 0
				)
		BEGIN
			EXEC sp_SendError 'Record Already Exists.';
		END

		UPDATE tItems
		SET ItemName = @ItemName
			,CategoryId = @CategoryId
			,ImagePath = @ImagePath
			,CostPrice = @CostPrice
			,SellPrice = @SellPrice
			,TaxTypeId = @TaxTypeId
			,Active = @Active
		WHERE ItemId = @ItemId;
	END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveJournalVoucher]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveJournalVoucher] @JVId BIGINT, @DebitCOAId BIGINT, @CreditCOAId BIGINT, @Amount DECIMAL(10, 2), @Remarks VARCHAR(300), @JVDate DATETIME, @TransactedBy INT
AS
BEGIN
	IF (@JVId = 0)
	BEGIN
		INSERT INTO tJournalVouchers (JVNumber, DebitCOAId, CreditCOAId, Amount, Remarks, JVDATe, CreatedBy, CreatedOn)
		VALUES (DBO.GetAGNumber('JV'), @DebitCOAId, @CreditCOAId, @Amount, @Remarks, @JVDate, @TransactedBy, GETDATE());

		SELECT @JVId = IDENT_CURRENT('tJournalVouchers');

		EXEC sp_SaveGL @DebitCOAId, 'JV', @JVId, @JVDate, @Remarks, @Amount, 0, @Amount, @TransactedBy;

		EXEC sp_SaveGL @CreditCOAId, 'JV', @JVId, @JVDate, @Remarks, 0, @Amount, @Amount, @TransactedBy;
	END
	ELSE
	BEGIN
		UPDATE tJournalVouchers
		SET DebitCOAId = @DebitCOAId, CreditCOAId = @CreditCOAId, Remarks = @Remarks, JVDate = @JVDate
		WHERE JVId = @JVId;

		DELETE
		FROM tGL
		WHERE RefID = @JVId
			AND RefType = 'JV';

		EXEC sp_SaveGL @DebitCOAId, 'JV', @JVId, @JVDate, @Remarks, @Amount, 0, @Amount, @TransactedBy;

		EXEC sp_SaveGL @CreditCOAId, 'JV', @JVId, @JVDate, @Remarks, 0, @Amount, @Amount, @TransactedBy;
	END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SavePaymentVoucher]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SavePaymentVoucher] @VoucherId BIGINT, @Data DBO.PaymentData READONLY, @TotalAmount DECIMAL(10, 2), @PaidOn DATETIME, @Remarks VARCHAR(300), @TransactedBy INT
AS
BEGIN
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @GLAmount DECIMAL(10, 2);
	DECLARE @VendorId INT;
	DECLARE @Amount DECIMAL(10, 2);

	DECLARE c CURSOR
	FOR
	SELECT VendorId, Amount
	FROM @Data

	SELECT @TotalAmount = SUM(Amount)
	FROM @Data;

	IF @VoucherId = 0
	BEGIN
		INSERT INTO tPaymentVouchers (VoucherNumber, TotalAmount, PaidOn, Remarks, CreatedBy, CreatedOn)
		VALUES (DBO.GetAGNumber('PV'), @TotalAmount, @PaidOn, @Remarks, @TransactedBy, GETDATE());

		SELECT @VoucherId = IDENT_CURRENT('tPaymentVouchers');
	END
	ELSE
	BEGIN
		UPDATE tPaymentVouchers
		SET Remarks = @Remarks, TotalAmount = @TotalAmount, PaidOn = @PaidOn, UpdatedBy = @TransactedBy, UpdatedOn = GETDATE()
		WHERE VoucherId = @VoucherId;

		DELETE
		FROM tPaymentVoucherDetail
		WHERE VoucherId = @VoucherId;

		DELETE
		FROM tGL
		WHERE RefID = @VoucherId
			AND RefType = 'PV';
	END

	INSERT INTO tPaymentVoucherDetail (VoucherId, VendorId, Amount)
	SELECT @VoucherId, VendorId, Amount
	FROM @Data

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @VendorId, @Amount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @DebitCOAId = DBO.GetCOAIdByRefId('VENDOR', @VendorId);
		SET @CreditCOAId = DBO.GetCOAIdByCode('CASH');

		EXEC sp_SaveGL @DebitCOAId, 'PV', @VoucherId, @PaidOn, 'Payment to Vendor', @Amount, 0, @Amount, @TransactedBy;

		EXEC sp_SaveGL @CreditCOAId, 'PV', @VoucherId, @PaidOn, 'Payment to Vendor', 0, @Amount, @Amount, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @VendorId, @Amount;
	END

	CLOSE C;

	DEALLOCATE C;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SavePurchaseInvoice]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SavePurchaseInvoice] @PurchaseInvoiceId BIGINT, @VendorId INT, @AdditionalDiscount DECIMAL(10, 2), @PurchaseInvoiceDate DATETIME, @Remarks VARCHAR(200), @Data DBO.PurchaseInvoiceData READONLY, @TransactedBy INT
AS
BEGIN
	DECLARE @ItemReceiptNumber VARCHAR(50);
	DECLARE @ItemBatchId BIGINT;
	DECLARE @ItemId INT;
	DECLARE @CostPrice DECIMAL(10, 2);
	DECLARE @Qty INT;
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @TaxCOAId BIGINT;
	DECLARE @GLAmount DECIMAL(10, 2);
	DECLARE @TaxAmount DECIMAL(10, 2);
	DECLARE @IRQty BIGINT;
	DECLARE @POQty BIGINT;
	DECLARE @StockQty BIGINT;

	DECLARE c CURSOR
	FOR
	SELECT ItemId, Qty, CostPrice
	FROM @Data

	IF @PurchaseInvoiceId = 0
	BEGIN
		SELECT @ItemReceiptNumber = DBO.GetAGNumber('PI');

		INSERT INTO tPurchaseInvoices (PurchaseInvoiceNumber, VendorId, Remarks, AdditionalDiscount, PurchaseInvoiceDate, CreatedOn, CreatedBy)
		VALUES (DBO.GetAGNumber('PI'), @VendorId, @Remarks, @AdditionalDiscount, @PurchaseInvoiceDate, GETDATE(), @TransactedBy);

		SELECT @PurchaseInvoiceId = IDENT_CURRENT('tPurchaseInvoices');
	END
	ELSE
	BEGIN
		UPDATE tPurchaseInvoices
		SET Remarks = @Remarks, AdditionalDiscount = @AdditionalDiscount, PurchaseInvoiceDate = @PurchaseInvoiceDate, UpdatedBy = @TransactedBy, UpdatedOn = GETDATE()
		WHERE PurchaseInvoiceId = @PurchaseInvoiceId;

		DELETE
		FROM tPurchaseInvoiceDetail
		WHERE PurchaseInvoiceId = @PurchaseInvoiceId;

		DELETE
		FROM tItemStock
		WHERE RefId = @PurchaseInvoiceId
			AND RefType = 'PI';

		DELETE
		FROM tGL
		WHERE RefId = @PurchaseInvoiceId
			AND RefType = 'PI';
	END

	INSERT INTO tPurchaseInvoiceDetail (PurchaseInvoiceId, ItemId, Qty, CostPrice, Tax, Discount, Amount)
	SELECT @PurchaseInvoiceId, ItemId, Qty, CostPrice, Tax, Discount, Amount
	FROM @Data;

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @ItemId, @Qty, @CostPrice

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC sp_SaveInventory @ItemId, @PurchaseInvoiceId, 'PI', 1, @Qty, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @ItemId, @Qty, @CostPrice;
	END

	CLOSE C;

	DEALLOCATE C;

	UPDATE tPurchaseInvoices
	SET TotalAmount = item.Amount - AdditionalDiscount
	FROM tPurchaseInvoices R
	INNER JOIN (
		SELECT SUM(Amount) Amount, PurchaseInvoiceId
		FROM tPurchaseInvoiceDetail
		GROUP BY PurchaseInvoiceId
		) Item ON Item.PurchaseInvoiceId = R.PurchaseInvoiceId
	WHERE R.PurchaseInvoiceId = @PurchaseInvoiceId;

	SET @CreditCOAId = DBO.GetCOAIdByRefId('VENDOR', @VendorId);
	SET @DebitCOAId = DBO.GetCOAIdByCode('PURCHASE');
	SET @TaxCOAId = DBO.GetCOAIdByCode('SALE_TAX_RECEIVABLE');
	SET @GLAmount = (
			SELECT TotalAmount
			FROM tPurchaseInvoices
			WHERE PurchaseInvoiceId = @PurchaseInvoiceId
			);
	SET @TaxAmount = (
			SELECT SUM((Qty * Tax))
			FROM tPurchaseInvoiceDetail
			WHERE PurchaseInvoiceId = @PurchaseInvoiceId
			);

	EXEC sp_SaveGL @CreditCOAId, 'PI', @PurchaseInvoiceId, @PurchaseInvoiceDate, 'Goods Received', 0, @GLAmount, @GLAmount, @TransactedBy;

	IF (@TaxAmount > 0)
	BEGIN
		SET @GLAmount = @GLAmount - @TaxAmount

		EXEC sp_SaveGL @TaxCOAId, 'PI', @PurchaseInvoiceId, @PurchaseInvoiceDate, 'Goods Received', @TaxAmount, 0, @TaxAmount, @TransactedBy;
	END

	EXEC sp_SaveGL @DebitCOAId, 'PI', @PurchaseInvoiceId, @PurchaseInvoiceDate, 'Goods Received', @GLAmount, 0, @GLAmount, @TransactedBy;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SavePurchaseReturn]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SavePurchaseReturn] @PurchaseReturnId BIGINT, @VendorId INT, @Remarks VARCHAR(500), @ReturnDate DATETIME, @Data DBO.PurchaseReturnData READONLY, @TransactedBy INT
AS
BEGIN
	DECLARE @ItemId INT;
	DECLARE @Qty INT;
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @TaxCOAId BIGINT;
	DECLARE @GLAmount DECIMAL(10, 2);
	DECLARE @TaxAmount DECIMAL(10, 2);
	DECLARE @StockQty BIGINT;

	DECLARE c CURSOR
	FOR
	SELECT ItemId, Qty
	FROM @Data

	IF @PurchaseReturnId = 0
	BEGIN
		INSERT INTO tPurchaseReturns (PurchaseReturnNumber, VendorId, Remarks, ReturnDate, CreatedOn, CreatedBy)
		VALUES (DBO.GetAGNumber('PR'), @VendorId, @Remarks, @ReturnDate, GETDATE(), @TransactedBy);

		SELECT @PurchaseReturnId = IDENT_CURRENT('tPurchaseReturns');
	END
	ELSE
	BEGIN
		UPDATE tPurchaseReturns
		SET Remarks = @Remarks, ReturnDate = @ReturnDate, UpdatedBy = @TransactedBy, UpdatedOn = GETDATE()
		WHERE PurchaseReturnId = @PurchaseReturnId;

		DELETE
		FROM tPurchaseReturnDetail
		WHERE PurchaseReturnId = @PurchaseReturnId;

		DELETE
		FROM tItemStock
		WHERE RefId = @PurchaseReturnId
			AND RefType = 'PR';

		DELETE
		FROM tGL
		WHERE RefId = @PurchaseReturnId
			AND RefType = 'PR';
	END

	

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @ItemId, @Qty

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SET @StockQty = ISNULL((
		--			SELECT SUM(Qty)
		--			FROM vPurchaseReturnableItems
		--			WHERE ItemId = @ItemId AND VendorId = @VendorId
		--			), 0);

		--IF (@Qty > @StockQty)
		--BEGIN
		--	EXEC sp_SendError 'Qty Exceeded.';
		--END

		EXEC sp_SaveInventory @ItemId, @PurchaseReturnId, 'PR', 2, @Qty, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @ItemId, @Qty;
	END

	CLOSE C;

	DEALLOCATE C;

	INSERT INTO tPurchaseReturnDetail (PurchaseReturnId, ItemId, Qty, CostPrice, Discount, Tax, Amount)
	SELECT @PurchaseReturnId, ItemId, Qty, CostPrice, Discount, Tax, Amount
	FROM @Data;

	UPDATE tPurchaseReturns
	SET TotalAmount = (
			SELECT SUM(Amount)
			FROM tPurchaseReturnDetail
			WHERE PurchaseReturnId = @PurchaseReturnId
			)
	WHERE PurchaseReturnId = @PurchaseReturnId;

	SET @DebitCOAId = DBO.GetCOAIdByRefId('VENDOR', @VendorId);
	SET @CreditCOAId = DBO.GetCOAIdByCode('PURCHASE_RETURN');
	SET @TaxCOAId = DBO.GetCOAIdByCode('SALE_TAX_RECEIVABLE');
	SET @GLAmount = (
			SELECT TotalAmount
			FROM tPurchaseReturns
			WHERE PurchaseReturnId = @PurchaseReturnId
			);
	SET @TaxAmount = (
			SELECT SUM((Qty * Tax))
			FROM tPurchaseReturnDetail
			WHERE PurchaseReturnId = @PurchaseReturnId
			);

	EXEC sp_SaveGL @DebitCOAId, 'PR', @PurchaseReturnId, @ReturnDate, 'Goods Returned to Vendor', @GLAmount, 0, @GLAmount, @TransactedBy;

	IF (@TaxAmount > 0)
	BEGIN
		SET @GLAmount = @GLAmount - @TaxAmount

		EXEC sp_SaveGL @TaxCOAId, 'PR', @PurchaseReturnId, @ReturnDate, 'Goods Returned to Vendor', 0, @TaxAmount, @TaxAmount, @TransactedBy;
	END

	EXEC sp_SaveGL @CreditCOAId, 'PR', @PurchaseReturnId, @ReturnDate, 'Goods Returned to Vendor', 0, @GLAmount, @GLAmount, @TransactedBy;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveReceiptVoucher]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveReceiptVoucher] @VoucherId BIGINT, @TotalAmount DECIMAL(10, 2), @ReceivedOn DATETIME, @Remarks VARCHAR(300), @TransactedBy INT, @Data DBO.ReceiptData READONLY
AS
BEGIN
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @CustomerId INT;
	DECLARE @Amount DECIMAL(10, 2);

	DECLARE c CURSOR
	FOR
	SELECT CustomerId, Amount
	FROM @Data

	SELECT @TotalAmount = SUM(Amount)
	FROM @Data;

	IF @VoucherId = 0
	BEGIN
		INSERT INTO tReceiptVouchers (VoucherNumber, TotalAmount, ReceivedOn, Remarks, CreatedBy, CreatedOn)
		VALUES (DBO.GetAGNumber('RV'), @TotalAmount, @ReceivedOn, @Remarks, @TransactedBy, GETDATE());

		SELECT @VoucherId = IDENT_CURRENT('tReceiptVouchers');
	END
	ELSE
	BEGIN
		UPDATE tReceiptVouchers
		SET Remarks = @Remarks, ReceivedOn = @ReceivedOn, TotalAmount = @TotalAmount, UpdatedBy = @TransactedBy, UpdatedOn = GETDATE()
		WHERE VoucherId = @VoucherId;

		DELETE
		FROM tGL
		WHERE RefID = @VoucherId
			AND RefType = 'RV';

		DELETE
		FROM tReceiptVoucherDetail
		WHERE VoucherId = @VoucherId;
	END

	INSERT INTO tReceiptVoucherDetail (VoucherId, CustomerId, Amount)
	SELECT @VoucherId, CustomerId, Amount
	FROM @Data

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @CustomerId, @Amount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CreditCOAId = DBO.GetCOAIdByRefId('CUSTOMER', @CustomerId);
		SET @DebitCOAId = DBO.GetCOAIdByCode('CASH');

		EXEC sp_SaveGL @DebitCOAId, 'RV', @VoucherId, @ReceivedOn, 'Payment Received', @Amount, 0, @Amount, @TransactedBy;

		EXEC sp_SaveGL @CreditCOAId, 'RV', @VoucherId, @ReceivedOn, 'Payment Received', 0, @Amount, @Amount, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @CustomerId, @Amount;
	END

	CLOSE C;

	DEALLOCATE C;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveSaleInvoice]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveSaleInvoice] @SaleInvoiceId BIGINT, @CustomerId INT, @Remarks VARCHAR(500), @AdditionalDiscount DECIMAL(10, 2), @SaleInvoiceDate DATETIME, @Data DBO.SaleInvoiceData READONLY, @TransactedBy INT
AS
BEGIN
	DECLARE @ItemId INT;
	DECLARE @Qty INT;
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @TaxCOAId BIGINT;
	DECLARE @GLAmount DECIMAL(10, 2);
	DECLARE @TaxAmount DECIMAL(10, 2);
	DECLARE @DCQty BIGINT;
	DECLARE @SOQty BIGINT;
	DECLARE @StockQty BIGINT;

	DECLARE c CURSOR
	FOR
	SELECT ItemId, Qty
	FROM @Data

	IF @SaleInvoiceId = 0
	BEGIN
		INSERT INTO tSaleInvoices (SaleInvoiceNumber, Remarks, CustomerId, AdditionalDiscount, SaleInvoiceDate, CreatedOn, CreatedBy)
		VALUES (DBO.GetAGNumber('SI'), @Remarks, @CustomerId, @AdditionalDiscount, @SaleInvoiceDate, GETDATE(), @TransactedBy);

		SELECT @SaleInvoiceId = IDENT_CURRENT('tSaleInvoices');
	END
	ELSE
	BEGIN
		UPDATE tSaleInvoices
		SET Remarks = @Remarks, SaleInvoiceDate = @SaleInvoiceDate, AdditionalDiscount = @AdditionalDiscount, UpdatedBy = @TransactedBy, UpdatedOn = GETDATE()
		WHERE SaleInvoiceId = @SaleInvoiceId;

		DELETE
		FROM tSaleInvoiceDetail
		WHERE SaleInvoiceId = @SaleInvoiceId;

		DELETE
		FROM tGL
		WHERE RefID = @SaleInvoiceId
			AND RefType = 'SI';
	END

	INSERT INTO tSaleInvoiceDetail (SaleInvoiceId, ItemId, Qty, SellPrice, Tax, Discount, Amount)
	SELECT @SaleInvoiceId, ItemId, Qty, SellPrice, Tax, Discount, Amount
	FROM @Data

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @ItemId, @Qty

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @StockQty = ISNULL((
					SELECT SUM(Qty)
					FROM vItemStock
					WHERE ItemId = @ItemId
					), 0);

		EXEC sp_SaveInventory @ItemId, @SaleInvoiceId, 'SI', 2, @Qty, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @ItemId, @Qty;
	END

	CLOSE C;

	DEALLOCATE C;

	UPDATE tSaleInvoices
	SET TotalAmount = item.Amount - AdditionalDiscount
	FROM tSaleInvoices R
	INNER JOIN (
		SELECT SUM(Amount) Amount, SaleInvoiceId
		FROM tSaleInvoiceDetail
		GROUP BY SaleInvoiceId
		) Item ON Item.SaleInvoiceId = R.SaleInvoiceId
	WHERE R.SaleInvoiceId = @SaleInvoiceId;

	SET @DebitCOAId = DBO.GetCOAIdByRefId('CUSTOMER', @CustomerId);
	SET @CreditCOAId = DBO.GetCOAIdByCode('SALE');
	SET @TaxCOAId = DBO.GetCOAIdByCode('SALE_TAX_PAYABLE');
	SET @GLAmount = (
			SELECT TotalAmount
			FROM tSaleInvoices
			WHERE SaleInvoiceId = @SaleInvoiceId
			);
	SET @TaxAmount = (
			SELECT SUM((Qty * Tax))
			FROM tSaleInvoiceDetail
			WHERE SaleInvoiceId = @SaleInvoiceId
			);

	EXEC sp_SaveGL @DebitCOAId, 'SI', @SaleInvoiceId, @SaleInvoiceDate, 'Goods Sold', @GLAmount, 0, @GLAmount, @TransactedBy;

	IF (@TaxAmount > 0)
	BEGIN
		SET @GLAmount = @GLAmount - @TaxAmount

		EXEC sp_SaveGL @TaxCOAId, 'SI', @SaleInvoiceId, @SaleInvoiceDate, 'Goods Sold', 0, @TaxAmount, @TaxAmount, @TransactedBy;
	END

	EXEC sp_SaveGL @CreditCOAId, 'SI', @SaleInvoiceId, @SaleInvoiceDate, 'Goods Sold', 0, @GLAmount, @GLAmount, @TransactedBy;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveSaleReturn]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveSaleReturn] @SaleReturnId BIGINT, @CustomerId INT, @Remarks VARCHAR(50), @ReturnDate DATETIME, @Data DBO.SaleReturnData READONLY, @TransactedBy INT
AS
BEGIN
	DECLARE @ItemId INT;
	DECLARE @Qty INT;
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @TaxCOAId BIGINT;
	DECLARE @GLAmount DECIMAL(10, 2);
	DECLARE @TaxAmount DECIMAL(10, 2);
	DECLARE @StockQty BIGINT;

	DECLARE c CURSOR
	FOR
	SELECT ItemId, Qty
	FROM @Data

	IF @SaleReturnId = 0
	BEGIN
		INSERT INTO tSaleReturns (SaleReturnNumber, CustomerId, Remarks, ReturnDate, CreatedOn, CreatedBy)
		VALUES (DBO.GetAGNumber('SR'), @CustomerId, @Remarks, @ReturnDate, GETDATE(), @TransactedBy);

		SELECT @SaleReturnId = IDENT_CURRENT('tSaleReturns');
	END
	ELSE
	BEGIN
		UPDATE tSaleReturns
		SET Remarks = @Remarks, ReturnDate = @ReturnDate, UpdatedBy = @TransactedBy, UpdatedOn = GETDATE()
		WHERE SaleReturnId = @SaleReturnId;

		DELETE
		FROM tSaleReturnDetail
		WHERE SaleReturnId = @SaleReturnId;

		DELETE
		FROM tGL
		WHERE RefID = @SaleReturnId
			AND RefType = 'SR';

		DELETE
		FROM tItemStock
		WHERE RefID = @SaleReturnId
			AND RefType = 'SR';
	END

	

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @ItemId, @Qty

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @StockQty = ISNULL((
					SELECT SUM(Qty)
					FROM vSaleReturnableItems
					WHERE ItemId = @ItemId
						AND CustomerId = @CustomerId
					), 0);

		--IF (@Qty > @StockQty)
		--BEGIN
		--	EXEC sp_SendError 'Qty Exceeded.';
		--END

		EXEC sp_SaveInventory @ItemId, @SaleReturnId, 'SR', 1, @Qty, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @ItemId, @Qty;
	END

	CLOSE C;

	DEALLOCATE C;

	INSERT INTO tSaleReturnDetail (SaleReturnId, ItemId, Qty, SellPrice, Tax, Discount, Amount)
	SELECT @SaleReturnId, ItemId, Qty, SellPrice, Tax, Discount, Amount
	FROM @Data

	UPDATE tSaleReturns
	SET TotalAmount = (
			SELECT SUM(Amount)
			FROM tSaleReturnDetail
			WHERE SaleReturnId = @SaleReturnId
			)
	WHERE SaleReturnId = @SaleReturnId;

	SET @CreditCOAId = DBO.GetCOAIdByRefId('CUSTOMER', @CustomerId);
	SET @DebitCOAId = DBO.GetCOAIdByCode('SALE_RETURN');
	SET @TaxCOAId = DBO.GetCOAIdByCode('SALE_TAX_PAYABLE');
	SET @TaxAmount = (
			SELECT SUM((Qty * Tax))
			FROM tSaleReturnDetail
			WHERE SaleReturnId = @SaleReturnId
			);
	SET @GLAmount = (
			SELECT TotalAmount
			FROM tSaleReturns
			WHERE SaleReturnId = @SaleReturnId
			);

	EXEC sp_SaveGL @CreditCOAId, 'SR', @SaleReturnId, @ReturnDate, 'Goods Returned from Customer', 0, @GLAmount, @GLAmount, @TransactedBy;

	IF (@TaxAmount > 0)
	BEGIN
		SET @GLAmount = @GLAmount - @TaxAmount

		EXEC sp_SaveGL @TaxCOAId, 'SR', @SaleReturnId, @ReturnDate, 'Goods Returned from Customer', @TaxAmount, 0, @TaxAmount, @TransactedBy;
	END

	EXEC sp_SaveGL @DebitCOAId, 'SR', @SaleReturnId, @ReturnDate, 'Goods Returned from Customer', @GLAmount, 0, @GLAmount, @TransactedBy;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveShipmentCharges]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SaveShipmentCharges] @SCId BIGINT, @SCDate DATETIME, @Remarks VARCHAR(300), @TransactedBy INT, @Data DBO.ShipmentCharges READONLY
AS
BEGIN
	DECLARE @DebitCOAId BIGINT;
	DECLARE @CreditCOAId BIGINT;
	DECLARE @TotalAmount DECIMAL(10, 2);
	DECLARE @CustomerId INT;
	DECLARE @CarrierId INT;
	DECLARE @Amount DECIMAL(10, 2);

	DECLARE c CURSOR
	FOR
	SELECT CustomerId, Amount, CarrierId
	FROM @Data

	SELECT @TotalAmount = SUM(Amount)
	FROM @Data;

	IF @SCId = 0
	BEGIN
		INSERT INTO tShipmentCharges (SCNumber, TotalAmount, SCDate, Remarks, CreatedBy, CreatedOn)
		VALUES (DBO.GetAGNumber('SC'), @TotalAmount, @SCDate, @Remarks, @TransactedBy, GETDATE());

		SELECT @SCId = IDENT_CURRENT('tShipmentCharges');
	END
	ELSE
	BEGIN
		UPDATE tShipmentCharges
		SET Remarks = @Remarks, SCDate = @SCDate, TotalAmount = @TotalAmount, UpdatedOn = GETDATE(), UpdatedBy = @TransactedBy
		WHERE SCId = @SCId;

		DELETE
		FROM tGL
		WHERE RefID = @SCId
			AND RefType = 'SC';

		DELETE
		FROM tShipmentChargesDetail
		WHERE SCId = @SCId;
	END

	INSERT INTO tShipmentChargesDetail (SCId, CustomerId, CarrierId, Amount)
	SELECT @SCId, CustomerId, CarrierId, Amount
	FROM @Data;

	OPEN C;

	FETCH NEXT
	FROM C
	INTO @CustomerId, @Amount, @CarrierId

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Carrier Expense DEBIT
		-- Cash Credit
		-- Custome Debit
		-- Carrier Credit
		SET @DebitCOAId = DBO.GetCOAIdByRefId('CARRIER', @CarrierId);
		SET @CreditCOAId = DBO.GetCOAIdByCode('CASH');

		EXEC sp_SaveGL @DebitCOAId, 'SC', @SCId, @SCDate, 'Carrier Expense', @Amount, 0, @Amount, @TransactedBy;

		EXEC sp_SaveGL @CreditCOAId, 'SC', @SCId, @SCDate, 'Carrier Expense', 0, @Amount, @Amount, @TransactedBy;

		SET @DebitCOAId = DBO.GetCOAIdByRefId('CUSTOMER', @CustomerId);
		SET @CreditCOAId = DBO.GetCOAIdByRefId('CARRIER', @CarrierId);

		EXEC sp_SaveGL @DebitCOAId, 'SC', @SCId, @SCDate, 'Carrier Expense', @Amount, 0, @Amount, @TransactedBy;

		EXEC sp_SaveGL @CreditCOAId, 'SC', @SCId, @SCDate, 'Carrier Expense', 0, @Amount, @Amount, @TransactedBy;

		FETCH NEXT
		FROM C
		INTO @CustomerId, @Amount, @CarrierId;
	END

	CLOSE C;

	DEALLOCATE C;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveTaxType]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveTaxType]
@TaxTypeId INT,
@TaxTypeName VARCHAR(50),
@TaxPercentage DECIMAL(5,2),
@TransactedBy INT
AS

BEGIN
IF @TaxTypeId = 0
BEGIN
	INSERT INTO tTaxTypes(TaxTypeName, TaxPercentage)
	VALUES(@TaxTypeName, @TaxPercentage);
	END
	ELSE
	BEGIN
	UPDATE tTaxTypes
	SET TaxTypeName = @TaxTypeName,
	
	TaxPercentage = @TaxPercentage
	WHERE TaxTypeId = @TaxTypeId;
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveVendor]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SaveVendor]
@VendorId INT,
@BillingName VARCHAR(50),
@BillingAddress1 VARCHAR(100),
@BillingAddress2 VARCHAR(100),
@PhoneNo VARCHAR(100),
@TelNo VARCHAR(100),
@NTNNo varchar(50),
@STRNo varchar(50),
@Active BIT,
@TransactedBy INT
AS

BEGIN
DECLARE @COAId BIGINT;
IF @VendorId = 0
BEGIN
IF((SELECT COUNT(*) FROM tVendors WHERE BillingName  = @BillingName) > 0)
	BEGIN
		EXEC sp_SendError 'Record Already Exists.';
	END
	INSERT INTO tVendors(BillingName, BillingAddress1, BillingAddress2, PhoneNo, TelNo, NTNNo, STRNo,  Active, CreatedBy, CreatedOn)
	VALUES(@BillingName, @BillingAddress1, @BillingAddress2, @PhoneNo, @TelNo, @NTNNo, @STRNo,  @Active, @TransactedBy, GETDATE());


	SELECT @VendorId = IDENT_CURRENT('tVendors');
	EXEC sp_SaveExternalCOA @VendorId, 'VENDOR', @BillingName, @COAId, @TransactedBy; 

	END
	ELSE
	BEGIn
	IF((SELECT COUNT(*) FROM tVendors WHERE BillingName  = @BillingName AND VendorId <> @VendorId) > 0)
	BEGIN
		EXEC sp_SendError 'Record Already Exists.';
	END
	UPDATE tVendors
	SET BillingName = @BillingName,
	BillingAddress1 = @BillingAddress1,
	BillingAddress2 = @BillingAddress2,
	PhoneNo = @PhoneNo,
	TelNo = @TelNo,
	NTNNo = @NTNNo,
	STRNo = @STRNo,

	Active = @Active,
	UpdatedBy = @TransactedBy,
	UpdatedOn  = GETDATE()
	WHERE VendorId = @VendorId;
	EXEC sp_SaveExternalCOA @VendorId, 'VENDOR', @BillingName, @COAId, @TransactedBy; 
END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SendError]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SendError] @ErrorMessage TEXT
AS 
BEGIN




THROW 50001,@ErrorMessage,1
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ValidateUser]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_ValidateUser] @UserName VARCHAR(15), @UserPassword VARCHAR(10)
AS

BEGIN
DECLARE @tmpUserCount INT;
SELECT @tmpUserCount =  COUNT(*)  FROM tUsers WHERE UserName = @UserName AND UserPwd = @UserPassword;

IF @tmpUserCount = 0
BEGIN
EXEC sp_SendError  'User not found in the System.';
END

SELECT UserId FROM tUsers  WHERE UserName = @UserName AND UserPwd = @UserPassword;

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetActiveFiscalYearFromDate]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetActiveFiscalYearFromDate]
(
	-- Add the parameters for the function here
)
RETURNS DATE
AS
BEGIN
DECLARE @Date DATE;
IF((SELECT COUNT(*) FROM tFiscalYears WHERE Active = 1) > 0)
BEGIN
SELECT  @Date =  CAST(FromDate as Date) FROM tFiscalYears WHERE Active = 1;
	
END
ELSE
BEGIN
SELECT @Date =  CAST(CONVERT(VARCHAR,'2001-01-01',105) as DATE);

END
RETURN @Date;


END

GO
/****** Object:  UserDefinedFunction [dbo].[GetActiveFiscalYearToDate]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetActiveFiscalYearToDate]
(
	-- Add the parameters for the function here
)
RETURNS DATE
AS
BEGIN

DECLARE @Date DATE;
IF((SELECT COUNT(*) FROM tFiscalYears WHERE Active = 1) > 0)
BEGIN
SELECT  @Date =  CAST(ToDate as Date) FROM tFiscalYears WHERE Active = 1;
	
END
ELSE
BEGIN
SELECT @Date =  CAST(CONVERT(VARCHAR,'2030-12-31',105) as DATE);

END
RETURN @Date;



END

GO
/****** Object:  UserDefinedFunction [dbo].[GetAGNumber]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetAGNumber] (
	-- Add the parameters for the function here
	@TYPE VARCHAR(3)
	)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @AGNumber VARCHAR(50);

	-- Declare the return variable here
	IF (@TYPE = 'PI')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(PurchaseInvoiceId), 0) + 1), 8))
		FROM tPurchaseInvoices;
	END
	ELSE IF (@TYPE = 'PR')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(PurchaseReturnId), 0) + 1), 8))
		FROM tPurchaseReturns;
	END
	ELSE IF (@TYPE = 'PV')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(VoucherId), 0) + 1), 8))
		FROM tPaymentVouchers;
	END
	ELSE IF (@TYPE = 'SI')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(SaleInvoiceId), 0) + 1), 8))
		FROM tSaleInvoices;
	END
	ELSE IF (@TYPE = 'SR')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(SaleReturnId), 0) + 1), 8))
		FROM tSaleReturns;
	END
	ELSE IF (@TYPE = 'RV')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(VoucherId), 0) + 1), 8))
		FROM tReceiptVouchers;
	END
	ELSE IF (@TYPE = 'BI')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(RecordId), 0) + 1), 8))
		FROM tBadInventories;
	END
	ELSE IF (@TYPE = 'JV')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(JVId), 0) + 1), 8))
		FROM tJournalVouchers;
	END
	ELSE IF (@TYPE = 'SC')
	BEGIN
		SELECT @AGNumber = CONCAT (@TYPE, RIGHT(CONCAT ('00000000', ISNULL(MAX(SCId), 0) + 1), 8))
		FROM tShipmentCharges;
	END

	RETURN @AGNumber;
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetCategoryHeirarchy]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM tCategories;
CREATE FUNCTION [dbo].[GetCategoryHeirarchy]
(
	@CategoryId INT
)
RETURNS VARCHAR(MAX)
as
BEGIN
DECLARE @text as VARCHAR(MAX);
;WITH C
(
Id,
ParentId,
Name,
Name1
)
as
(
SELECT CategoryId, ParentId, CategoryName, CAST(CategoryName as NVARCHAR(MAX)) as Name1 FROM tCategories WHERE CategoryId = @CategoryId
UNION ALL
SELECT CategoryId, A.ParentId, CategoryName, CAST(A.CategoryName + ':' + C.Name1 as NVARCHAR(MAX)) FROM tCategories  A
INNER JOIN C ON C.ParentId =A.CategoryId  

) SELECT @text = Name1 FROM C WHERE ParentId = 0;

RETURN @text;
END


GO
/****** Object:  UserDefinedFunction [dbo].[GetCOAIdByCode]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetCOAIdByCode]
(
	-- Add the parameters for the function here
	@Code VARCHAR(20)
)
RETURNS BIGINT
AS
BEGIN
return (	SELECT COAID FROM tCOA WHERE COACOde = @Code);

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetCOAIdByRefId]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetCOAIdByRefId]
(
	-- Add the parameters for the function here
	@COACode VARCHAR(10),
	@RefId BIGINT
)
RETURNS BIGINT
AS
BEGIN
return (SELECT COAID FROM tCOA WHERE RefID = @RefId AND COACode = @COACode);

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetCOATypeValue]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetCOATypeValue]
(
	-- Add the parameters for the function here
	@COAId BIGINT
)
RETURNS VARCHAR(10)
AS
BEGIN
return (SELECT WhenIncrease FROM tCOA COA
INNER JOIN tCOATypes T ON T.COATYpeId  = COA.COATypeId
WHERE COA.COAID = @COAId
);

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetRefNumberByRefId]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetRefNumberByRefId]
(
	-- Add the parameters for the function here
	@RefType VARCHAR(2),
	@RefId BIGINT
)
RETURNS VARCHAR(50)
AS
BEGIN
DECLARE @RefNumber VARCHAR(50);
 IF(@RefType = 'PI')
	BEGIN
	SELECT @RefNumber = PurchaseInvoiceNumber FROM tPurchaseInvoices WHERE PurchaseInvoiceId = @RefId;
	END
	ELSE IF(@RefType = 'PR')
	BEGIN
	SELECT @RefNumber =  PurchaseReturnNumber FROM tPurchaseReturns WHERE PurchaseReturnId= @RefId;
	END

	ELSE IF(@RefType = 'SI')
	BEGIN
	SELECT @RefNumber =   SaleInvoiceNumber FROM tSaleInvoices WHERE SaleInvoiceId = @RefId;
	END
	ELSE IF(@RefType = 'SR')
	BEGIN
	SELECT @RefNumber = SaleReturnNumber FROM tSaleReturns WHERE SaleReturnId= @RefId;
	END
	ELSE IF(@RefType = 'BI')
	BEGIN
	SELECT @RefNumber = BadInventoryNumber FROM tBadInventories WHERE  RecordId= @RefId;
	END
    ELSE IF(@RefType = 'JV')
	BEGIN
	SELECT @RefNumber =   JVNumber FROM tJournalVouchers WHERE JVId = @RefId;
	END
	ELSE IF(@RefType = 'SC')
	BEGIN
	SELECT @RefNumber =   SCNumber FROM tShipmentCharges WHERE SCId = @RefId;
	END
	ELSE IF(@RefType = 'PV')
	BEGIN
	SELECT @RefNumber =   VoucherNumber FROM tPaymentVouchers WHERE VoucherId = @RefId;
	END
	ELSE IF(@RefType = 'RV')
	BEGIN
	SELECT @RefNumber =   VoucherNumber FROM tReceiptVouchers WHERE VoucherId = @RefId;
	END
	RETURN @RefNumber;


END

GO
/****** Object:  UserDefinedFunction [dbo].[GetSysIniValue]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetSysIniValue]
(
	-- Add the parameters for the function here
	@SysCode VARCHAR(20)
)
RETURNS VARCHAR(50)
AS
BEGIN
return (SELECT SysValue FROM tSysIni WHERE SysCode = @SysCode);

END

GO
/****** Object:  Table [dbo].[tBadInventories]    Script Date: 08/01/2021 11:43:13 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tBadInventories](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[BadInventoryNumber] [varchar](50) NULL,
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[Remarks] [varchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tBadInventories] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tCarriers]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tCarriers](
	[CarrierId] [int] IDENTITY(1,1) NOT NULL,
	[CarrierName] [varchar](50) NULL,
	[Active] [bit] NOT NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tCarriers] PRIMARY KEY CLUSTERED 
(
	[CarrierId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tCategories]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tCategories](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [int] NULL,
	[CategoryName] [varchar](50) NULL,
	[Active] [bit] NOT NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tCategories] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tCOA]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tCOA](
	[COAID] [int] IDENTITY(1,1) NOT NULL,
	[RefID] [int] NULL,
	[COAName] [varchar](50) NULL,
	[COACode] [varchar](20) NULL,
	[COATypeId] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tCOA] PRIMARY KEY CLUSTERED 
(
	[COAID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tCOATypes]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tCOATypes](
	[COATypeId] [int] NOT NULL,
	[COAType] [varchar](50) NULL,
	[WhenIncrease] [varchar](10) NULL,
	[WhenDecrease] [varchar](10) NULL,
 CONSTRAINT [PK_tCOATypes] PRIMARY KEY CLUSTERED 
(
	[COATypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tCompanyInfo]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tCompanyInfo](
	[CompanyName] [varchar](50) NULL,
	[AddressLine1] [varchar](50) NULL,
	[AddressLine2] [varchar](50) NULL,
	[TelNo] [varchar](50) NULL,
	[ContactPerson] [varchar](50) NULL,
	[NTNNo] [varchar](50) NULL,
	[STRNo] [varchar](50) NULL,
	[LogoPath] [varchar](100) NULL,
	[InvoiceFooterRemarks] [nvarchar](500) NULL,
	[ShortDesc] [varchar](500) NULL,
	[Email] [varchar](50) NULL,
	[Slogan] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tCustomers]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tCustomers](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[BillingName] [varchar](50) NULL,
	[BillingAddress1] [varchar](300) NULL,
	[BillingAddress2] [varchar](300) NULL,
	[ShippingName] [varchar](50) NULL,
	[ShippingAddress1] [varchar](300) NULL,
	[ShippingAddress2] [varchar](300) NULL,
	[TelNo] [varchar](50) NULL,
	[PhoneNo] [varchar](50) NULL,
	[NTNNo] [varchar](50) NULL,
	[STRNo] [varchar](50) NULL,
	[Active] [bit] NOT NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tCustomers] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tFiscalYears]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tFiscalYears](
	[FiscalYearId] [int] IDENTITY(1,1) NOT NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_tFiscalYears] PRIMARY KEY CLUSTERED 
(
	[FiscalYearId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tGL]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tGL](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[COAID] [int] NULL,
	[RefType] [varchar](50) NULL,
	[RefID] [bigint] NULL,
	[TransactionDate] [datetime] NULL,
	[Remarks] [varchar](500) NULL,
	[Debit] [decimal](10, 2) NULL,
	[Credit] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
 CONSTRAINT [PK_tGL] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tItems]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tItems](
	[ItemId] [bigint] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NULL,
	[ItemName] [varchar](50) NULL,
	[CostPrice] [decimal](10, 2) NULL,
	[SellPrice] [decimal](10, 2) NULL,
	[TaxTypeId] [int] NULL,
	[ImagePath] [varchar](200) NULL,
	[Active] [bit] NOT NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tItems] PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tItemStock]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tItemStock](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NULL,
	[RefId] [bigint] NULL,
	[RefType] [varchar](50) NULL,
	[Direction] [int] NULL,
	[Qty] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
 CONSTRAINT [PK_tItemStock] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tJournalVouchers]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tJournalVouchers](
	[JVId] [bigint] IDENTITY(1,1) NOT NULL,
	[JVNumber] [varchar](50) NULL,
	[DebitCOAId] [bigint] NULL,
	[CreditCOAId] [bigint] NULL,
	[Amount] [decimal](18, 0) NULL,
	[Remarks] [varchar](300) NULL,
	[JVDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
 CONSTRAINT [PK_tJournalVouchers] PRIMARY KEY CLUSTERED 
(
	[JVId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tMenuGroups]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tMenuGroups](
	[MenuGroupId] [int] NOT NULL,
	[ParentId] [int] NULL,
	[MenuGroupName] [varchar](50) NULL,
 CONSTRAINT [PK_tMenuGroups] PRIMARY KEY CLUSTERED 
(
	[MenuGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tMenus]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tMenus](
	[MenuId] [int] NOT NULL,
	[ParentId] [int] NOT NULL,
	[MenuGroupId] [int] NULL,
	[MenuName] [varchar](25) NOT NULL,
	[MenuGrp] [varchar](10) NULL,
	[MenuPath] [varchar](30) NULL,
	[MenuOrder] [int] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_tMenus] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tPaymentVoucherDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPaymentVoucherDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[VoucherId] [bigint] NULL,
	[VendorId] [int] NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tPaymentVoucherDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tPaymentVouchers]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tPaymentVouchers](
	[VoucherId] [bigint] IDENTITY(1,1) NOT NULL,
	[VoucherNumber] [varchar](50) NULL,
	[TotalAmount] [decimal](10, 0) NULL,
	[PaidOn] [datetime] NULL,
	[Remarks] [varchar](300) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tPaymentVouchers] PRIMARY KEY CLUSTERED 
(
	[VoucherId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tPurchaseInvoiceDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPurchaseInvoiceDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[PurchaseInvoiceId] [bigint] NULL,
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[CostPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tItemReceiptDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tPurchaseInvoices]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tPurchaseInvoices](
	[PurchaseInvoiceId] [bigint] IDENTITY(1,1) NOT NULL,
	[PurchaseInvoiceNumber] [varchar](50) NULL,
	[VendorId] [int] NULL,
	[PurchaseInvoiceDate] [datetime] NULL,
	[Remarks] [varchar](200) NULL,
	[AdditionalDiscount] [decimal](10, 2) NULL,
	[TotalAmount] [decimal](10, 2) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tItemReceipts] PRIMARY KEY CLUSTERED 
(
	[PurchaseInvoiceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tPurchaseReturnDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPurchaseReturnDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[PurchaseReturnId] [bigint] NULL,
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[CostPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tPurchaseReturnDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tPurchaseReturns]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tPurchaseReturns](
	[PurchaseReturnId] [bigint] IDENTITY(1,1) NOT NULL,
	[PurchaseReturnNumber] [varchar](50) NULL,
	[VendorId] [int] NULL,
	[Remarks] [varchar](500) NULL,
	[ReturnDate] [datetime] NULL,
	[TotalAmount] [decimal](10, 2) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tPurchaseReturns] PRIMARY KEY CLUSTERED 
(
	[PurchaseReturnId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tReceiptVoucherDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tReceiptVoucherDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[VoucherId] [bigint] NULL,
	[CustomerId] [int] NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tReceiptVoucherDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tReceiptVouchers]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tReceiptVouchers](
	[VoucherId] [bigint] IDENTITY(1,1) NOT NULL,
	[VoucherNumber] [varchar](50) NULL,
	[TotalAmount] [decimal](10, 0) NULL,
	[ReceivedOn] [datetime] NULL,
	[Remarks] [varchar](300) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tReceiptVouchers] PRIMARY KEY CLUSTERED 
(
	[VoucherId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tSaleInvoiceDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tSaleInvoiceDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[SaleInvoiceId] [bigint] NULL,
	[ItemId] [int] NULL,
	[Qty] [int] NULL,
	[SellPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tDeliveryChallanDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tSaleInvoices]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tSaleInvoices](
	[SaleInvoiceId] [bigint] IDENTITY(1,1) NOT NULL,
	[SaleInvoiceNumber] [varchar](50) NULL,
	[CustomerId] [int] NULL,
	[SaleInvoiceDate] [datetime] NULL,
	[Remarks] [varchar](500) NULL,
	[TotalAmount] [decimal](10, 2) NULL,
	[AdditionalDiscount] [decimal](10, 2) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tDeliveryChallans] PRIMARY KEY CLUSTERED 
(
	[SaleInvoiceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tSaleReturnDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tSaleReturnDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[SaleReturnId] [bigint] NULL,
	[ItemId] [int] NULL,
	[Qty] [int] NOT NULL,
	[SellPrice] [decimal](10, 2) NULL,
	[Tax] [decimal](10, 2) NULL,
	[Discount] [decimal](10, 2) NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tSalesReturnDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tSaleReturns]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tSaleReturns](
	[SaleReturnId] [bigint] IDENTITY(1,1) NOT NULL,
	[SaleReturnNumber] [varchar](50) NULL,
	[CustomerId] [int] NULL,
	[Remarks] [varchar](500) NULL,
	[ReturnDate] [datetime] NULL,
	[TotalAmount] [decimal](10, 2) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tSalesReturns] PRIMARY KEY CLUSTERED 
(
	[SaleReturnId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tShipmentCharges]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tShipmentCharges](
	[SCId] [bigint] IDENTITY(1,1) NOT NULL,
	[SCNumber] [varchar](50) NULL,
	[TotalAmount] [decimal](10, 2) NULL,
	[SCDate] [datetime] NULL,
	[Remarks] [varchar](500) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tShipmentCharges] PRIMARY KEY CLUSTERED 
(
	[SCId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tShipmentChargesDetail]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tShipmentChargesDetail](
	[RecordId] [bigint] IDENTITY(1,1) NOT NULL,
	[SCId] [bigint] NULL,
	[CustomerId] [int] NULL,
	[CarrierId] [int] NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tShipmentChargesDetail] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tSysIni]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tSysIni](
	[SysCode] [varchar](20) NOT NULL,
	[SysValue] [varchar](50) NULL,
 CONSTRAINT [PK_tSysIni] PRIMARY KEY CLUSTERED 
(
	[SysCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tTaxTypes]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tTaxTypes](
	[TaxTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TaxTypeName] [varchar](20) NULL,
	[TaxPercentage] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tTaxTypes] PRIMARY KEY CLUSTERED 
(
	[TaxTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tUsers]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tUsers](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](15) NOT NULL,
	[UserPwd] [varchar](10) NULL,
	[Active] [bit] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_tUsers] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tVendors]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tVendors](
	[VendorId] [int] IDENTITY(1,1) NOT NULL,
	[BillingName] [varchar](50) NULL,
	[BillingAddress1] [varchar](300) NULL,
	[BillingAddress2] [varchar](300) NULL,
	[TelNo] [varchar](50) NULL,
	[PhoneNo] [varchar](50) NULL,
	[NTNNo] [varchar](50) NULL,
	[STRNo] [varchar](50) NULL,
	[Active] [bit] NOT NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_tVendors] PRIMARY KEY CLUSTERED 
(
	[VendorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vItemStock]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vItemStock]
AS
SELECT        ItemId, SUM(Qty) AS Qty
FROM            dbo.tItemStock AS S
GROUP BY ItemId
HAVING        (SUM(Qty) > 0)

GO
/****** Object:  View [dbo].[vPurchaseReturnableItems]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPurchaseReturnableItems]
AS
SELECT        VendorId, ItemId, SUM(Qty) AS Qty
FROM            (SELECT        IR.VendorId, IRD.ItemId, CASE WHEN SUM(S.Qty) < SUM(IRD.Qty) THEN SUM(S.Qty) ELSE SUM(IRD.Qty) END AS Qty
                          FROM            dbo.tPurchaseInvoices AS IR INNER JOIN
                                                    dbo.tPurchaseInvoiceDetail AS IRD ON IR.PurchaseInvoiceId = IRD.PurchaseInvoiceId INNER JOIN
                                                    dbo.vItemStock AS S ON S.ItemId = IRD.ItemId
                          GROUP BY IR.VendorId, IRD.ItemId, S.ItemId
                          UNION ALL
                          SELECT        IR.VendorId, IRD.ItemId, SUM(IRD.Qty) * - 1 AS Qty
                          FROM            dbo.tPurchaseReturns AS IR INNER JOIN
                                                   dbo.tPurchaseReturnDetail AS IRD ON IR.PurchaseReturnId = IRD.PurchaseReturnId
                          GROUP BY IR.VendorId, IRD.ItemId) AS dt
GROUP BY ItemId, VendorId
HAVING        (SUM(Qty) > 0)

GO
/****** Object:  View [dbo].[vItemAvgCostPrice]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vItemAvgCostPrice]
AS
SELECT        ItemId, SUM(Amount) / SUM(Qty) AS AvgCostPrice
FROM            (SELECT        ItemId, Qty, Qty * (CostPrice - Discount) AS Amount
                          FROM            dbo.tPurchaseInvoiceDetail AS IRD
                          UNION ALL
                          SELECT        ItemId, Qty * - 1 AS Qty, Qty * CostPrice * - 1 AS Amount
                          FROM            dbo.tPurchaseReturnDetail AS PRD) AS D
GROUP BY ItemId
HAVING        (SUM(Qty) > 0)

GO
/****** Object:  View [dbo].[vSaleReturnableItems]    Script Date: 08/01/2021 11:43:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSaleReturnableItems]
AS
SELECT        CustomerId, ItemId, SUM(Qty) AS Qty
FROM            (SELECT        IR.CustomerId, IRD.ItemId, SUM(IRD.Qty) AS Qty
                          FROM            dbo.tSaleInvoices AS IR INNER JOIN
                                                    dbo.tSaleInvoiceDetail AS IRD ON IR.SaleInvoiceId = IRD.SaleInvoiceId
                          GROUP BY IR.CustomerId, IRD.ItemId
                          UNION ALL
                          SELECT        IR.CustomerId, IRD.ItemId, SUM(IRD.Qty) * - 1 AS Qty
                          FROM            dbo.tSaleReturns AS IR INNER JOIN
                                                   dbo.tSaleReturnDetail AS IRD ON IR.SaleReturnId = IRD.SaleReturnId
                          GROUP BY IR.CustomerId, IRD.ItemId) AS dt
GROUP BY ItemId, CustomerId
HAVING        (SUM(Qty) > 0)

GO
SET IDENTITY_INSERT [dbo].[tBadInventories] ON 

GO
INSERT [dbo].[tBadInventories] ([RecordId], [BadInventoryNumber], [ItemId], [Qty], [Remarks], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'BI00000001', 1, 12, N'aa', CAST(N'2020-12-02 23:20:16.533' AS DateTime), 1, CAST(N'2020-12-02 23:25:57.263' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tBadInventories] OFF
GO
SET IDENTITY_INSERT [dbo].[tCategories] ON 

GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, 0, N'Apple', 1, CAST(N'2020-12-01 00:28:39.640' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, 1, N'Mobiles', 1, CAST(N'2020-12-01 00:28:45.113' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (3, 0, N'Samsung', 1, CAST(N'2020-12-01 00:29:08.613' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (4, 3, N'Mobiles', 1, CAST(N'2020-12-01 00:29:16.553' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (5, 0, N'Mobile', 1, CAST(N'2020-12-02 23:39:43.513' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (6, 1, N'aa', 0, CAST(N'2020-12-02 23:52:31.937' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (7, 1, N'ddd', 0, CAST(N'2020-12-03 00:09:10.117' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (8, 1, N'dd', 0, CAST(N'2020-12-03 00:10:08.420' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (9, 1, N'44', 0, CAST(N'2020-12-03 00:10:40.723' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (10, 1, N'afaf', 1, CAST(N'2020-12-03 00:10:52.610' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (11, 0, N'cc', 0, CAST(N'2020-12-03 00:11:15.690' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCategories] ([CategoryId], [ParentId], [CategoryName], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (12, 1, N'aa', 1, CAST(N'2020-12-03 00:28:25.677' AS DateTime), NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[tCOA] ON 

GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, 0, N'Purchases', N'PURCHASE', 4, CAST(N'2020-09-24 00:00:00.000' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, 0, N'Purchase Returns', N'PURCHASE_RETURN', 4, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (3, 0, N'Sales', N'SALE', 3, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (4, 0, N'Sales Returns', N'SALE_RETURN', 3, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (5, 0, N'Sales Tax Payable', N'SALE_TAX_PAYABLE', 2, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (6, 0, N'CASH', N'CASH', 1, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (7, 0, N'BANK', N'BANK', 1, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (8, 0, N'General Expense', N'GENERAL_EXPENSE', 4, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (9, 0, N'Sales Tax Receivable', N'SALE_TAX_RECEIVABLE', 1, CAST(N'2020-09-24 00:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (18, 1, N'Salman', N'VENDOR', NULL, CAST(N'2020-12-01 00:31:18.957' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tCOA] ([COAID], [RefID], [COAName], [COACode], [COATypeId], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (19, 1, N'Salman', N'CUSTOMER', NULL, CAST(N'2020-12-01 00:31:35.840' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tCOA] OFF
GO
INSERT [dbo].[tCOATypes] ([COATypeId], [COAType], [WhenIncrease], [WhenDecrease]) VALUES (1, N'ASSET', N'DEBIT', N'CREDIT')
GO
INSERT [dbo].[tCOATypes] ([COATypeId], [COAType], [WhenIncrease], [WhenDecrease]) VALUES (2, N'LIABILITY', N'CREDIT', N'DEBIT')
GO
INSERT [dbo].[tCOATypes] ([COATypeId], [COAType], [WhenIncrease], [WhenDecrease]) VALUES (3, N'INCOME', N'CREDIT', N'DEBIT')
GO
INSERT [dbo].[tCOATypes] ([COATypeId], [COAType], [WhenIncrease], [WhenDecrease]) VALUES (4, N'EXPENSE', N'DEBIT', N'CREDIT')
GO
INSERT [dbo].[tCOATypes] ([COATypeId], [COAType], [WhenIncrease], [WhenDecrease]) VALUES (5, N'CAPITAL', N'CREDIT', N'DEBIT')
GO
INSERT [dbo].[tCompanyInfo] ([CompanyName], [AddressLine1], [AddressLine2], [TelNo], [ContactPerson], [NTNNo], [STRNo], [LogoPath], [InvoiceFooterRemarks], [ShortDesc], [Email], [Slogan]) VALUES (N'Ahmed Enterprises', N'5th, 106, Star City Mall', N'Saddar, Karachi Pakistan', N'021-34588777', N'a', N'a', N'a', N'Images\Company\Logo.jpg', N'ایک بار فروخت شدہ سامان واپس نہیں کیا جاسکتا', N'Deals in all kind of mobile accessories', N'ahmed@ahmed.com', N'We will fuck YOU OFF')
GO
SET IDENTITY_INSERT [dbo].[tCustomers] ON 

GO
INSERT [dbo].[tCustomers] ([CustomerId], [BillingName], [BillingAddress1], [BillingAddress2], [ShippingName], [ShippingAddress1], [ShippingAddress2], [TelNo], [PhoneNo], [NTNNo], [STRNo], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'Salman', N'salman', N'', N'salman', N'', N'', N'', N'', N'', N'', 1, CAST(N'2020-12-01 00:31:35.840' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tCustomers] OFF
GO
SET IDENTITY_INSERT [dbo].[tFiscalYears] ON 

GO
INSERT [dbo].[tFiscalYears] ([FiscalYearId], [FromDate], [ToDate], [Active]) VALUES (1, CAST(N'2020-11-01 23:10:30.000' AS DateTime), CAST(N'2020-12-01 23:10:30.000' AS DateTime), 0)
GO
SET IDENTITY_INSERT [dbo].[tFiscalYears] OFF
GO
SET IDENTITY_INSERT [dbo].[tGL] ON 

GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (21, 18, N'PV', 1, CAST(N'2020-12-03 00:43:40.123' AS DateTime), N'Payment to Vendor', CAST(6.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(6.00 AS Decimal(10, 2)), CAST(N'2020-12-03 23:16:28.540' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (22, 6, N'PV', 1, CAST(N'2020-12-03 00:43:40.123' AS DateTime), N'Payment to Vendor', CAST(0.00 AS Decimal(10, 2)), CAST(6.00 AS Decimal(10, 2)), CAST(6.00 AS Decimal(10, 2)), CAST(N'2020-12-03 23:16:28.540' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (29, 19, N'SI', 1, CAST(N'2020-12-03 23:21:17.860' AS DateTime), N'Goods Sold', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-03 23:21:33.770' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (30, 3, N'SI', 1, CAST(N'2020-12-03 23:21:17.860' AS DateTime), N'Goods Sold', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-03 23:21:33.770' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (45, 18, N'PR', 1, CAST(N'2020-12-03 00:59:53.627' AS DateTime), N'Goods Returned to Vendor', CAST(204.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(204.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:06:41.553' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (46, 2, N'PR', 1, CAST(N'2020-12-03 00:59:53.627' AS DateTime), N'Goods Returned to Vendor', CAST(0.00 AS Decimal(10, 2)), CAST(204.00 AS Decimal(10, 2)), CAST(204.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:06:41.553' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (47, 18, N'PI', 3, CAST(N'2020-12-03 23:19:32.047' AS DateTime), N'Goods Received', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:09:50.570' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (48, 1, N'PI', 3, CAST(N'2020-12-03 23:19:32.047' AS DateTime), N'Goods Received', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:09:50.573' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (49, 18, N'PI', 1, CAST(N'2020-12-02 00:31:47.000' AS DateTime), N'Goods Received', CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:09:58.823' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (50, 1, N'PI', 1, CAST(N'2020-12-02 00:31:47.000' AS DateTime), N'Goods Received', CAST(12.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:09:58.823' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (51, 18, N'PI', 2, CAST(N'2020-12-01 23:23:42.777' AS DateTime), N'Goods Received', CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:10:04.687' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (52, 1, N'PI', 2, CAST(N'2020-12-01 23:23:42.777' AS DateTime), N'Goods Received', CAST(12.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:10:04.687' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (53, 19, N'SR', 1, CAST(N'2020-12-04 00:13:39.710' AS DateTime), N'Goods Returned from Customer', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:13:55.697' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (54, 4, N'SR', 1, CAST(N'2020-12-04 00:13:39.710' AS DateTime), N'Goods Returned from Customer', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:13:55.697' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (57, 6, N'RV', 1, CAST(N'2018-12-31 00:18:22.000' AS DateTime), N'Payment Received', CAST(6000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(6000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:25:09.590' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (58, 19, N'RV', 1, CAST(N'2018-12-31 00:18:22.000' AS DateTime), N'Payment Received', CAST(0.00 AS Decimal(10, 2)), CAST(6000.00 AS Decimal(10, 2)), CAST(6000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:25:09.590' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (59, 18, N'PI', 4, CAST(N'2020-12-04 00:29:48.857' AS DateTime), N'Goods Received', CAST(0.00 AS Decimal(10, 2)), CAST(325000.00 AS Decimal(10, 2)), CAST(325000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:04.427' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (60, 1, N'PI', 4, CAST(N'2020-12-04 00:29:48.857' AS DateTime), N'Goods Received', CAST(325000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(325000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:04.427' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (61, 19, N'SI', 2, CAST(N'2020-12-04 00:30:09.230' AS DateTime), N'Goods Sold', CAST(200000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(200000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:35.463' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (62, 3, N'SI', 2, CAST(N'2020-12-04 00:30:09.230' AS DateTime), N'Goods Sold', CAST(0.00 AS Decimal(10, 2)), CAST(200000.00 AS Decimal(10, 2)), CAST(200000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:35.463' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (65, 18, N'PR', 2, CAST(N'2020-12-04 00:30:42.647' AS DateTime), N'Goods Returned to Vendor', CAST(32500.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(32500.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:31:05.817' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (66, 2, N'PR', 2, CAST(N'2020-12-04 00:30:42.647' AS DateTime), N'Goods Returned to Vendor', CAST(0.00 AS Decimal(10, 2)), CAST(32500.00 AS Decimal(10, 2)), CAST(32500.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:31:05.817' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (67, 19, N'SR', 2, CAST(N'2020-12-04 00:32:14.470' AS DateTime), N'Goods Returned from Customer', CAST(0.00 AS Decimal(10, 2)), CAST(75000.00 AS Decimal(10, 2)), CAST(75000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:32:34.193' AS DateTime), 1)
GO
INSERT [dbo].[tGL] ([RecordId], [COAID], [RefType], [RefID], [TransactionDate], [Remarks], [Debit], [Credit], [Amount], [CreatedOn], [CreatedBy]) VALUES (68, 4, N'SR', 2, CAST(N'2020-12-04 00:32:14.470' AS DateTime), N'Goods Returned from Customer', CAST(75000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(75000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:32:34.193' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tGL] OFF
GO
SET IDENTITY_INSERT [dbo].[tItems] ON 

GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, 2, N'Iphone X', CAST(12.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), 0, N'Images\Items\Iphone X.jpg', 1, CAST(N'2020-12-01 00:30:04.417' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, 4, N'S3', CAST(12.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), 0, N'Images\Items\S3.jpg', 1, CAST(N'2020-12-01 00:30:18.617' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (3, 1, N'affa', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\affa.jpg', 1, CAST(N'2020-12-02 23:42:09.437' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (4, 1, N'dd', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\dd.jpg', 1, CAST(N'2020-12-03 00:16:46.967' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (5, 1, N'ff', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\ff.jpg', 1, CAST(N'2020-12-03 00:33:39.583' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (6, 1, N'55', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\55.jpg', 1, CAST(N'2020-12-03 00:34:01.273' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (7, 1, N'66', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\66.jpg', 1, CAST(N'2020-12-03 00:34:44.950' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (8, 1, N'ww', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\ww.jpg', 1, CAST(N'2020-12-03 00:35:18.080' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (9, 1, N'4', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\4.jpg', 1, CAST(N'2020-12-03 00:37:06.443' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tItems] ([ItemId], [CategoryId], [ItemName], [CostPrice], [SellPrice], [TaxTypeId], [ImagePath], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (10, 1, N'33', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'Images\Items\33.jpg', 1, CAST(N'2020-12-03 00:42:04.560' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tItems] OFF
GO
SET IDENTITY_INSERT [dbo].[tItemStock] ON 

GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (6, 1, 1, N'BI', 2, -12, CAST(N'2020-12-02 23:25:57.263' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (12, 10, 1, N'SI', 2, -1000, CAST(N'2020-12-03 23:21:33.760' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (20, 1, 1, N'PR', 2, -17, CAST(N'2020-12-04 00:06:41.553' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (21, 10, 3, N'PI', 1, 1, CAST(N'2020-12-04 00:09:50.567' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (22, 1, 1, N'PI', 1, 1, CAST(N'2020-12-04 00:09:58.823' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (23, 1, 2, N'PI', 1, 1, CAST(N'2020-12-04 00:10:04.680' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (24, 10, 1, N'SR', 1, 1100, CAST(N'2020-12-04 00:13:55.690' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (25, 8, 4, N'PI', 1, 5000, CAST(N'2020-12-04 00:30:04.420' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (26, 8, 2, N'SI', 2, -4000, CAST(N'2020-12-04 00:30:35.463' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (28, 8, 2, N'PR', 2, -500, CAST(N'2020-12-04 00:31:05.810' AS DateTime), 1)
GO
INSERT [dbo].[tItemStock] ([RecordId], [ItemId], [RefId], [RefType], [Direction], [Qty], [CreatedOn], [CreatedBy]) VALUES (29, 8, 2, N'SR', 1, 3000, CAST(N'2020-12-04 00:32:34.187' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tItemStock] OFF
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (1, 1, N'Configuration')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (2, 13, N'Customers')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (3, 1, N'Employees')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (4, 7, N'Entry')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (5, 4, N'Entry')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (6, 20, N'Inventory')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (7, 7, N'Vendors')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (9, 13, N'Entry')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (10, NULL, N'Window')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (11, 4, N'Listing')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (12, 13, N'Listing')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (13, 7, N'Listing')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (14, 20, N'Purchase')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (15, 20, N'Sale')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (16, 1, N'Start Up')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (17, 1, N'Accounts')
GO
INSERT [dbo].[tMenuGroups] ([MenuGroupId], [ParentId], [MenuGroupName]) VALUES (18, 20, N'General Ledger')
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (1, 0, NULL, N'Company', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (2, 1, 1, N'Company Information', N'CONFIG', N'fConfigurations', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (4, 0, NULL, N'Inventory', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (5, 4, 5, N'Items', N'Items', N'fItems', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (6, 4, 11, N'Item Stock', N'Items', N'fItemStock', 3, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (7, 0, NULL, N'Purchase', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (8, 7, 7, N'Vendors', N'Vendors', N'fVendors', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (10, 7, 4, N'Purchase Invoice', N'Entry', N'fPurchaseInvoice', 4, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (11, 7, 4, N'Purchase Return', N'Entry', N'fPurchaseReturns', 5, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (12, 7, 7, N'Vendor Payments', N'Vendors', N'fPayments', 2, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (13, 0, NULL, N'Sale', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (14, 13, 2, N'Customers', N'Customers', N'fCustomers', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (16, 13, 9, N'Sale Invoice', N'Entry', N'fSaleInvoice', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (18, 13, 9, N'Sales Return', N'Entry', N'fSaleReturns', 2, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (19, 13, 2, N'Customer Receipts', N'Customers', N'fReceipts', 3, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (20, 0, NULL, N'Reports', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (21, 20, 6, N'Item Ledger', N'REPORTS', N'fItemLedgerReport', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (22, 20, 14, N'Vendor Ledger', N'REPORTS', N'fVendorLedgerReport', 2, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (23, 20, 15, N'Customer Ledger', N'REPORTS', N'fCustomerLedgerReport', 3, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (24, 0, NULL, N'Window', NULL, N'fSaleReturns', NULL, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (25, 24, 10, N'Log Out', N'WINDOW', N'fLogin', 3, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (33, 1, 1, N'Tax Types', N'CONFIG', N'fTaxTypes', 3, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (35, 1, 16, N'Customer OB', NULL, N'fCustomerOB', 5, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (36, 1, 16, N'Vendor OB', NULL, N'fVendorOB', 4, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (38, 4, 5, N'Bad Inventory', NULL, N'fBadInventories', 2, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (39, 1, 1, N'Fiscal Years', NULL, N'fFiscalYears', 2, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (46, 24, 10, N'About', N'WINDOW', N'fAbout', 2, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (47, 1, 17, N'Journal Voucher', NULL, N'fJournalVouchers', 6, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (48, 20, 18, N'General Ledger', NULL, N'fGeneralLedgerReport', 4, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (49, 24, 10, N'Backup Data', NULL, N'fBackupDB', 1, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (50, 4, 5, N'Categories', NULL, N'fCategories', 0, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (51, 1, 1, N'Carriers', NULL, N'fCarriers', 4, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (52, 13, 9, N'Shipment Charges', NULL, N'fShipmentCharges', 3, 1)
GO
INSERT [dbo].[tMenus] ([MenuId], [ParentId], [MenuGroupId], [MenuName], [MenuGrp], [MenuPath], [MenuOrder], [Active]) VALUES (53, 20, 6, N'Item Listing', NULL, N'fItemReport', 0, 1)
GO
SET IDENTITY_INSERT [dbo].[tPaymentVoucherDetail] ON 

GO
INSERT [dbo].[tPaymentVoucherDetail] ([RecordId], [VoucherId], [VendorId], [Amount]) VALUES (5, 1, 1, CAST(6.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[tPaymentVoucherDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[tPaymentVouchers] ON 

GO
INSERT [dbo].[tPaymentVouchers] ([VoucherId], [VoucherNumber], [TotalAmount], [PaidOn], [Remarks], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'PV00000001', CAST(6 AS Decimal(10, 0)), CAST(N'2020-12-03 00:43:40.123' AS DateTime), N'ww', CAST(N'2020-12-03 00:43:54.100' AS DateTime), 1, CAST(N'2020-12-03 23:16:28.530' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tPaymentVouchers] OFF
GO
SET IDENTITY_INSERT [dbo].[tPurchaseInvoiceDetail] ON 

GO
INSERT [dbo].[tPurchaseInvoiceDetail] ([RecordId], [PurchaseInvoiceId], [ItemId], [Qty], [CostPrice], [Tax], [Discount], [Amount]) VALUES (10, 3, 10, 1, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[tPurchaseInvoiceDetail] ([RecordId], [PurchaseInvoiceId], [ItemId], [Qty], [CostPrice], [Tax], [Discount], [Amount]) VALUES (11, 1, 1, 1, CAST(12.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[tPurchaseInvoiceDetail] ([RecordId], [PurchaseInvoiceId], [ItemId], [Qty], [CostPrice], [Tax], [Discount], [Amount]) VALUES (12, 2, 1, 1, CAST(12.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[tPurchaseInvoiceDetail] ([RecordId], [PurchaseInvoiceId], [ItemId], [Qty], [CostPrice], [Tax], [Discount], [Amount]) VALUES (13, 4, 8, 5000, CAST(65.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(325000.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[tPurchaseInvoiceDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[tPurchaseInvoices] ON 

GO
INSERT [dbo].[tPurchaseInvoices] ([PurchaseInvoiceId], [PurchaseInvoiceNumber], [VendorId], [PurchaseInvoiceDate], [Remarks], [AdditionalDiscount], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'PI00000001', 1, CAST(N'2020-12-02 00:31:47.000' AS DateTime), N'test', CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(N'2020-12-01 00:32:00.873' AS DateTime), 1, CAST(N'2020-12-04 00:09:58.823' AS DateTime), 1)
GO
INSERT [dbo].[tPurchaseInvoices] ([PurchaseInvoiceId], [PurchaseInvoiceNumber], [VendorId], [PurchaseInvoiceDate], [Remarks], [AdditionalDiscount], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, N'PI00000002', 1, CAST(N'2020-12-01 23:23:42.777' AS DateTime), N'', CAST(0.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(N'2020-12-01 23:24:01.203' AS DateTime), 1, CAST(N'2020-12-04 00:10:04.677' AS DateTime), 1)
GO
INSERT [dbo].[tPurchaseInvoices] ([PurchaseInvoiceId], [PurchaseInvoiceNumber], [VendorId], [PurchaseInvoiceDate], [Remarks], [AdditionalDiscount], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (3, N'PI00000003', 1, CAST(N'2020-12-03 23:19:32.047' AS DateTime), N'', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-03 23:19:44.980' AS DateTime), 1, CAST(N'2020-12-04 00:09:50.563' AS DateTime), 1)
GO
INSERT [dbo].[tPurchaseInvoices] ([PurchaseInvoiceId], [PurchaseInvoiceNumber], [VendorId], [PurchaseInvoiceDate], [Remarks], [AdditionalDiscount], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (4, N'PI00000004', 1, CAST(N'2020-12-04 00:29:48.857' AS DateTime), N'', CAST(0.00 AS Decimal(10, 2)), CAST(325000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:04.420' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tPurchaseInvoices] OFF
GO
SET IDENTITY_INSERT [dbo].[tPurchaseReturnDetail] ON 

GO
INSERT [dbo].[tPurchaseReturnDetail] ([RecordId], [PurchaseReturnId], [ItemId], [Qty], [CostPrice], [Tax], [Discount], [Amount]) VALUES (12, 1, 1, 17, CAST(12.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(204.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[tPurchaseReturnDetail] ([RecordId], [PurchaseReturnId], [ItemId], [Qty], [CostPrice], [Tax], [Discount], [Amount]) VALUES (14, 2, 8, 500, CAST(65.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(32500.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[tPurchaseReturnDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[tPurchaseReturns] ON 

GO
INSERT [dbo].[tPurchaseReturns] ([PurchaseReturnId], [PurchaseReturnNumber], [VendorId], [Remarks], [ReturnDate], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'PR00000001', 1, N'', CAST(N'2020-12-03 00:59:53.627' AS DateTime), CAST(204.00 AS Decimal(10, 2)), CAST(N'2020-12-03 01:00:03.350' AS DateTime), 1, CAST(N'2020-12-04 00:06:41.553' AS DateTime), 1)
GO
INSERT [dbo].[tPurchaseReturns] ([PurchaseReturnId], [PurchaseReturnNumber], [VendorId], [Remarks], [ReturnDate], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, N'PR00000002', 1, N'', CAST(N'2020-12-04 00:30:42.647' AS DateTime), CAST(32500.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:55.503' AS DateTime), 1, CAST(N'2020-12-04 00:31:05.810' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tPurchaseReturns] OFF
GO
SET IDENTITY_INSERT [dbo].[tReceiptVoucherDetail] ON 

GO
INSERT [dbo].[tReceiptVoucherDetail] ([RecordId], [VoucherId], [CustomerId], [Amount]) VALUES (2, 1, 1, CAST(6000.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[tReceiptVoucherDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[tReceiptVouchers] ON 

GO
INSERT [dbo].[tReceiptVouchers] ([VoucherId], [VoucherNumber], [TotalAmount], [ReceivedOn], [Remarks], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'RV00000001', CAST(6000 AS Decimal(10, 0)), CAST(N'2018-12-31 00:18:22.000' AS DateTime), N'', CAST(N'2020-12-04 00:18:32.803' AS DateTime), 1, CAST(N'2020-12-04 00:25:09.577' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tReceiptVouchers] OFF
GO
SET IDENTITY_INSERT [dbo].[tSaleInvoiceDetail] ON 

GO
INSERT [dbo].[tSaleInvoiceDetail] ([RecordId], [SaleInvoiceId], [ItemId], [Qty], [SellPrice], [Tax], [Discount], [Amount]) VALUES (1, 1, 10, 1000, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[tSaleInvoiceDetail] ([RecordId], [SaleInvoiceId], [ItemId], [Qty], [SellPrice], [Tax], [Discount], [Amount]) VALUES (2, 2, 8, 4000, CAST(50.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(200000.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[tSaleInvoiceDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[tSaleInvoices] ON 

GO
INSERT [dbo].[tSaleInvoices] ([SaleInvoiceId], [SaleInvoiceNumber], [CustomerId], [SaleInvoiceDate], [Remarks], [TotalAmount], [AdditionalDiscount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'SI00000001', 1, CAST(N'2020-12-03 23:21:17.860' AS DateTime), N'', CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-03 23:21:33.653' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tSaleInvoices] ([SaleInvoiceId], [SaleInvoiceNumber], [CustomerId], [SaleInvoiceDate], [Remarks], [TotalAmount], [AdditionalDiscount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, N'SI00000002', 1, CAST(N'2020-12-04 00:30:09.230' AS DateTime), N'', CAST(200000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:30:35.460' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tSaleInvoices] OFF
GO
SET IDENTITY_INSERT [dbo].[tSaleReturnDetail] ON 

GO
INSERT [dbo].[tSaleReturnDetail] ([RecordId], [SaleReturnId], [ItemId], [Qty], [SellPrice], [Tax], [Discount], [Amount]) VALUES (1, 1, 10, 1100, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[tSaleReturnDetail] ([RecordId], [SaleReturnId], [ItemId], [Qty], [SellPrice], [Tax], [Discount], [Amount]) VALUES (2, 2, 8, 3000, CAST(25.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(75000.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[tSaleReturnDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[tSaleReturns] ON 

GO
INSERT [dbo].[tSaleReturns] ([SaleReturnId], [SaleReturnNumber], [CustomerId], [Remarks], [ReturnDate], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'SR00000001', 1, N'', CAST(N'2020-12-04 00:13:39.710' AS DateTime), CAST(0.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:13:55.657' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tSaleReturns] ([SaleReturnId], [SaleReturnNumber], [CustomerId], [Remarks], [ReturnDate], [TotalAmount], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (2, N'SR00000002', 1, N'', CAST(N'2020-12-04 00:32:14.470' AS DateTime), CAST(75000.00 AS Decimal(10, 2)), CAST(N'2020-12-04 00:32:34.173' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tSaleReturns] OFF
GO
INSERT [dbo].[tSysIni] ([SysCode], [SysValue]) VALUES (N'BAK_PATH', N'D:\')
GO
INSERT [dbo].[tSysIni] ([SysCode], [SysValue]) VALUES (N'SYS_START_DATE', N'2001-01-01')
GO
SET IDENTITY_INSERT [dbo].[tUsers] ON 

GO
INSERT [dbo].[tUsers] ([UserId], [UserName], [UserPwd], [Active], [CreatedBy], [CreatedOn]) VALUES (1, N'madni', N'00000', 1, 1, CAST(N'2020-09-13 00:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tUsers] OFF
GO
SET IDENTITY_INSERT [dbo].[tVendors] ON 

GO
INSERT [dbo].[tVendors] ([VendorId], [BillingName], [BillingAddress1], [BillingAddress2], [TelNo], [PhoneNo], [NTNNo], [STRNo], [Active], [CreatedOn], [CreatedBy], [UpdatedOn], [UpdatedBy]) VALUES (1, N'Salman', N'salman', N'salman', N'', N'', N'', N'', 1, CAST(N'2020-12-01 00:31:18.953' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tVendors] OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[7] 4[5] 2[74] 3) )"
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
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 224
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
      Begin ColumnWidths = 12
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vItemAvgCostPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vItemAvgCostPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 224
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
      Begin ColumnWidths = 12
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vItemStock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vItemStock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[34] 2[45] 3) )"
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
         Begin Table = "dt"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 224
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
      Begin ColumnWidths = 12
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vPurchaseReturnableItems'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vPurchaseReturnableItems'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "dt"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 224
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
      Begin ColumnWidths = 12
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSaleReturnableItems'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSaleReturnableItems'
GO
