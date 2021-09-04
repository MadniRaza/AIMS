using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class COAModel
    {
   
        public object GetJVAccounts()
        {
            DAL oDAL = new DAL(false);

            return oDAL.Request(new SqlQuery("sp_GetJVAccounts", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetGLAccounts()
        {
            DAL oDAL = new DAL(false);

            return oDAL.Request(new SqlQuery("sp_GetGLAccounts", true), DAL.QueryExecutionTypes.Data);
        }

        public object GetById(long Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("COAId",Id),
                
            };

            return oDAL.Request(new SqlQuery("sp_GetCOA", true,_params), DAL.QueryExecutionTypes.Data);
        }

        public object GetGeneralLedger(long COAId, DateTime FromDate, DateTime ToDate)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("COAId",COAId),
                new SqlParam("FromDate",FromDate),
                new SqlParam("ToDate",ToDate),
            };
            return oDAL.Request(new SqlQuery("sp_GetGeneralLedger", true, _params), DAL.QueryExecutionTypes.Data);
        }

    }
}
