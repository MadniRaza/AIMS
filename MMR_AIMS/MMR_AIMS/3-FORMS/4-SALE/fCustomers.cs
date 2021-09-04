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
    public partial class fCustomers : Form
    {
        #region Data Fields
        int ID = 0;

        #endregion
        public fCustomers()
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
                cbFilter.Items.Add("All");
                cbFilter.Items.Add("Active");
                cbFilter.Items.Add("InActive");

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
                CustomerModel model = new CustomerModel();
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
                CustomerModel model = new CustomerModel();
                DataTable dt = ((DataSet)model.GetById(ID)).Tables[0];
                txtVendorNo.Text = dt.Rows[0]["CustomerId"].ToString();
                txtBillingName.Text = dt.Rows[0]["BillingName"].ToString();
                txtBillAddr1.Text = dt.Rows[0]["BillingAddress1"].ToString();
                txtBillAddr2.Text = dt.Rows[0]["BillingAddress2"].ToString();
                txtShipName.Text = dt.Rows[0]["ShippingName"].ToString();
                txtShipAddr1.Text = dt.Rows[0]["ShippingAddress1"].ToString();
                txtShipAddr2.Text = dt.Rows[0]["ShippingAddress2"].ToString();
                txtPhone.Text = dt.Rows[0]["PhoneNo"].ToString();
                txtTel.Text = dt.Rows[0]["TelNo"].ToString();
                txtNTNNo.Text = dt.Rows[0]["NTNNo"].ToString();
                txtSTRNo.Text = dt.Rows[0]["STRNo"].ToString();

                chkActive.Checked = Convert.ToBoolean(dt.Rows[0]["Active"]);
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
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtBillingName.Text.Trim())))
                sb.AppendLine("Please enter Billing Name.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtBillAddr1.Text.Trim())))
                sb.AppendLine("Please enter Billing Address.");
            
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
                    txtVendorNo.Text = "Auto";
                    cbFilter.SelectedIndex = 0;


                    // ENABLE / DISABLE
                    chkActive.Checked = false;
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
                    txtVendorNo.Text = "Auto";
                    cbFilter.SelectedIndex = 0;
                    chkActive.Checked = true;
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
                    txtVendorNo.Text = "Auto";
                    chkActive.Checked = false;

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
                    txtVendorNo.Text = "Auto";

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
            if (cbFilter.Text.ToLower().Equals("all"))
                filter_text += "0 = 0";
            else if (cbFilter.Text.ToLower().Equals("active"))
                filter_text += " Active = 'Y'";
            else if (cbFilter.Text.ToLower().Equals("inactive"))
                filter_text += " Active = 'N'";


            if (!string.IsNullOrEmpty(search_value))
            {
                filter_text += " AND (";
                filter_text += " BillingName LIKE '%" + search_value + "%'";
                //filter_text += " OR Desc LIKE '%" + search_value + "%'";
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
                CustomerModel model = new CustomerModel();
                CustomerModel.Customer obj = new CustomerModel.Customer();
                obj.CustomerId = ID;
                obj.BillingName = Utilities.ValidateText(txtBillingName.Text);
                obj.BillingAddress1 = Utilities.ValidateText(txtBillAddr1.Text);
                obj.BillingAddress2 = Utilities.ValidateText(txtBillAddr2.Text);
                obj.ShippingName = Utilities.ValidateText(txtShipName.Text);
                obj.ShippingAddress1 = Utilities.ValidateText(txtShipAddr1.Text);
                obj.ShippingAddress2 = Utilities.ValidateText(txtShipAddr2.Text);
                obj.PhoneNo = Utilities.ValidateText(txtPhone.Text);
                obj.TelNo = Utilities.ValidateText(txtTel.Text);
                obj.NTNNo = Utilities.ValidateText(txtNTNNo.Text);
                obj.STRNo = Utilities.ValidateText(txtSTRNo.Text);
                
                obj.Active = chkActive.Checked;
                model.Save(obj);

                Utilities.ShowSuccesMessage(this);
                SetFormState("on_reset");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        #endregion

        
    }
}
