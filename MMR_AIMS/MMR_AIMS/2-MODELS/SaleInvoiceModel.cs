using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class SaleInvoiceModel
    {
        public struct SaleInvoice
        {
            public long SaleInvoiceId { get; set; }
            public int CustomerId { get; set; }
            public decimal AdditionalDiscount { get; set; }
            public string Remarks { get; set; }
            public DateTime SaleInvoiceDate { get; set; }
            public DataTable Items { get; set; }
        }
    
        public object Save(SaleInvoice _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {

                DataTable dt = _model.Items.DefaultView.ToTable(false, "ItemId", "Qty", "SellPrice","Tax","Discount",  "Amount");
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("SaleInvoiceId",_model.SaleInvoiceId),
                new SqlParam("CustomerId",_model.CustomerId),
                new SqlParam("SaleInvoiceDate",_model.SaleInvoiceDate),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("AdditionalDiscount",_model.AdditionalDiscount),
                new SqlParam("Data",dt,SqlDbType.Structured),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SaveSaleInvoice", true, _params), DAL.QueryExecutionTypes.Data);
                oDAL.Commit();
            }
            catch (Exception ex)
            {
                oDAL.Rollback();
                throw ex;
            }
            return result;
        }

        public object GetById(long Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("SaleInvoiceId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetSaleInvoice", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetSaleInvoiceList", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
