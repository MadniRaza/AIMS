using System;
using System.CodeDom;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fShipmentCharges : Form
    {
        #region Data Fields
        long ID = 0;
        int CustomerId = 0;
        bool EditItem = false;
        string DetailGridColumns = "CustomerId,CarrierId,BillingName,CarrierName,Amount";
        DataTable dtDetailGrid;



        #endregion
        public fShipmentCharges()
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
                    dgList.Rows[hit.RowIndex].Selected = true;
                }
            }
        }

        public void LoadInitialData()
        {
            try
            {
                CarrierModel model = new CarrierModel();
                DataTable dtTaxTypes = ((DataSet)model.GetCarriers()).Tables[0];
                Utilities.PrepareOptionList(dtTaxTypes.Copy(), "CarrierName", "CarrierId", ref cbCarrier,false);
                

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
                ShipmentChargesModel model = new ShipmentChargesModel();
                DataTable dt = ((DataSet)model.GetList()).Tables[0];
                dgList.AutoGenerateColumns = false;
                dgList.DataSource = dt;
                FilterRecords();
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
                ShipmentChargesModel model = new ShipmentChargesModel();
                DataSet ds = ((DataSet)model.GetById(ID));
                DataTable dtMaster = ds.Tables[0];
                DataTable dtDetail = ds.Tables[1];
                txtAGNo.Text = dtMaster.Rows[0]["SCNumber"].ToString();
                txtRemarks.Text = dtMaster.Rows[0]["Remarks"].ToString();
                dtpDate.Value = Convert.ToDateTime(dtMaster.Rows[0]["SCDate"]);
                txtTotalAmount.Text = dtMaster.Rows[0]["TotalAmount"].ToString();
                
                dtDetailGrid = dtDetail.Copy();
                dgDetail.AutoGenerateColumns = false;
                dgDetail.DataSource = dtDetailGrid;
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
            if (dtDetailGrid.Rows.Count == 0)
                sb.AppendLine("at least one item is required.");

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
                    //cbFilter.SelectedValue = 1;
                    LoadList();
                    PauseActions(false);
                    // CLEAR VALUES
                    ID = 0;
                    CustomerId = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";
                    txtAGNo.Text = "Auto";

                    dtDetailGrid = Utilities.CreateDataTable(DetailGridColumns);
                    dgDetail.DataSource = dtDetailGrid;

                    // ENABLE / DISABLE
                    txtSearch.Enabled = true;
                    //cbFilter.Enabled = true;
                    gb.Enabled = false;
                    gbDetail.Enabled = false;
                    dgList.Enabled = true;
                    btnAdd.Enabled = true;
                    btnSave.Enabled = false;
                    btnReset.Enabled = false;
                    btnAdd.Focus();
                    break;
                case "on_add":
                    //LOAD OBJECTS

                    // CLEAR VALUES
                    ID = 0;
                    
                    CustomerId = 0;
                    txtSearch.Text = "";
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtAGNo.Text = "Auto";
                    ////cbFilter.SelectedIndex = 0;

                    //cbStatus.SelectedValue = 1;
                    // ENABLE / DISABLE
                    gb.Enabled = true;
                    gbDetail.Enabled = true;
                    
                    txtSearch.Enabled = false;
                    cbFilter.Enabled = false;
                    dgList.Enabled = false;
                    btnAdd.Enabled = false;
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    break;
                
                case "on_item_selected":
                    txtQty.Enabled = true;
                    txtQty.Focus();
                    break;
                case "on_item_added_in_grid":
                    CustomerId = 0;
                    EditItem = false;
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtQty.Enabled = false;
                    dgDetail.Enabled = true;
                    btnSave.Enabled = true;
                    btnSearch.Focus();
                    break;
                case "on_item_editing":
                    EditItem = true;
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtQty.Enabled = true;
                    dgDetail.Enabled = false;
                    txtQty.Focus();
                    break;
                case "on_reset":
                    PauseActions(true);
                    //LOAD OBJECTS
                    cbFilter.SelectedValue = 1;
                    LoadList();
                    PauseActions(false);
                    // CLEAR VALUES
                    ID = 0;
                   
                    CustomerId = 0;
                    dtDetailGrid = Utilities.CreateDataTable(DetailGridColumns);
                    dgDetail.DataSource = dtDetailGrid;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";
                    //cbFilter.SelectedIndex = 0;
                    txtAGNo.Text = "Auto";
                   
                    //cbStatus.SelectedValue = 0;
                    // ENABLE / DISABLE
                    gb.Enabled = false;
                    gbDetail.Enabled = false;
                    txtSearch.Enabled = true;
                    //cbFilter.Enabled = true;
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
                   
                    CustomerId = 0;
                    dtDetailGrid = Utilities.CreateDataTable(DetailGridColumns);
                    dgDetail.DataSource = dtDetailGrid;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtAGNo.Text = "Auto";
                    // ENABLE / DISABLE
                    gb.Enabled = false;
                    gbDetail.Enabled = false;
                    dgList.Enabled = false;
                    btnAdd.Enabled = false;
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    btnReset.Focus();
                    break;
                case "on_object_loaded":
                    PauseActions(false);
                    gb.Enabled = false;
                    gbDetail.Enabled = true;
                    dgDetail.Enabled = true;
                    txtSearch.Enabled = false;
                    cbFilter.Enabled = false;
                    dgList.Enabled = false;
                    
                    btnAdd.Enabled = false;
                    btnSave.Enabled = true;
                    btnReset.Enabled = true;
                 
                    //cbStatus.Enabled = true;
                    txtQty.Enabled = false;
                    btnReset.Focus();
                   

                    break;
                case "on_save_uncommitted":
                    PauseActions(true);
                    gb.Enabled = false;
                    gbDetail.Enabled = false;
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
            //if (cbFilter.Text.ToLower().Equals("all"))
            //    filter_text += "0 = 0";
            //else 
            //    filter_text += " POStatus = '"+cbFilter.Text+"'";


            if (!string.IsNullOrEmpty(search_value))
            {
                filter_text += "  (";

                filter_text += " Convert(SCNumber,'System.String')  LIKE '%" + search_value + "%'";
                filter_text += " OR Convert(SCDate,'System.String')  LIKE '%" + search_value + "%'";
                filter_text += " OR Convert(TotalAmount,'System.String')  LIKE '%" + search_value + "%'";
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
                ShipmentChargesModel model = new ShipmentChargesModel();
                ShipmentChargesModel.ShipmentCharges obj = new ShipmentChargesModel.ShipmentCharges();
                
                obj.SCId = ID;
                
                obj.SCDate = dtpDate.Value;
                obj.Remarks = txtRemarks.Text;
                obj.Items = dtDetailGrid;
               
                model.Save(obj);

                Utilities.ShowSuccesMessage(this);
                SetFormState("on_reset");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void mnuEditDetail_Click(object sender, EventArgs e)
        {
            SetFormState("on_item_editing");
            CustomerId = Convert.ToInt32(dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["CustomerId"]);
            txtName.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["BillingName"].ToString();
            cbCarrier.SelectedValue = Convert.ToInt32(dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["CarrierId"]);
            txtQty.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Amount"].ToString();
            CalculateTotalAmount();
        }

        private void mnuDeleteDetail_Click(object sender, EventArgs e)
        {
            dtDetailGrid.Rows.RemoveAt(dgDetail.SelectedRows[0].Index);
            CalculateTotalAmount();
        }

        #endregion


        private void dgDetail_MouseDown(object sender, MouseEventArgs e)
        {
            dgDetail.ClearSelection();
            if (e.Button == MouseButtons.Right)
            {
                DataGridView.HitTestInfo hit = dgDetail.HitTest(e.X, e.Y);
                if (hit.Type == DataGridViewHitTestType.Cell)
                {
                    //mstRowIndex = hit.RowIndex;
                    dgDetail.Rows[hit.RowIndex].Selected = true;
                    cmsDetailOptions.Show(dgDetail, new Point(e.X, e.Y));

                }
            }
        }


        private void AddItemInGrid(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                //if (IsItemDuplicate())
                //{
                //    MessageBox.Show("Item already exists.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                //    return;
                //}
                decimal _Amount = string.IsNullOrEmpty(txtQty.Text) ? -1 : Convert.ToDecimal(txtQty.Text);
                if (_Amount < 0 )
                {
                    MessageBox.Show("Invalid Amount.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (EditItem)
                {
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["CarrierId"] = cbCarrier.SelectedValue;

                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["CarrierName"] = cbCarrier.Text;
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Amount"] = _Amount;
                }
                else
                {
                    DataRow dr = dtDetailGrid.NewRow();
                    dr["CustomerId"] = CustomerId;
                    dr["CarrierId"] = cbCarrier.SelectedValue;
                    dr["CarrierName"] = cbCarrier.Text;
                    dr["BillingName"] = txtName.Text;
                    dr["Amount"] = _Amount;
                    dtDetailGrid.Rows.Add(dr);
                }
                SetFormState("on_item_added_in_grid");
                CalculateTotalAmount();
            }
        }



        private void btnSearchCustomer_Click(object sender, EventArgs e)
        {
            try
            {
                fSearch oSearch = new fSearch();
                oSearch.Left = this.Left + AppStandards.CustomerSearchleftMargin;
                oSearch.Top = this.Top + AppStandards.CustomerSearchTopMargin;
                oSearch.SearchType = fSearch.SearchFor.Customer;
                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    CustomerId = Convert.ToInt32(result["CustomerId"]);
                    txtName.Text = result["BillingName"].ToString();
                    SetFormState("on_item_selected");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnSearchItem_Click(object sender, EventArgs e)
        {
            try
            {
                fSearch oSearch = new fSearch();
                oSearch.Left = this.Left + AppStandards.ItemSearchleftMargin;
                oSearch.Top = this.Top + AppStandards.ItemSearchTopMargin;
               
                    oSearch.SearchType = fSearch.SearchFor.Customer;
                
                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    CustomerId = Convert.ToInt32(result["CustomerId"]);
                    txtName.Text = result["BillingName"].ToString();
                    SetFormState("on_item_selected");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void AutoCalculateItemAmount(object sender, EventArgs e)
        {
            
        }

        void CalculateTotalAmount()
        {
            decimal _grandTotalAmount = 0;

            txtTotalAmount.Text = "0";
            for (int i = 0; i < dtDetailGrid.Rows.Count; i++)
            {
                _grandTotalAmount += Convert.ToDecimal(dtDetailGrid.Rows[i]["Amount"]);
            }
            txtTotalAmount.Text = _grandTotalAmount.ToString();
        }

        void Print()
        {
            long tmpID = Convert.ToInt32(dgList.Rows[dgList.SelectedRows[0].Index].Cells["cListId"].Value);
            CompanyModel modelCompany = new CompanyModel();
            DataTable dtCompany = ((DataSet)modelCompany.Get()).Tables[0].Copy();
            dtCompany.Rows[0]["LogoPath"] = "file:/" + Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dtCompany.Rows[0]["LogoPath"].ToString()).Replace(@"\", "/");
            ShipmentChargesModel model1 = new ShipmentChargesModel();
            DataSet ds = ((DataSet)model1.GetById(tmpID));
            DataTable dtMaster = ds.Tables[0].Copy();
            DataTable dtDetail = ds.Tables[1].Copy();
            DataTable dtData = DataHelper.MergeDataTable(dtMaster, dtDetail);

            dtCompany.TableName = "Company";
            dtData.TableName = "ShipmentCharges";

            DataSet dsReport = new DataSet();
            dsReport.Tables.Add(dtCompany);
            dsReport.Tables.Add(dtData);

            fReportViewer frm = new fReportViewer();
            frm.dsReport = dsReport;
            frm.ReportPath = Path.Combine(AppData.IsLive ? AppDomain.CurrentDomain.BaseDirectory : Directory.GetParent(Directory.GetCurrentDirectory()).Parent.FullName, "4-Reports", "4-Sale", "rptShipmentCharges.rdlc");
            frm.HeaderText = "Shipment Charges";
            frm.MdiParent = this.MdiParent;
            frm.Show();
        }

        private void printToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Print();
        }

   
        private bool IsItemDuplicate()
        {
            if (dtDetailGrid.Rows.Count == 0)
                return false;

            if (EditItem)
            {
                int index = dgDetail.SelectedRows[0].Index;
                DataTable dttmp = dtDetailGrid.Copy();
                dttmp.Rows.RemoveAt(index);
                if (dttmp.Select("CustomerId =" + CustomerId).Length > 0)
                    return true;
            }
            else
            {
                if (dtDetailGrid.Select("CustomerId =" + CustomerId).Length > 0)
                    return true;
            }
            return false;
        }
    }
}
