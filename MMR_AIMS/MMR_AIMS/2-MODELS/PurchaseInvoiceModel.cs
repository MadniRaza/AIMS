using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class PurchaseInvoiceModel
    {
        public struct PurchaseInvoice
        {
            public long PurchaseInvoiceId { get; set; }
            public int VendorId { get; set; }
            public string Remarks { get; set; }
            public decimal AdditionalDiscount { get; set; }
            public DateTime PurchaseInvoiceDate { get; set; }
            public DataTable Items { get; set; }
        }
       
        public object Save(PurchaseInvoice _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {

                DataTable dt = _model.Items.DefaultView.ToTable(false, "ItemId", "Qty", "CostPrice", "Tax", "Discount","Amount");
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("PurchaseInvoiceId",_model.PurchaseInvoiceId),
                new SqlParam("VendorId",_model.VendorId),
                new SqlParam("PurchaseInvoiceDate",_model.PurchaseInvoiceDate),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("AdditionalDiscount",_model.AdditionalDiscount),
                new SqlParam("Data",dt,SqlDbType.Structured),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SavePurchaseInvoice", true, _params), DAL.QueryExecutionTypes.Data);
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
                new SqlParam("PurchaseInvoiceId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetPurchaseInvoice", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetPurchaseInvoiceList", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
