using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class ActivityModel
    {
       public object BackupDB()
        {
            DAL oDAL = new DAL(false);

            return oDAL.Request(new SqlQuery("sp_BackupDB", true), DAL.QueryExecutionTypes.Data);
        }

    
        

    }
}
