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
    public partial class fVendorLedgerReport : Form
    {
        #region Data Fields
        int ID = 0;
        #endregion
        public fVendorLedgerReport()
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
                dtpFrom.MinDate = AppData.FiscalYearFromDate;
                dtpFrom.MaxDate = AppData.FiscalYearToDate;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        public string ValidateFields()
        {
            StringBuilder sb = new StringBuilder();
            if (ID == 0)
                sb.AppendLine("Please select Vendor.");
            return sb.ToString();
        }
        public void SetFormState(string action)
        {
            switch (action.ToLower())
            {
                case "on_load":
                    PauseActions(true);
                    //LOAD OBJECTS
                    LoadInitialData();
                    PauseActions(false);
                    // CLEAR VALUES
                    // ENABLE / DISABLE

                    btnLoad.Enabled = true;
                    btnReset.Enabled = true;
                    break;

                case "on_reset":
                    PauseActions(true);
                    //LOAD OBJECTS
                    LoadInitialData();
                    PauseActions(false);
                    // CLEAR VALUES
                    ID = 0;
                    txtName.Text = "";
                    btnLoad.Enabled = true;
                    btnReset.Enabled = true;
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

        private void btnReset_Click(object sender, EventArgs e)
        {
            SetFormState("on_reset");
        }

        #endregion

        private void btnLoad_Click(object sender, EventArgs e)
        {
            try
            {


                string errors = ValidateFields();
                if (errors.Length > 0)
                {
                    MessageBox.Show(errors, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                CompanyModel modelCompany = new CompanyModel();
                DataTable dtCompany = ((DataSet)modelCompany.Get()).Tables[0].Copy();
                dtCompany.Rows[0]["LogoPath"] = "file:/" + Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dtCompany.Rows[0]["LogoPath"].ToString()).Replace(@"\", "/");
                VendorModel modelVendor = new VendorModel();
                DataTable dtItem = ((DataSet)modelVendor.GetById(ID)).Tables[0].Copy();
                DataSet ds = (DataSet)modelVendor.GetVendorLedger(ID, dtpFrom.Value, dtpTo.Value);

                DataTable dtLedger = ds.Tables[0].Copy();
                DataTable dtVendorLedger = ds.Tables[1].Copy();

                dtCompany.TableName = "Company";
                dtItem.TableName = "Vendor";
                dtLedger.TableName = "Ledger";
                dtVendorLedger.TableName = "VendorLedger";

                DataSet dsReport = new DataSet();
                dsReport.Tables.Add(dtCompany);
                dsReport.Tables.Add(dtItem);
                dsReport.Tables.Add(dtLedger);
                dsReport.Tables.Add(dtVendorLedger);

                fReportViewer frm = new fReportViewer();
                frm.dsReport = dsReport;
                frm.ReportPath = Path.Combine(AppData.IsLive ? AppDomain.CurrentDomain.BaseDirectory : Directory.GetParent(Directory.GetCurrentDirectory()).Parent.FullName, "4-Reports", "3-Purchase", "rptVendorLedger.rdlc");
                frm.HeaderText = "Vendor Ledger Report";
                frm.MdiParent = this.MdiParent;
                frm.Show();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }



        private void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                fSearch oSearch = new fSearch();
                oSearch.Left = this.Left + 100;
                oSearch.Top = this.Top + 100;
                oSearch.SearchType = fSearch.SearchFor.Vendor;
                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    ID = Convert.ToInt32(result["VendorId"]);
                    txtName.Text = result["BillingName"].ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
