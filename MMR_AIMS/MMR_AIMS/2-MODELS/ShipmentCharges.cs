using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class ShipmentChargesModel
    {
        public struct ShipmentCharges
        {
            public long SCId { get; set; }
            public string Remarks { get; set; }
            public DateTime SCDate { get; set; }
            public DataTable Items { get; set; }
        }
        

        public object Save(ShipmentCharges _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {

                DataTable dt = _model.Items.DefaultView.ToTable(false, "CustomerId", "Amount", "CarrierId");
                List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("SCId",_model.SCId),
                new SqlParam("SCDate",_model.SCDate),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("Data",dt,SqlDbType.Structured),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            result= oDAL.Request(new SqlQuery("sp_SaveShipmentCharges", true, _params), DAL.QueryExecutionTypes.Data);
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
                new SqlParam("SCId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetShipmentCharges", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetShipmentChargesList", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
