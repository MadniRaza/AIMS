using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class BadInventoryModel
    {
        public struct BadInventory
        {
            public long RecordId { get; set; }
            public int ItemId { get; set; }
            public int Qty { get; set; }
            public string Remarks { get; set; }
        }

        public object Save(BadInventory _model)
        {
            object result = null;
            DAL oDAL = new DAL(true);
            try
            {
                List<SqlParam> _params = new List<SqlParam>()
            {
                    new SqlParam("RecordId",_model.RecordId),
                new SqlParam("ItemId",_model.ItemId),
                new SqlParam("Qty",_model.Qty),
                new SqlParam("Remarks",_model.Remarks),
                new SqlParam("TransactedBy",AppData.UserId),
            };

                result = oDAL.Request(new SqlQuery("sp_SaveBadInventory", true, _params), DAL.QueryExecutionTypes.Data);
                oDAL.Commit();
                return result;
            }
            catch (Exception ex)
            {
                oDAL.Rollback();
                throw ex;
            }
            
        }

        public object GetById(long ID)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("RecordId",ID)
            };

            return oDAL.Request(new SqlQuery("sp_GetBadInventory", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetBadInventoryList", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
