using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class CompanyModel
    {
        public struct CompanyInfo
        {
            public string CompanyName { get; set; }
            public string AddressLine1 { get; set; }
            public string AddressLine2 { get; set; }
            public string NTNNo { get; set; }
            public string STRNo { get; set; }
            public string TelNo { get; set; }
            public string ContactPerson { get; set; }
            public string LogoPath { get; set; }
            public string ShortDesc { get; set; }
            public string Slogan { get; set; }
            public string InvoiceFooterRemarks { get; set; }
            public string Email { get; set; }
        }
        public object Save(CompanyInfo _model)
        {
            DAL oDAL = new DAL(false);
            List<SqlParam> _params = new List<SqlParam>()
            {
                new SqlParam("CompanyName",_model.CompanyName),
                new SqlParam("AddressLine1",_model.AddressLine1),
                new SqlParam("AddressLine2",_model.AddressLine2),
                new SqlParam("TelNo",_model.TelNo),
                new SqlParam("NTNNo",_model.NTNNo),
                new SqlParam("STRNo",_model.STRNo),
                new SqlParam("ContactPerson",_model.ContactPerson),
                new SqlParam("LogoPath",_model.LogoPath),
                new SqlParam("InvoiceFooterRemarks",_model.InvoiceFooterRemarks),
                new SqlParam("Email",_model.Email),
                new SqlParam("ShortDesc",_model.ShortDesc),
                new SqlParam("Slogan",_model.Slogan),
            };

            return oDAL.Request(new SqlQuery("sp_SaveCompanyInfo", true, _params), DAL.QueryExecutionTypes.Data);
        }
        public object BackupDB()
        {
            DAL oDAL = new DAL(false);

            return oDAL.Request(new SqlQuery("sp_BackupDB", true), DAL.QueryExecutionTypes.Data);
        }

        public object Get()
        {
            DAL oDAL = new DAL(false);
            
            return oDAL.Request(new SqlQuery("sp_GetCompanyInfo", true), DAL.QueryExecutionTypes.Data);
        }

        

    }
}
