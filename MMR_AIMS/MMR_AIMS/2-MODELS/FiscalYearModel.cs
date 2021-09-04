using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class FiscalYearModel
    {
        public struct FiscalYear
        {
            public int FiscalYearId { get; set; }
            public DateTime FromDate { get; set; }
            public DateTime ToDate { get; set; }
            public bool Active { get; set; }
        }

        public object Save(FiscalYear _model)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("FiscalYearId",_model.FiscalYearId),
                new SqlParam("FromDate",_model.FromDate),
                new SqlParam("ToDate",_model.ToDate),
                new SqlParam("Active",_model.Active),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            return oDAL.Request(new SqlQuery("sp_SaveFiscalYear", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetById(int ID)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("FiscalYearId",ID)
            };

            return oDAL.Request(new SqlQuery("sp_GetFiscalYear", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetFiscalYears()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetFiscalYears", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetFiscalYearList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetFiscalYearList", true), DAL.QueryExecutionTypes.Data);
        }
        

    }
}
