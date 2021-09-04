using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class PaymentVoucherModel
    {
        public struct PaymentVoucher
        {
            public long VoucherId { get; set; }
            public DateTime PaidOn { get; set; }
            public decimal TotalAmount { get; set; }
            public string Remarks { get; set; }
            public DataTable Items { get; set; }
        }

        public object Save(PaymentVoucher _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                DataTable dt = _model.Items.DefaultView.ToTable(false, "VendorId", "Amount");
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VoucherId",_model.VoucherId),
                new SqlParam("PaidOn",_model.PaidOn),
                new SqlParam("TotalAmount",_model.TotalAmount),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("Data",dt,SqlDbType.Structured),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SavePaymentVoucher", true, _params), DAL.QueryExecutionTypes.Data);
                oDAL.Commit();
                return result;
            }
            catch (Exception ex)
            {
                oDAL.Rollback();
                throw ex;
            }
        }

        public object GetById(long Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VoucherId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetPaymentVoucher", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetPaymentVoucherList", true), DAL.QueryExecutionTypes.Data);
        }
        
    }
}
