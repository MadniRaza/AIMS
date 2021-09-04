using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public static class AppData
    {
        public static int UserId { get; set; }
        public static bool IsLive { get; set; } = false;
        public static string UserName { get; set; }
        public static DataTable dtMenus { get; set; }
        public static string ErrorCaption { get; set; } = "Oh! Something went wrong.";
        public static string SuccessMessageCaption { get; set; } = "Success!";
        public static string SuccessMessage { get; set; } = "Transaction Processed Successfully!";

        public static DateTime FiscalYearFromDate { get; set; } = DateTime.Now.AddDays(-365);
        public static DateTime FiscalYearToDate { get; set; } = DateTime.Now;
        public static string DateTimeFormat = "dd-MM-yyyy HH:mm";
        public static string DateFormat = "dd-MM-yyyy";



    }
}
