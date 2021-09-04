using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fVendorOB : Form
    {
        #region Data Fields
        int ID = 0;
        long COAId = 0;

        #endregion
        public fVendorOB()
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
                OBModel model = new OBModel();
                DataTable dt = ((DataSet)model.GetList("VENDOR")).Tables[0];
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
                OBModel model = new OBModel();
                DataTable dt = ((DataSet)model.GetVendorOB(ID)).Tables[0];
                txtNo.Text = dt.Rows[0]["RefId"].ToString();
                COAId = Convert.ToInt64(dt.Rows[0]["COAId"].ToString());
                txtBilling.Text = dt.Rows[0]["BillingName"].ToString();
                txtOB.Text = dt.Rows[0]["OB"].ToString();
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
            e.Handled = Utilities.ValidateDecimal(e.KeyChar, (sender as TextBox).Text, true);
        }
        public string ValidateFields()
        {
            StringBuilder sb = new StringBuilder();
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtBilling.Text.Trim())))
                sb.AppendLine("Please enter Tax Type.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtOB.Text.Trim())))
                sb.AppendLine("Please enter Tax Percentage.");
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
                    COAId = 0;
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
                    
                    btnSave.Enabled = false;
                    btnReset.Enabled = false;
                    break;
                case "on_add":
                    //LOAD OBJECTS

                    // CLEAR VALUES
                    ID = 0;
                    COAId = 0;
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
                    COAId = 0;
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
                    
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    
                    break;
                case "on_load_object":
                    PauseActions(true);
                    //LOAD OBJECTS

                    // CLEAR VALUES
                    ID = 0;
                    COAId = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }

                    txtNo.Text = "Auto";

                    // ENABLE / DISABLE
                    gb.Enabled = true;
                    dgList.Enabled = false;
                    
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    break;
                case "on_object_loaded":
                    PauseActions(false);
                    gb.Enabled = true;
                    txtSearch.Enabled = false;
                    cbFilter.Enabled = false;
                    dgList.Enabled = false;
                    
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
                filter_text += " ";
                filter_text += " BillingName LIKE '%" + search_value + "%'";
                filter_text += " OR Convert(OB,'System.String') LIKE '%" + search_value + "%' ";
                filter_text += " ";
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
                OBModel modelItem = new OBModel();
                OBModel.OB obj = new OBModel.OB();
                obj.RefId = ID;
                obj.COAId = COAId;
                obj.COACode = "VENDOR";
                obj.Credit =Convert.ToDecimal( txtOB.Text);
                obj.Debit = 0;
                obj.Amount = Convert.ToDecimal(txtOB.Text);

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

        private void btnSearchVendor_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {

        }
    }
}
