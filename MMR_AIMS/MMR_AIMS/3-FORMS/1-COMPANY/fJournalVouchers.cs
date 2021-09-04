using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlTypes;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fJournalVouchers : Form
    {
        #region Data Fields
        long ID = 0;
        long DebitCOAId = 0;
        long CreditCOAId = 0;
        #endregion
        public fJournalVouchers()
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
        private void dgList_MouseDown(object sender, MouseEventArgs e)
        {
            dgList.ClearSelection();
            if (e.Button == MouseButtons.Right)
            {
                DataGridView.HitTestInfo hit = dgList.HitTest(e.X, e.Y);
                if (hit.Type == DataGridViewHitTestType.Cell)
                {
                    //mstRowIndex = hit.RowIndex;
                    dgList.Rows[hit.RowIndex].Selected = true;
                }
            }
        }

        public void LoadInitialData()
        {
            try
            {
                cbFilter.Items.Clear();
                cbFilter.Items.Add("");

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        void LoadList()
        {
            try
            {
                JournalVoucherModel model = new JournalVoucherModel();
                DataTable dt = ((DataSet)model.GetList()).Tables[0];
                dgList.AutoGenerateColumns = false;
                dgList.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        private void cbFilter_SelectionChangeCommitted(object sender, EventArgs e)
        {
            FilterRecords();
        }
        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            FilterRecords();
        }
        private void mnuEdit_Click(object sender, EventArgs e)
        {
            try
            {
                SetFormState("on_load_object");
                ID = Convert.ToInt32(dgList.Rows[dgList.SelectedRows[0].Index].Cells["cListId"].Value);
                JournalVoucherModel model = new JournalVoucherModel();
                DataTable dt = ((DataSet)model.GetById(ID)).Tables[0];
                txtNo.Text = dt.Rows[0]["JVNumber"].ToString();
                txtRemarks.Text = dt.Rows[0]["Remarks"].ToString();
                txtAmount.Text = dt.Rows[0]["Amount"].ToString();
                dtpDate.Value = Convert.ToDateTime(dt.Rows[0]["JVDate"]);
                txtDrCOA.Text =dt.Rows[0]["DebitCOAName"].ToString();
                txtCrCOA.Text =dt.Rows[0]["CreditCOAName"].ToString();
                SetFormState("on_object_loaded");
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        private void ValidateNumber(object sender, KeyPressEventArgs e)
        {
            e.Handled = Utilities.ValidateNumber(e.KeyChar, (sender as TextBox).Text);
        }
        private void ValidateDecimal(object sender, KeyPressEventArgs e)
        {
            e.Handled = Utilities.ValidateDecimal(e.KeyChar, (sender as TextBox).Text);
        }
        public string ValidateFields()
        {
            StringBuilder sb = new StringBuilder();
            if(Convert.ToInt64(DebitCOAId) == 0 || Convert.ToInt64(CreditCOAId) == 0)
                sb.AppendLine("Please Select Accounts.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtRemarks.Text.Trim())))
                sb.AppendLine("Please enter remarks.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtAmount.Text.Trim())))
                sb.AppendLine("Please enter Amount.");
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
                    LoadList();
                    PauseActions(false);
                    // CLEAR VALUES
                    ID = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";
                    txtNo.Text = "Auto";
                    cbFilter.SelectedIndex = 0;


                    // ENABLE / DISABLE

                    txtSearch.Enabled = true;
                    cbFilter.Enabled = true;
                    gb.Enabled = false;
                    dgList.Enabled = true;
                    btnAdd.Enabled = true;
                    btnSave.Enabled = false;
                    btnReset.Enabled = false;
                    break;
                case "on_add":
                    //LOAD OBJECTS

                    // CLEAR VALUES
                    ID = 0;
                    txtSearch.Text = "";
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtNo.Text = "Auto";
                    cbFilter.SelectedIndex = 0;

                    gb.Enabled = true;
                    // ENABLE / DISABLE
                    txtSearch.Enabled = false;
                    cbFilter.Enabled = false;
                    dgList.Enabled = false;
                    btnAdd.Enabled = false;
                    btnSave.Enabled = true;
                    btnReset.Enabled = true;
                    break;
                case "on_reset":
                    PauseActions(true);
                    //LOAD OBJECTS
                    LoadList();
                    PauseActions(false);
                    // CLEAR VALUES
                    ID = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";

                    cbFilter.SelectedIndex = 0;
                    txtNo.Text = "Auto";


                    // ENABLE / DISABLE
                    gb.Enabled = false;
                    txtSearch.Enabled = true;
                    cbFilter.Enabled = true;
                    dgList.Enabled = true;
                    btnAdd.Enabled = true;
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    btnAdd.Focus();
                    break;
                case "on_load_object":
                    PauseActions(true);
                    //LOAD OBJECTS

                    // CLEAR VALUES
                    ID = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }

                    txtNo.Text = "Auto";

                    // ENABLE / DISABLE
                    gb.Enabled = true;
                    dgList.Enabled = false;
                    btnAdd.Enabled = false;
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    break;
                case "on_object_loaded":
                    PauseActions(false);
                    gb.Enabled = true;
                    txtSearch.Enabled = false;
                    
                    cbFilter.Enabled = false;
                    dgList.Enabled = false;
                    btnAdd.Enabled = false;
                    btnSave.Enabled = true;
                    btnReset.Enabled = true;

                    btnReset.Focus();
                    break;
                case "on_save_uncommitted":
                    PauseActions(true);
                    gb.Enabled = false;
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    break;
                default:
                    break;
            }
        }
        public void FilterRecords()
        {
            string filter_text = "";
            string search_value = Utilities.ValidateText(txtSearch.Text);

            if (!string.IsNullOrEmpty(search_value))
            {
                filter_text += "  (";
                filter_text += " JVNumber LIKE '%" + search_value + "%'";
                filter_text += " OR DebitCOAName LIKE '%" + search_value + "%'";
                filter_text += " OR CreditCOAName LIKE '%" + search_value + "%'";
                filter_text += " OR Convert(JVDate,'System.String') LIKE '%" + search_value + "%' ";
                filter_text += " OR Convert(TotalAmount,'System.String') LIKE '%" + search_value + "%' ";
                filter_text += " )";
            }



            DataTable dt = (DataTable)dgList.DataSource;
            dt.DefaultView.RowFilter = filter_text;


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

        private void btnAdd_Click(object sender, EventArgs e)
        {
            SetFormState("on_add");
        }
        private void btnReset_Click(object sender, EventArgs e)
        {
            SetFormState("on_reset");
        }
        private void btnSave_Click(object sender, EventArgs e)
        {
            try
            {

                string errors = ValidateFields();
                if (errors.Length > 0)
                {
                    MessageBox.Show(errors, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                SetFormState("on_save_uncommitted");
                JournalVoucherModel modelItem = new JournalVoucherModel();
                JournalVoucherModel.JournalVoucher obj = new JournalVoucherModel.JournalVoucher();
                obj.JVId = ID;
                obj.DebitCOAId = DebitCOAId;
                obj.CreditCOAId = CreditCOAId;
                obj.Remarks = Utilities.ValidateText(txtRemarks.Text);
                obj.Amount = Convert.ToDecimal(Utilities.ValidateText(txtAmount.Text));
                obj.JVDate = dtpDate.Value;
                modelItem.Save(obj);

                Utilities.ShowSuccesMessage(this);
                SetFormState("on_reset");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        #endregion

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void mnuPrint_Click(object sender, EventArgs e)
        {
            Print();
        }
        void Print()
        {
            long tmpID = Convert.ToInt32(dgList.Rows[dgList.SelectedRows[0].Index].Cells["cListId"].Value);
            CompanyModel modelCompany = new CompanyModel();
            DataTable dtCompany = ((DataSet)modelCompany.Get()).Tables[0].Copy();
            dtCompany.Rows[0]["LogoPath"] = "file:/" + Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dtCompany.Rows[0]["LogoPath"].ToString()).Replace(@"\", "/");
            JournalVoucherModel model1 = new JournalVoucherModel();
            DataSet ds = ((DataSet)model1.GetById(tmpID));
            DataTable dtMaster = ds.Tables[0].Copy();


            dtCompany.TableName = "Company";
            dtMaster.TableName = "JournalVoucher";
            

            DataSet dsReport = new DataSet();
            dsReport.Tables.Add(dtCompany);
            dsReport.Tables.Add(dtMaster);

            fReportViewer frm = new fReportViewer();
            frm.dsReport = dsReport;
            frm.ReportPath = Path.Combine(AppData.IsLive ? AppDomain.CurrentDomain.BaseDirectory : Directory.GetParent(Directory.GetCurrentDirectory()).Parent.FullName, "4-Reports", "1-Company", "rptJournalVoucher.rdlc");
            frm.HeaderText = "Journal Voucher";
            frm.MdiParent = this.MdiParent;
            frm.Show();
        }

        private void btnSearchDr_Click(object sender, EventArgs e)
        {
            try
            {
                fSearch oSearch = new fSearch();
                oSearch.Left = this.Left + AppStandards.ItemSearchleftMargin;
                oSearch.Top = this.Top + AppStandards.ItemSearchTopMargin;

                oSearch.SearchType = fSearch.SearchFor.JVCOA;

                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    DebitCOAId = Convert.ToInt32(result["COAId"]);
                    txtDrCOA.Text = result["COAName"].ToString();
                    SetFormState("on_item_selected");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnSearchCr_Click(object sender, EventArgs e)
        {
            try
            {
                fSearch oSearch = new fSearch();
                oSearch.Left = this.Left + AppStandards.ItemSearchleftMargin;
                oSearch.Top = this.Top + AppStandards.ItemSearchTopMargin;

                oSearch.SearchType = fSearch.SearchFor.JVCOA;

                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    CreditCOAId = Convert.ToInt32(result["COAId"]);
                    txtCrCOA.Text = result["COAName"].ToString();
                    SetFormState("on_item_selected");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
