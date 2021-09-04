using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class TaxTypeModel
    {
        public struct TaxType
        {
            public int TaxTypeId { get; set; }
            public string TaxTypeName { get; set; }
            public decimal TaxPercentage { get; set; }
            public decimal SellPrice { get; set; }
        }

        public object Save(TaxType _model)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("TaxTypeId",_model.TaxTypeId),
                new SqlParam("TaxTypeName",_model.TaxTypeName),
                new SqlParam("TaxPercentage",_model.TaxPercentage),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            return oDAL.Request(new SqlQuery("sp_SaveTaxType", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetById(int ID)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("TaxTypeId",ID)
            };

            return oDAL.Request(new SqlQuery("sp_GetTaxType", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetTaxTypes()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetTaxTypes", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetTaxTypeList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetTaxTypeList", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
