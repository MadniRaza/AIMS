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
    public partial class fItemReport : Form
    {
        #region Data Fields
        int ID = 0;
        #endregion
        public fItemReport()
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
                sb.AppendLine("Please select Item.");
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
                    chkWithStock.Checked = false;
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
                //if (errors.Length > 0)
                //{
                //    MessageBox.Show(errors, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                //    return;
                //}
                CompanyModel modelCompany = new CompanyModel();
                DataTable dtCompany = ((DataSet)modelCompany.Get()).Tables[0].Copy();
                dtCompany.Rows[0]["LogoPath"] = "file:/" + Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dtCompany.Rows[0]["LogoPath"].ToString()).Replace(@"\", "/");
                ItemModel modelItem = new ItemModel();
                DataSet ds = (DataSet)modelItem.GetItemReport(ID);

                DataTable dtItemLedger = ds.Tables[0].Copy();
                if (chkWithStock.Checked == false) 
                {
                    dtItemLedger.Columns.Remove("Qty");
                    DataColumn c = new DataColumn();
                    c.DefaultValue = 0;
                    c.ColumnName = "Qty";
                    dtItemLedger.Columns.Add(c);
                }

                dtCompany.TableName = "Company";
                dtItemLedger.TableName = "ItemDetail";

                DataSet dsReport = new DataSet();
                dsReport.Tables.Add(dtCompany);
                dsReport.Tables.Add(dtItemLedger);

                fReportViewer frm = new fReportViewer();
                frm.dsReport = dsReport;
                frm.ReportPath = Path.Combine(AppData.IsLive ? AppDomain.CurrentDomain.BaseDirectory : Directory.GetParent(Directory.GetCurrentDirectory()).Parent.FullName,"4-Reports","2-Inventory", "rptItemDetail.rdlc");
                frm.HeaderText = "Item Report";
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
                oSearch.SearchType = fSearch.SearchFor.Category;
                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    ID = Convert.ToInt32(result["CategoryId"]);
                    txtName.Text = result["CategoryName"].ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
