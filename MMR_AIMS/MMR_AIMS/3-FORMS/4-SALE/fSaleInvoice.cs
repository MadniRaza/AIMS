using System;
using System.CodeDom;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Linq;
using System.Net.Sockets;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fSaleInvoice : Form
    {
        #region Data Fields
        long ID = 0;
        int CustomerId = 0;
        int ItemId = 0;
        bool EditItem = false;
        decimal StockQty = 0;
        
        string DetailGridColumns = "ItemId,ItemName,Qty,SellPrice,Tax,Discount,Amount";
        DataTable dtDetailGrid;

        #endregion
        public fSaleInvoice()
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
                //SaleInvoiceModel model = new SaleInvoiceModel();
                //DataTable dtTaxTypes = ((DataSet)model.GetSaleOrderStatuses()).Tables[0];
                //Utilities.PrepareOptionList(dtTaxTypes.Copy(), "SOStatus", "SOStatusId", ref cbStatus, false);
                //Utilities.PrepareOptionList(dtTaxTypes.Copy(), "SOStatus", "SOStatusId", ref cbFilter, true, "All");

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
                SaleInvoiceModel model = new SaleInvoiceModel();
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
                SaleInvoiceModel model = new SaleInvoiceModel();
                DataSet ds = ((DataSet)model.GetById(ID));
                DataTable dtMaster = ds.Tables[0];
                DataTable dtDetail = ds.Tables[1];
                CustomerId = Convert.ToInt32(dtMaster.Rows[0]["CustomerId"]);
                txtAGNo.Text= dtMaster.Rows[0]["SaleInvoiceNumber"].ToString();
                //txtSONo.Text = dtMaster.Rows[0]["SONumber"].ToString();
                txtCustomer.Text = dtMaster.Rows[0]["BillingName"].ToString();
                //cbStatus.SelectedValue = Convert.ToInt32(dtMaster.Rows[0]["SOStatusId"]);
                txtTotalAmount.Text= dtMaster.Rows[0]["TotalAmount"].ToString();
                dtpDate.Value =Convert.ToDateTime(dtMaster.Rows[0]["SaleInvoiceDate"]);
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
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtCustomer.Text.Trim())))
                sb.AppendLine("Please select Customer.");
            if(dtDetailGrid.Rows.Count == 0)
                sb.AppendLine("at least one item is required.");
            decimal _Amount = string.IsNullOrEmpty(txtTotalAmount.Text) ? 0 : Convert.ToDecimal(txtTotalAmount.Text);
            decimal additional_discount = string.IsNullOrEmpty(txtAdditionalDisc.Text) ? 0 : Convert.ToDecimal(txtAdditionalDisc.Text);
            if (additional_discount > _Amount)
                sb.AppendLine("Total Amount can not be negative.");
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
                    StockQty = 0;
                    
                    ItemId = 0;
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
                    dgDetail.AutoGenerateColumns = false;
                    dgDetail.DataSource = dtDetailGrid;
                    
                    // ENABLE / DISABLE
                    txtSearch.Enabled = true;
                    cbFilter.Enabled = true;
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
                    StockQty = 0;
                    
                    ItemId = 0;
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
                    // cbFilter.SelectedIndex = 0;

                    
                    // ENABLE / DISABLE
                    gb.Enabled = true;
                    
                    txtSearch.Enabled = false;
                    cbFilter.Enabled = false;
                    dgList.Enabled = false;
                    btnAdd.Enabled = false;
                    btnSave.Enabled = false;
                    btnReset.Enabled = true;
                    
                    break;
                case "on_vendor_selected":
                    gbDetail.Enabled = true;
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtQty.Enabled = txtPrice.Enabled = txtDiscount.Enabled = txtTaxPer.Enabled = false;
                    btnSearchItem.Focus();
                    break;
                case "on_item_selected":
                    txtQty.Enabled = txtPrice.Enabled = txtDiscount.Enabled = txtTaxPer.Enabled = true;
                    txtTaxPer.Enabled = false;
                    txtQty.Focus();
                    break;
                case "on_item_added_in_grid":
                    ItemId = 0;
                    EditItem = false;
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtQty.Enabled = txtPrice.Enabled = txtDiscount.Enabled = txtTaxPer.Enabled = false;
                    dgDetail.Enabled = true;
                    btnSave.Enabled = true;
                    btnSearchItem.Focus();
                    break;
                case "on_item_editing":
                    EditItem = true;
                    foreach (TextBox txt in gbDetail.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtQty.Enabled = txtPrice.Enabled = txtDiscount.Enabled = txtTaxPer.Enabled = true;
                    dgDetail.Enabled = false;
                    txtQty.Focus();
                    break;
                case "on_reset":
                    PauseActions(true);
                    //LOAD OBJECTS
                    //cbFilter.SelectedValue = 1;
                    LoadList();
                    PauseActions(false);
                    // CLEAR VALUES
                    ID = 0;
                    StockQty = 0;
                    
                    ItemId = 0;
                    CustomerId = 0;
                    CustomerId = 0;
                    dtDetailGrid = Utilities.CreateDataTable(DetailGridColumns);
                    dgDetail.AutoGenerateColumns = false;
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
                    // cbFilter.SelectedIndex = 0;
                    txtAGNo.Text = "Auto";
                    
                    // ENABLE / DISABLE
                    gb.Enabled = false;
                    
                    gbDetail.Enabled = false;
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
                    StockQty = 0;
                    ItemId = 0;
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
                    
                    
                    txtQty.Enabled = txtPrice.Enabled = txtDiscount.Enabled = txtTaxPer.Enabled = false;
                    btnReset.Focus();
                    //if (Convert.ToInt32(cbStatus.SelectedValue) >1)
                    //{ cbStatus.Enabled = false;
                    //    gbDetail.Enabled = false;
                    //    gb.Enabled = false;
                    //    btnReset.Focus();
                    //    btnSave.Enabled = false;
                    //}
                    //else 
                    //{

                    //}
                    
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
            //    filter_text += " SOStatus = '"+cbFilter.Text+"'";


            if (!string.IsNullOrEmpty(search_value))
            {
                filter_text += "  (";
                filter_text += " Convert(SaleInvoiceNumber,'System.String')  LIKE '%" + search_value + "%'";
                filter_text += "  OR Convert(BillingName,'System.String')  LIKE '%" + search_value + "%'";
                filter_text += " OR Convert(TotalAmount,'System.String')  LIKE '%" + search_value + "%'";
                filter_text += " OR Convert(SaleInvoiceDate,'System.String')  LIKE '%" + search_value + "%'";
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
        private void cbStatus_SelectionChangeCommitted(object sender, EventArgs e)
        {
            //try
            //{
            //    SetFormState("on_save_uncommitted");
            //    SaleInvoiceModel model = new SaleInvoiceModel();

            //    model.UpdateSaleOrderStatus(ID, Convert.ToInt32(cbStatus.SelectedValue));

            //    Utilities.ShowSuccesMessage(this);
            //    SetFormState("on_reset");
            //}
            //catch (Exception ex)
            //{
            //    MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            //}
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
                SaleInvoiceModel model = new SaleInvoiceModel();
                SaleInvoiceModel.SaleInvoice obj = new SaleInvoiceModel.SaleInvoice();
                
                obj.SaleInvoiceId = ID;
                
                obj.AdditionalDiscount = string.IsNullOrEmpty(txtAdditionalDisc.Text) ? 0 : Convert.ToDecimal(txtAdditionalDisc.Text);
                //obj.SOStatusId =Convert.ToInt32(cbStatus.SelectedValue);
                obj.SaleInvoiceDate = dtpDate.Value;
                obj.CustomerId = CustomerId;
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
            ItemId = Convert.ToInt32(dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["ItemId"]);
            txtItemName.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["ItemName"].ToString();
            txtQty.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Qty"].ToString();
            txtPrice.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["SellPrice"].ToString();
            //txtTaxPer.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["TaxPer"].ToString();
            txtDiscount.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Discount"].ToString();
            txtItemTotal.Text = dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Amount"].ToString();
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
                if (IsItemDuplicate())
                {
                    MessageBox.Show("Item already exists.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                decimal Amount = string.IsNullOrEmpty(txtItemTotal.Text) ? -1 : Convert.ToDecimal(txtItemTotal.Text);
                int Qty = string.IsNullOrEmpty(txtQty.Text) ? -1 : Convert.ToInt32(txtQty.Text);
                decimal _Discount = string.IsNullOrEmpty(txtDiscount.Text) ? 0 : Convert.ToDecimal(txtDiscount.Text);
                decimal _price = string.IsNullOrEmpty(txtPrice.Text) ? 0 : Convert.ToDecimal(txtPrice.Text);
                decimal _TaxPer = string.IsNullOrEmpty(txtTaxPer.Text) ? 0 : Convert.ToDecimal(txtTaxPer.Text);
                decimal _Tax = _price * _TaxPer / 100;
                if (Qty > StockQty  && ID == 0)
                {
                    MessageBox.Show("You are adding out of Stock Qty.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                if (Amount < 0 || Qty <= 0)
                {
                    MessageBox.Show("Invalid Amount.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                
                if (EditItem)
                {
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["ItemId"] = ItemId;
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Qty"] = txtQty.Text;
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["SellPrice"] =_price;
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Discount"] = _Discount;
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Tax"] = _Tax;
                    dtDetailGrid.Rows[dgDetail.SelectedRows[0].Index]["Amount"] = txtItemTotal.Text;
                }
                
                else
                {
                    DataRow dr = dtDetailGrid.NewRow();
                    dr["ItemId"] = ItemId;
                    dr["ItemName"] = txtItemName.Text;
                    dr["Qty"] = txtQty.Text;
                    dr["SellPrice"] = _price;
                    dr["Discount"] =_Discount;
                    dr["Tax"] = _Tax;
                    dr["Amount"] = txtItemTotal.Text;
                    dtDetailGrid.Rows.Add(dr);
                }
                SetFormState("on_item_added_in_grid");
                CalculateTotalAmount();
            }
        }



        private void btnSearchVendor_Click(object sender, EventArgs e)
        {
           
        }

        private void btnSearchItem_Click(object sender, EventArgs e)
        {
            try
            {
                fSearch oSearch = new fSearch();
                oSearch.Left = this.Left + AppStandards.ItemSearchleftMargin;
                oSearch.Top = this.Top + AppStandards.ItemSearchTopMargin;
                oSearch.SearchType = fSearch.SearchFor.Item;
                
                DialogResult dr = oSearch.ShowDialog();
                if (dr == DialogResult.OK)
                {
                    Dictionary<string, object> result = oSearch.GetData();
                    ItemId = Convert.ToInt32(result["ItemId"]);
                    txtPrice.Text = result["SellPrice"].ToString();
                    txtItemName.Text = result["ItemName"].ToString();
                    txtTaxPer.Text = result["TaxPercentage"].ToString();
                    StockQty = Convert.ToInt32(result["StockQty"]);
                    
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
            int Qty = string.IsNullOrEmpty(txtQty.Text) ? 0 : Convert.ToInt32(txtQty.Text);
            decimal Price = string.IsNullOrEmpty(txtPrice.Text) ? 0 : Convert.ToDecimal(txtPrice.Text);
            decimal Taxper = string.IsNullOrEmpty(txtTaxPer.Text) ? 0 : Convert.ToDecimal(txtTaxPer.Text);
            decimal Disc = string.IsNullOrEmpty(txtDiscount.Text) ? 0 : Convert.ToDecimal(txtDiscount.Text);

            decimal Tax = Price * Taxper / 100;

            decimal Amount = Qty * (Price - Disc + Tax);
            txtItemTotal.Text = Amount.ToString();
        }

        void CalculateTotalAmount()
        {
            decimal _grandTotalAmount = 0;
            decimal _additionalDiscount = string.IsNullOrEmpty(txtAdditionalDisc.Text) ? 0 : Convert.ToDecimal(txtAdditionalDisc.Text);
            txtTotalAmount.Text = "0";
            for (int i = 0; i < dtDetailGrid.Rows.Count; i++)
            {

                _grandTotalAmount += Convert.ToDecimal(dtDetailGrid.Rows[i]["Amount"]);
            }

            _grandTotalAmount -= _additionalDiscount;
            txtTotalAmount.Text = _grandTotalAmount.ToString();
        }

      
        void Print()
        {
            long tmpID = Convert.ToInt32(dgList.Rows[dgList.SelectedRows[0].Index].Cells["cListId"].Value);
            CompanyModel modelCompany = new CompanyModel();
            DataTable dtCompany = ((DataSet)modelCompany.Get()).Tables[0].Copy();
            dtCompany.Rows[0]["LogoPath"] = "file:/" + Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dtCompany.Rows[0]["LogoPath"].ToString()).Replace(@"\", "/");
            SaleInvoiceModel model1 = new SaleInvoiceModel();
            DataSet ds = ((DataSet)model1.GetById(tmpID));
            DataTable dtMaster = ds.Tables[0].Copy();
            DataTable dtDetail = ds.Tables[1].Copy();
            DataTable dtData = DataHelper.MergeDataTable(dtMaster, dtDetail);


            CustomerModel model2 = new CustomerModel();
            DataTable dtVendor = ((DataSet)model2.GetById(Convert.ToInt32(dtMaster.Rows[0]["CustomerId"]))).Tables[0].Copy();
            DataTable dtBalance = ((DataSet)model2.GetCustomerBalance(Convert.ToInt32(dtMaster.Rows[0]["CustomerId"]),Convert.ToDateTime(dtMaster.Rows[0]["SaleInvoiceDate"]))).Tables[0].Copy();
            dtBalance.Rows[0]["GrossAmount"] = dtMaster.Rows[0]["TotalAmount"];
            dtBalance.Rows[0]["NetBalance"] = Convert.ToDecimal(dtBalance.Rows[0]["PreviousBalance"]) + Convert.ToDecimal(dtBalance.Rows[0]["GrossAmount"]);
            
            dtBalance.TableName = "Balance";
            dtCompany.TableName = "Company";
            dtData.TableName = "SaleInvoice";
            dtVendor.TableName = "Customer";

            DataSet dsReport = new DataSet();
            dsReport.Tables.Add(dtCompany);
            dsReport.Tables.Add(dtData);
            dsReport.Tables.Add(dtVendor);
            dsReport.Tables.Add(dtBalance);
            fReportViewer frm = new fReportViewer();
            frm.dsReport = dsReport;
            frm.ReportPath = Path.Combine(AppData.IsLive ? AppDomain.CurrentDomain.BaseDirectory : Directory.GetParent(Directory.GetCurrentDirectory()).Parent.FullName, "4-Reports", "4-Sale", "rptSaleInvoice.rdlc");
            frm.HeaderText = "Sale Invoice";
            frm.MdiParent = this.MdiParent;
            frm.Show();
        }

        private void mnuPrint_Click(object sender, EventArgs e)
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
                if (dttmp.Select("ItemId =" + ItemId).Length > 0)
                    return true;
            }
            else
            {
                if (dtDetailGrid.Select("ItemId =" + ItemId).Length > 0)
                    return true;
            }
            return false;
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
                    txtCustomer.Text = result["BillingName"].ToString();
                    SetFormState("on_vendor_selected");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}

