using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class CarrierModel
    {
        public struct Carrier
        {
            public int CarrierId { get; set; }
            public string CarrierName { get; set; }
            public bool Active { get; set; }
        }

        public object Save(Carrier _model)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CarrierId",_model.CarrierId),
                new SqlParam("CarrierName",_model.CarrierName),
                new SqlParam("Active",_model.Active),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            return oDAL.Request(new SqlQuery("sp_SaveCarrier", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetById(int Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CarrierId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetCarrier", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCarrierList", true), DAL.QueryExecutionTypes.Data);
        }
       public object GetCarriers()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCarriers", true), DAL.QueryExecutionTypes.Data);
        }


    }
}
