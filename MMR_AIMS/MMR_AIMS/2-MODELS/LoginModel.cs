using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class LoginModel
    {
        public struct User
        {
            public long UserID { get; set; }
            public string UserName { get; set; }
            public string UserPwd { get; set; }
        }

        public object ValidateUser(User _user) 
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("UserName",_user.UserName),
                new SqlParam("UserPassword",_user.UserPwd),
                
            };

            return  oDAL.Request(new SqlQuery("sp_ValidateUser", true, _params), DAL.QueryExecutionTypes.Data);


            return false;

        }
    }
}
