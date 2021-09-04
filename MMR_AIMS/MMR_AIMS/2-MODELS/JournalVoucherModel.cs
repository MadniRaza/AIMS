using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class JournalVoucherModel
    {
        public struct JournalVoucher
        {
            public long JVId { get; set; }
            public long DebitCOAId { get; set; }
            public long CreditCOAId { get; set; }
            public DateTime JVDate { get; set; }
            public decimal Amount { get; set; }
            public string Remarks { get; set; }
        }

        public object Save(JournalVoucher _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("JVId",_model.JVId),
                new SqlParam("DebitCOAId",_model.DebitCOAId),
                new SqlParam("CreditCOAId",_model.CreditCOAId),
                new SqlParam("Amount",_model.Amount),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("JVDate",_model.JVDate),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SaveJournalVoucher", true, _params), DAL.QueryExecutionTypes.Data);
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
                new SqlParam("JVId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetJournalVoucher", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetJournalVoucherList", true), DAL.QueryExecutionTypes.Data);
        }
        
    }
}
