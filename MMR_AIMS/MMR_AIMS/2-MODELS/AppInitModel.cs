using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class AppInitModel
    {

        public object GetAllMenus() 
        {
            DAL oDAL = new DAL(false);

            return oDAL.Request(new SqlQuery("sp_GetAllMenus",true), DAL.QueryExecutionTypes.Data);
        }
        public object GetActiveFiscalYear()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetActiveFiscalYear", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
