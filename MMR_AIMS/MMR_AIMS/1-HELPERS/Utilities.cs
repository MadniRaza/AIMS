using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public class Utilities
    {

        public static string ValidateText(string value)
        {
            string _val = string.Empty;

            _val = value.Replace("'", "");
            
            return _val;
        }

        public static bool ValidateDecimal(char c, string text, bool allowNegativeValue = false)
        {
            if (!char.IsControl(c)
         && !char.IsDigit(c)
         && c != '.' && c!='-')
            {
                return true;
            }
            if (c == '.'
                && text.IndexOf('.') > -1)
            {
                return true;
            }
            if (!allowNegativeValue && c == '-')
                return true;
            if (allowNegativeValue && c == '-' && text.Length > 0)
                return true;
            if (text.Length == 8)
                return true;
            return false;
        }
        public static bool ValidateNumber(char c, string text)
        {
            if (!char.IsControl(c)
         && !char.IsDigit(c)
         )
                return true;


            if (text.Length == 6)
                return true;
            return false;
        }

        public static void PrepareOptionList(DataTable dt, string _displayMember, string _valueMember, ref System.Windows.Forms.ComboBox cb, bool showFirstOption = true, string firstOption = "")
        {
            if (showFirstOption)
            {
                DataRow dr = dt.NewRow();
                dr[_valueMember] = "0";
                dr[_displayMember] = string.IsNullOrEmpty(firstOption) ? "--SELECT--" : firstOption;
                dt.Rows.InsertAt(dr, 0);
            }
            cb.DisplayMember = _displayMember;
            cb.ValueMember = _valueMember;
            cb.DataSource = dt;
        }

        public static DataTable CreateDataTable(string columns)
        {
            columns = columns.Trim();
            DataTable dt = new DataTable();
            string[] cols = columns.Split(',');
            foreach (string col in cols)
            {
                dt.Columns.Add(col);
            }
            return dt;
        }
        public static DataTable CreateDtWithRow(Dictionary<string, string> obj)
        {
            DataTable dt = new DataTable();
            foreach (var i in obj)
            {
                dt.Columns.Add(i.Key);
            }
            DataRow dr;
            dr = dt.NewRow();
            foreach (var i in obj)
            {
                dr[i.Key] = i.Value;
            }
            dt.Rows.Add(dr);
            return dt;
        }

        public static void ShowSuccesMessage(Form source) 
        {
            fDashboard parent = (fDashboard)source.MdiParent;
            parent.messageInterval = 0;
            parent.ssSuccessMessage.Visible = true;
            parent.timerMessage.Enabled = true;

        }
    
    }
}
