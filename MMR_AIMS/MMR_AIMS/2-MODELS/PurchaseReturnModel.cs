using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class PurchaseReturnModel
    {
        public struct PurchaseReturn
        {
            public long PurchaseReturnId { get; set; }
            public int VendorId { get; set; }
            public string Remarks { get; set; }
            public DateTime ReturnDate { get; set; }
            public DataTable Items { get; set; }
        }
       
        public object Save(PurchaseReturn _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {

                DataTable dt = _model.Items.DefaultView.ToTable(false, "ItemId", "Qty", "Tax", "CostPrice", "Discount", "Amount");
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("PurchaseReturnId",_model.PurchaseReturnId),
                new SqlParam("VendorId",_model.VendorId),
                new SqlParam("ReturnDate",_model.ReturnDate),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("Data",dt,SqlDbType.Structured),
                new SqlParam("TransactedBy",AppData.UserId),
            };

                result= oDAL.Request(new SqlQuery("sp_SavePurchaseReturn", true, _params), DAL.QueryExecutionTypes.Data);
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
                new SqlParam("PurchaseReturnId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetPurchaseReturn", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetPurchaseReturnList", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetPurchaseReturnableItems(long Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VendorId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetPurchaseReturnableItems", true, _params), DAL.QueryExecutionTypes.Data);
        }
    }
}
