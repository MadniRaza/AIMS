using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class ItemModel
    {
        public struct Item
        {
            public int ItemId { get; set; }
            public int CategoryId { get; set; }
            public string ItemName { get; set; }
            public string ImagePath { get; set; }
            public decimal CostPrice { get; set; }
            public decimal SellPrice { get; set; }
            public decimal TaxTypeId { get; set; }
            public bool Active { get; set; }
        }
       

        public object Save(Item _model)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("ItemId",_model.ItemId),
                new SqlParam("ItemName",_model.ItemName),
                new SqlParam("CategoryId",_model.CategoryId),
                new SqlParam("ImagePath",_model.ImagePath),
                new SqlParam("CostPrice",_model.CostPrice),
                new SqlParam("SellPrice",_model.SellPrice),
                new SqlParam("TaxTypeId",_model.TaxTypeId),
                new SqlParam("Active",_model.Active),
                new SqlParam("CreatedBy",AppData.UserId),
            };

            return oDAL.Request(new SqlQuery("sp_SaveItem", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object Get(int Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("ItemId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetItem", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetItemList", true), DAL.QueryExecutionTypes.Data);
        }
      
        public object GetItems()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetItems", true), DAL.QueryExecutionTypes.Data);
        }
       
      
        public object GetItemAvgCostPriceList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetItemAvgCostPriceList", true), DAL.QueryExecutionTypes.Data);
        }

        public object GetItemStockList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetItemStockList", true), DAL.QueryExecutionTypes.Data);
        }
       
        public object GetItemLedger(int ItemId, DateTime FromDate, DateTime ToDate)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("ItemId",ItemId),
                new SqlParam("FromDate",FromDate),
                new SqlParam("ToDate",ToDate),
            };
            return oDAL.Request(new SqlQuery("sp_GetItemLedger", true,_params), DAL.QueryExecutionTypes.Data);
        }
        public object GetStockItems()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetStockItems", true), DAL.QueryExecutionTypes.Data);
        }

        public object GetItemReport(long CategoryId)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CategoryId",CategoryId)
            };
            return oDAL.Request(new SqlQuery("sp_GetItemReport", true,_params), DAL.QueryExecutionTypes.Data);
        }

    }
}
