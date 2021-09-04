using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class CustomerModel
    {
        public struct Customer
        {
            public int CustomerId { get; set; }
            public string BillingName { get; set; }
            public string BillingAddress1 { get; set; }
            public string BillingAddress2 { get; set; }
            public string ShippingAddress1 { get; set; }
            public string ShippingAddress2 { get; set; }
            public string ShippingName { get; set; }
            public string TelNo { get; set; }
            public string PhoneNo { get; set; }
            public string NTNNo { get; set; }
            public string STRNo { get; set; }
            
            public bool Active { get; set; }
        }

        public object Save(Customer _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CustomerId",_model.CustomerId),
                new SqlParam("BillingName",_model.BillingName),
                new SqlParam("BillingAddress1",_model.BillingAddress1),
                new SqlParam("BillingAddress2",_model.BillingAddress2),
                new SqlParam("ShippingName",_model.ShippingName),
                new SqlParam("ShippingAddress1",_model.ShippingAddress1),
                new SqlParam("ShippingAddress2",_model.ShippingAddress2),
                new SqlParam("TelNo",_model.TelNo),
                new SqlParam("PhoneNo",_model.PhoneNo),
                new SqlParam("NTNNo",_model.NTNNo),
                new SqlParam("STRNo",_model.STRNo),
                new SqlParam("Active",_model.Active),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SaveCustomer", true, _params), DAL.QueryExecutionTypes.Data);
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
                new SqlParam("CustomerId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetCustomer", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCustomerList", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetCustomers()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCustomers", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetCustomerLedger(int CustomerId, DateTime FromDate, DateTime ToDate)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CustomerId",CustomerId),
                new SqlParam("FromDate",FromDate),
                new SqlParam("ToDate",ToDate),
            };
            return oDAL.Request(new SqlQuery("sp_GetCustomerLedger", true,_params), DAL.QueryExecutionTypes.Data);
        }
        public object GetCustomerBalance(int CustomerId, DateTime timeStamp)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CustomerId",CustomerId),
                new SqlParam("Timestamp",timeStamp)
            };
            return oDAL.Request(new SqlQuery("sp_GetCustomerBalance", true, _params), DAL.QueryExecutionTypes.Data);
        }

    }
}
