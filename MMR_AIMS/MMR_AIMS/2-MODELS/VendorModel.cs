using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class VendorModel
    {
        public struct Vendor
        {
            public int VendorId { get; set; }
            public string BillingName { get; set; }
            public string BillingAddress1 { get; set; }
            public string BillingAddress2 { get; set; }
            
            public string TelNo { get; set; }
            public string PhoneNo { get; set; }
            public string NTNNo { get; set; }
            public string STRNo { get; set; }
            
            public bool Active { get; set; }
        }

        public object Save(Vendor _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VendorId",_model.VendorId),
                new SqlParam("BillingName",_model.BillingName),
                new SqlParam("BillingAddress1",_model.BillingAddress1),
                new SqlParam("BillingAddress2",_model.BillingAddress2),
                new SqlParam("TelNo",_model.TelNo),
                new SqlParam("PhoneNo",_model.PhoneNo),
                new SqlParam("NTNNo",_model.NTNNo),
                new SqlParam("STRNo",_model.STRNo),
                new SqlParam("Active",_model.Active),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SaveVendor", true, _params), DAL.QueryExecutionTypes.Data);

                oDAL.Commit();
                return result;
            }
            catch (Exception ex)
            {
                oDAL.Rollback();
                throw ex;
            }
        }

        public object GetById(int Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VendorId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetVendor", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetVendorList", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetVendors()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetVendors", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetVendorLedger(int VendorId, DateTime FromDate, DateTime ToDate)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VendorId",VendorId),
                new SqlParam("FromDate",FromDate),
                new SqlParam("ToDate",ToDate),
            };
            return oDAL.Request(new SqlQuery("sp_GetVendorLedger", true,_params), DAL.QueryExecutionTypes.Data);
        }
        public object GetVendorBalance(int VendorId, DateTime timeStamp)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("VendorId",VendorId),
                new SqlParam("Timestamp",timeStamp)
            };
            return oDAL.Request(new SqlQuery("sp_GetVendorBalance", true, _params), DAL.QueryExecutionTypes.Data);
        }
    }
}
