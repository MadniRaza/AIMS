using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class OBModel
    {
        public struct OB
        {
            public long RefId { get; set; }
            public long COAId { get; set; }
            public string COACode { get; set; }
            public decimal Debit { get; set; }
            public decimal Credit { get; set; }
            public decimal Amount { get; set; }
        }
        public object Save(OB _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("COAId",_model.COAId),
                new SqlParam("COACode",_model.COACode),
                new SqlParam("RefId",_model.RefId),
                new SqlParam("Debit",_model.Debit),
                new SqlParam("Credit",_model.Credit),
                new SqlParam("Amount",_model.Amount),
                new SqlParam("TransactedBy",AppData.UserId)
            };

            result= oDAL.Request(new SqlQuery("sp_SaveGLOpeningBalance", true, _params), DAL.QueryExecutionTypes.Data);
                oDAL.Commit();
                return result;
            }
            catch (Exception ex)
            {
                oDAL.Rollback();
                throw ex;
            }
        }

        public object GetCustomerOB(long CustomerId)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CustomerId",CustomerId)
            };
            return oDAL.Request(new SqlQuery("sp_GetCustomerOB", true, _params), DAL.QueryExecutionTypes.Data);
        }
        public object GetVendorOB(long VendorId)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VendorId",VendorId)
            };
            return oDAL.Request(new SqlQuery("sp_GetVendorOB", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList(string COAType)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("COAType",COAType)
            };
            return oDAL.Request(new SqlQuery("sp_GetOBList", true, _params), DAL.QueryExecutionTypes.Data);
        }




    }
}
