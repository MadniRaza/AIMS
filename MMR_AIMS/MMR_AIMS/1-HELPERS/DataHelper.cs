using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MMR_AIMS
{
    public class DataHelper
    {

        public enum DateTimeFormat
        {
            Date = 1,
            DateTime = 2
        }

        public static DataTable UpdateColumnDateFormat(string columns, DataTable dt, DateTimeFormat format)
        {
            DataTable dtNew = dt.Copy();
            switch (format)
            {
                case DateTimeFormat.Date:
                 
                    dtNew.AsEnumerable().ToList<DataRow>().ForEach(r =>
                    
                    {
                        string parsed_date = Convert.ToDateTime(r["FromDate"]).ToString("dd-MM-yyyy");

                        r["FromDate"] =DateTime.ParseExact(parsed_date, "dd-MM-yyyy", null);
                    });

                    string[] arr = columns.Split(',');
                    for (int i = 0; i < arr.Length; i++)
                    {
                        for (int j = 0; j < dtNew.Rows.Count; j++)
                        {
                            dtNew.Rows[j]["FromDate"] =  Convert.ToDateTime(dtNew.Rows[j]["FromDate"]).ToString("dd-MM-yyyy");
                        }
                        //dt.AsEnumerable().ToList<DataRow>().ForEach(r =>
                        //{
                        //    r[arr[i]] = Convert.ToDateTime(r[arr[i]]).ToString("dd-MM-yyyy");
                        //});
                    }
                    dtNew.AcceptChanges();
                    break;
                case DateTimeFormat.DateTime:
                    //dt.AsEnumerable().ToList<DataRow>().ForEach(r =>
                    //{
                    //    string[] arr = columns.Split(',');
                    //    for (int i = 0; i < arr.Length; i++)
                    //    {
                    //        r[arr[i]] = Convert.ToDateTime(r[arr[i]]).ToString(AppData.DateTimeFormat);
                    //    }
                        
                    //});
                    break;
                default:
                    break;
            }
            return dt;
        }

        public static DataTable MergeDataTable(DataTable dtMaster, DataTable dtDetail) 
        {
            DataTable dt1 = dtMaster.Clone();
            DataTable dt2 = dtDetail.Clone();
            dt1.Merge(dt2);
            foreach (DataRow detailRow in dtDetail.Rows)
            {
                DataRow dr = dt1.NewRow();
                foreach (DataRow masterRow in dtMaster.Rows)
                {
                    for (int i = 0; i < dtMaster.Columns.Count; i++)
                    {
                        dr[dtMaster.Columns[i].ColumnName] = masterRow[dtMaster.Columns[i].ColumnName];
                    }
                }
                for (int i = 0; i < dtDetail.Columns.Count; i++)
                {
                    dr[dtDetail.Columns[i].ColumnName] = detailRow[dtDetail.Columns[i].ColumnName];
                }


                dt1.Rows.Add(dr);
            }
            


            return dt1;

        }

    }
}
