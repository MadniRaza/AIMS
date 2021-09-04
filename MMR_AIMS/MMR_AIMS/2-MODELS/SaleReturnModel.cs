using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class SaleReturnModel
    {
        public struct SaleReturn
        {
            public long SaleReturnId { get; set; }
            public int CustomerId { get; set; }
            public string Remarks { get; set; }
            public DateTime ReturnDate { get; set; }
            public DataTable Items { get; set; }
        }
   
        public object Save(SaleReturn _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                DataTable dt = _model.Items.DefaultView.ToTable(false, "ItemId", "Qty", "SellPrice","Tax", "Discount", "Amount");
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("SaleReturnId",_model.SaleReturnId),
                new SqlParam("CustomerId",_model.CustomerId),
                new SqlParam("ReturnDate",_model.ReturnDate),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("Data",dt,SqlDbType.Structured),
                new SqlParam("TransactedBy",AppData.UserId),
            };

                result = oDAL.Request(new SqlQuery("sp_SaveSaleReturn", true, _params), DAL.QueryExecutionTypes.Data);
                oDAL.Commit();
            }
            catch (Exception)
            {
                oDAL.Rollback();
                throw;
            }
            return result;
        }

        public object GetById(long Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("SaleReturnId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetSaleReturn", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetSaleReturnList", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetSaleReturnableItems(long Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CustomerId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetSaleReturnableItems", true, _params), DAL.QueryExecutionTypes.Data);
        }
    }
}
