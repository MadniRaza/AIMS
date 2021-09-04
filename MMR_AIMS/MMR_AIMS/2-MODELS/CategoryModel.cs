using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class CategoryModel
    {
        public struct Category
        {
            public int CategoryId { get; set; }
            public int ParentId { get; set; }
            public string CategoryName { get; set; }
            public bool Active { get; set; }
        }

        public object Save(Category _model)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CategoryId",_model.CategoryId),
                new SqlParam("CategoryName",_model.CategoryName),
                new SqlParam("ParentId",_model.ParentId),
                new SqlParam("Active",_model.Active),
                new SqlParam("TransactedBy",AppData.UserId),
            };

            return oDAL.Request(new SqlQuery("sp_SaveCategory", true, _params), DAL.QueryExecutionTypes.Data);
        }

        public object GetById(int Id)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CategoryId",Id)
            };
            return oDAL.Request(new SqlQuery("sp_GetCategory", true, _params), DAL.QueryExecutionTypes.Data);

        }

        public object GetList()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCategoryList", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetCategories()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCategories", true), DAL.QueryExecutionTypes.Data);
        }
        public object GetCategoryTree()
        {
            DAL oDAL = new DAL(false);
            return oDAL.Request(new SqlQuery("sp_GetCategoryTree", true), DAL.QueryExecutionTypes.Data);
        }

    }
}
