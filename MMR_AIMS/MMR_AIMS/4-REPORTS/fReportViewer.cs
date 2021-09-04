using Microsoft.Reporting.WinForms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fReportViewer : Form
    {
        #region Data Fields
        public DataSet dsReport;
        public string ReportPath = "";
        public string HeaderText = "";

        #endregion
        public fReportViewer()
        {
            InitializeComponent();
        }

        #region "Form Helpers"
        private void frm_load(object sender, EventArgs e)
        {
            SetFormState("on_load");


        }
        private void frm_Move(object sender, EventArgs e)
        {
            if (this.Left <= 10)
            {
                this.Left = 10;
            }
            else if (this.Left >= (this.MdiParent.ClientRectangle.Width - 10) - this.Width)
            {
                this.Left = (this.MdiParent.ClientRectangle.Width - 10) - this.Width;
            }
            if (this.Top < 0)
            {
                this.Top = 0;
            }
            else if (this.Top >= 20)
            {
                this.Top = 20;
            }
        }


        public void LoadInitialData()
        {
            try
            {
                this.Text = HeaderText;
                this.rv.RefreshReport();
                this.rv.LocalReport.EnableExternalImages = true;
                this.rv.LocalReport.ReportPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, ReportPath);
                this.rv.LocalReport.DataSources.Clear();
                ReportDataSource rds;
                for (int i = 0; i < dsReport.Tables.Count; i++)
                {
                    rds = new ReportDataSource(dsReport.Tables[i].TableName, dsReport.Tables[i]);
                    rv.LocalReport.DataSources.Add(rds);
                }
                this.rv.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }



        public void SetFormState(string action)
        {
            switch (action.ToLower())
            {
                case "on_load":
                    PauseActions(true);
                    //LOAD OBJECTS
                    this.rv.RefreshReport();
                    LoadInitialData();

                    PauseActions(false);
                    break;
                default:
                    break;
            }
        }
        void PauseActions(bool status)
        {
            if (status)
            {
                this.Invoke((MethodInvoker)delegate
                {
                    this.Cursor = System.Windows.Forms.Cursors.WaitCursor;
                });
            }
            else
            {
                this.Invoke((MethodInvoker)delegate
                {
                    this.Cursor = System.Windows.Forms.Cursors.Default;
                });
            }
        }



        #endregion
    }
}
