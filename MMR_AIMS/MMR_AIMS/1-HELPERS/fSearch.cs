using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Printing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fSearch : Form
    {
        #region Data Fields
        public SearchFor SearchType { get; set; }
        public int CustomerId { get; set; }
        public int VendorId { get; set; }
        public int RowIndex { get; set; }

        #endregion
        public fSearch()
        {
            InitializeComponent();
        }
        public enum SearchFor
        {
            Item = 1,
            Vendor = 2,
            Customer = 3,
            PurchaseReturnableItem = 4,
            SaleReturnableItem = 5,
            StockItem = 6,
            JVCOA = 7,
            GLCOA = 8,
            Category  = 9
        }
        #region "Form Helpers"
        private void frm_load(object sender, EventArgs e)
        {
            SetFormState("on_load");
        }
        private void frm_Move(object sender, EventArgs e)
        {
            //if (this.Left <= 10)
            //{
            //    this.Left = 10;
            //}
            //else if (this.Left >= (this.MdiParent.ClientRectangle.Width - 10) - this.Width)
            //{
            //    this.Left = (this.MdiParent.ClientRectangle.Width - 10) - this.Width;
            //}
            //if (this.Top < 0)
            //{
            //    this.Top = 0;
            //}
            //else if (this.Top >= 20)
            //{
            //    this.Top = 20;
            //}
        }
        void LoadInitialData()
        {
            try
            {
                switch (SearchType)
                {
                    case SearchFor.Item:
                        lblSearch.Text = "Search Item:";
                        break;
                    case SearchFor.Vendor:
                        lblSearch.Text = "Search Vendor:";
                        break;
                    case SearchFor.Customer:
                        lblSearch.Text = "Search Customer:";
                        break;
                    case SearchFor.StockItem:
                        lblSearch.Text = "Search Item:";
                        break;
                    case SearchFor.PurchaseReturnableItem:
                        lblSearch.Text = "Search Item:";
                        break;
                    case SearchFor.SaleReturnableItem:
                        lblSearch.Text = "Search Item:";
                        break;
                    case SearchFor.GLCOA:
                        lblSearch.Text = "Search Account:";
                        break;
                    case SearchFor.JVCOA:
                        lblSearch.Text = "Search Account:";
                        break;
                    case SearchFor.Category:
                        lblSearch.Text = "Search Category:";
                        break;

                }


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
                switch (SearchType)
                {
                   
                    case SearchFor.Vendor:
                        VendorModel vModel = new VendorModel();
                        DataTable dtVendors = ((DataSet)vModel.GetVendors()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "VendorId", 80, 0, "Vendor #",DataGridViewContentAlignment.MiddleLeft,false));
                        dgList.Columns.Add(GetGridColumn("cName", "BillingName", 200, 1, "Vendor"));
                        dgList.Columns.Add(GetGridColumn("cAddress", "BillingAddress1", 200, 2, "Address"));
                        dgList.Columns.Add(GetGridColumn("cPhoneNo", "PhoneNo", 80, 3, "Phone"));
                        dgList.DataSource = dtVendors;
                        break;
                    case SearchFor.Customer:
                        CustomerModel cModel = new CustomerModel();
                        DataTable dtCustomer = ((DataSet)cModel.GetCustomers()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "CustomerId", 80, 0, "Customer #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cName", "BillingName", 200, 1, "Customer"));
                        dgList.Columns.Add(GetGridColumn("cAddress", "BillingAddress1", 200, 2, "Address"));
                        dgList.Columns.Add(GetGridColumn("cPhoneNo", "PhoneNo", 80, 3, "Phone"));
                        dgList.DataSource = dtCustomer;
                        break;
                    case SearchFor.Item:
                        ItemModel model1 = new ItemModel();
                        DataTable dt1 = ((DataSet)model1.GetItems()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "ItemId", 80, 0, "Item #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cItemName", "ItemName", 120, 1, "Item"));
                        dgList.Columns.Add(GetGridColumn("cCategory", "Category", 200, 2, "Category"));
                        dgList.Columns.Add(GetGridColumn("cCostPrice", "CostPrice", 70, 3, "Cost Price", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cSellPrice", "SellPrice", 70, 4, "Sell Price", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cStockQty", "StockQty", 60, 5, "Stock Qty", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cTaxPer", "TaxPercentage", 40, 6, "Tax %", DataGridViewContentAlignment.MiddleRight,false));

                        dgList.DataSource = dt1;
                        break;
                    case SearchFor.Category:
                        CategoryModel modelc = new CategoryModel();
                        DataTable dtc = ((DataSet)modelc.GetCategoryTree()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "CategoryId", 80, 0, "Item #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cCategoryName", "CategoryName", 480, 1, "Category"));
                        dgList.DataSource = dtc;
                        break;
                    case SearchFor.PurchaseReturnableItem:
                        PurchaseReturnModel aa = new PurchaseReturnModel();
                        DataTable dt = ((DataSet)aa.GetPurchaseReturnableItems(VendorId)).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "ItemId", 80, 0, "Item #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cItemName", "ItemName", 120, 1, "Item"));
                        dgList.Columns.Add(GetGridColumn("cCategory", "Category", 200, 2, "Category"));
                        dgList.Columns.Add(GetGridColumn("cCostPrice", "CostPrice", 70, 3, "Cost Price", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cReturnableQty", "ReturnableQty", 100, 4, "Returnable Qty", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cTaxPer", "TaxPercentage", 40, 5, "Tax%", DataGridViewContentAlignment.MiddleRight));
                        dgList.DataSource = dt;
                        break;
                    case SearchFor.SaleReturnableItem:
                        SaleReturnModel aa1 = new SaleReturnModel();
                        DataTable daft = ((DataSet)aa1.GetSaleReturnableItems(CustomerId)).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "ItemId", 80, 0, "Item #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cItemName", "ItemName", 120, 1, "Item"));
                        dgList.Columns.Add(GetGridColumn("cCategory", "Category", 200, 2, "Category"));
                        dgList.Columns.Add(GetGridColumn("cSellPrice", "SellPrice", 70, 3, "Sell Price", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cReturnableQty", "ReturnableQty", 100, 4, "Returnable Qty", DataGridViewContentAlignment.MiddleRight));
                        dgList.Columns.Add(GetGridColumn("cTaxPer", "TaxPercentage", 40, 5, "Tax%", DataGridViewContentAlignment.MiddleRight));
                        dgList.DataSource = daft;
                        break;
                    case SearchFor.StockItem:
                        ItemModel g = new ItemModel();
                        DataTable aaaa = ((DataSet)g.GetItems()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "ItemId", 80, 0, "Item #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cItemName", "ItemName", 120, 1, "Item"));
                        dgList.Columns.Add(GetGridColumn("cCategory", "Category", 200, 2, "Category"));
                        dgList.Columns.Add(GetGridColumn("cStockQty", "StockQty", 100, 3, "Stock Qty", DataGridViewContentAlignment.MiddleRight));
                        dgList.DataSource = aaaa;
                        break;
                    case SearchFor.JVCOA:
                        COAModel aaaaa = new COAModel();
                        DataTable a3 = ((DataSet)aaaaa.GetJVAccounts()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "COAId", 80, 0, "Item #",DataGridViewContentAlignment.MiddleLeft,false));
                        dgList.Columns.Add(GetGridColumn("cCOAName", "COAName", 200, 1, "Account"));
                        dgList.Columns.Add(GetGridColumn("cCOACode", "COACode", 100, 1, "Code"));
                        dgList.Columns.Add(GetGridColumn("cCOAType", "COAType", 100, 1, "Type"));
                        dgList.DataSource = a3;
                        break;
                    case SearchFor.GLCOA:
                        COAModel hh = new COAModel();
                        DataTable ggg = ((DataSet)hh.GetGLAccounts()).Tables[0];
                        dgList.AutoGenerateColumns = false;
                        dgList.Columns.Add(GetGridColumn("cListId", "COAId", 80, 0, "Item #", DataGridViewContentAlignment.MiddleLeft, false));
                        dgList.Columns.Add(GetGridColumn("cCOAName", "COAName", 200, 1, "Account"));
                        dgList.Columns.Add(GetGridColumn("cCOACode", "COACode", 100, 1, "Code"));
                        dgList.Columns.Add(GetGridColumn("cCOAType", "COAType", 100, 1, "Type"));
                        dgList.DataSource = ggg;
                        break;
                    default:
                        break;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            FilterRecords();
        }


        public void SetFormState(string action)
        {
            switch (action.ToLower())
            {
                case "on_load":
                    PauseActions(true);
                    LoadInitialData();
                    //LOAD OBJECTS
                    LoadList();
                    PauseActions(false);
                    // CLEAR VALUES
                    txtSearch.Text = "";
                    // ENABLE / DISABLE

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
                switch (SearchType)
                {
                    case SearchFor.Item:
                        // filter_text += "Convert(ItemId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += "  ItemName LIKE '%" + search_value + "%' ";
                        filter_text += " OR Category LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(CostPrice,'System.String') LIKE '%" + search_value + "%' ";
                        // filter_text += " OR Convert(AvgCostPrice,'System.String') LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.Category:
                        filter_text += "  CategoryName LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.Vendor:
                        filter_text += "Convert(VendorId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR BillingName LIKE '%" + search_value + "%' ";
                        filter_text += " OR BillingAddress1 LIKE '%" + search_value + "%' ";
                        filter_text += " OR PhoneNo LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.Customer:
                        filter_text += "Convert(CustomerId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR BillingName LIKE '%" + search_value + "%' ";
                        filter_text += " OR BillingAddress1 LIKE '%" + search_value + "%' ";
                        filter_text += " OR PhoneNo LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.PurchaseReturnableItem:
                        filter_text += "Convert(ItemId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR ItemName LIKE '%" + search_value + "%' ";
                        filter_text += " OR Category LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(CostPrice,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(ReturnableQty,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(StockQty,'System.String') LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.SaleReturnableItem:
                      //  filter_text += "Convert(ItemId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += "  ItemName LIKE '%" + search_value + "%' ";
                        filter_text += " OR Category LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(SellPrice,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(ReturnableQty,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(StockQty,'System.String') LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.StockItem:
                    //    filter_text += "Convert(ItemId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += "  ItemName LIKE '%" + search_value + "%' ";
                        filter_text += " OR Category LIKE '%" + search_value + "%' ";
                        filter_text += " OR Convert(StockQty,'System.String') LIKE '%" + search_value + "%' ";
                        break;
                    case SearchFor.JVCOA:
                        filter_text += "Convert(COAId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR COAName LIKE '%" + search_value + "%' ";
                        filter_text += " OR COACode LIKE '%" + search_value + "%' ";
                        filter_text += " OR COAType LIKE '%" + search_value + "%' ";
                        
                        break;
                    case SearchFor.GLCOA:
                        filter_text += "Convert(COAId,'System.String') LIKE '%" + search_value + "%' ";
                        filter_text += " OR COAName LIKE '%" + search_value + "%' ";
                        filter_text += " OR COACode LIKE '%" + search_value + "%' ";
                        filter_text += " OR COAType LIKE '%" + search_value + "%' ";

                        break;


                }
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


        private void btnReset_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
        }

        DataGridViewColumn GetGridColumn(string _columnName, string _dataPropertyName, int _width, int _index, string _text,DataGridViewContentAlignment alignment = DataGridViewContentAlignment.MiddleLeft, bool _visible = true)
        {
            DataGridViewColumn column = new DataGridViewColumn();
            column.DisplayIndex = _index;
            column.Name = _columnName;
            column.CellTemplate = new DataGridViewTextBoxCell();
            column.Width = _width;
            column.DataPropertyName = _dataPropertyName;
            column.HeaderText = _text;
            column.SortMode = DataGridViewColumnSortMode.Automatic;
            column.ReadOnly = true;
            column.Visible = _visible;
            column.DefaultCellStyle.Alignment = alignment;
            return column;
        }

        #endregion

        private void btnSave_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
        }

        private void pnlMain_Paint(object sender, PaintEventArgs e)
        {

        }



        private void dgList_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex == -1)
                return;
            RowIndex = e.RowIndex;
            this.DialogResult = DialogResult.OK;
        }

        private void dgList_KeyDown(object sender, KeyEventArgs e)
        {
            //if (e.KeyData == Keys.Enter)
            //{

            //    this.DialogResult = DialogResult.OK;
            //}
        }


        public Dictionary<string, object> GetData()
        {
            Dictionary<string, object> keyValues = new Dictionary<string, object>();
            switch (SearchType)
            {
                case SearchFor.Item:
                    keyValues["ItemId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["ItemName"] = dgList.Rows[RowIndex].Cells["cItemName"].Value;
                    keyValues["CostPrice"] = dgList.Rows[RowIndex].Cells["cCostPrice"].Value;
                    keyValues["SellPrice"] = dgList.Rows[RowIndex].Cells["cSellPrice"].Value;
                    keyValues["StockQty"] = dgList.Rows[RowIndex].Cells["cStockQty"].Value;
                    keyValues["TaxPercentage"] = dgList.Rows[RowIndex].Cells["cTaxPer"].Value;
                    break;
                case SearchFor.Vendor:
                    keyValues["VendorId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["BillingName"] = dgList.Rows[RowIndex].Cells["cName"].Value;
                    break;
                case SearchFor.Customer:
                    keyValues["CustomerId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["BillingName"] = dgList.Rows[RowIndex].Cells["cName"].Value;
                    break;
                case SearchFor.PurchaseReturnableItem:
                    keyValues["ItemId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["ItemName"] = dgList.Rows[RowIndex].Cells["cItemName"].Value;
                    keyValues["CostPrice"] = dgList.Rows[RowIndex].Cells["cCostPrice"].Value;
                    keyValues["ReturnableQty"] = dgList.Rows[RowIndex].Cells["cReturnableQty"].Value;
                    keyValues["TaxPercentage"] = dgList.Rows[RowIndex].Cells["cTaxPer"].Value;
                    break;
                case SearchFor.SaleReturnableItem:
                    keyValues["ItemId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["ItemName"] = dgList.Rows[RowIndex].Cells["cItemName"].Value;
                    keyValues["SellPrice"] = dgList.Rows[RowIndex].Cells["cSellPrice"].Value;
                    keyValues["ReturnableQty"] = dgList.Rows[RowIndex].Cells["cReturnableQty"].Value;
                    keyValues["TaxPercentage"] = dgList.Rows[RowIndex].Cells["cTaxPer"].Value;
                    break;
                case SearchFor.StockItem:
                    keyValues["ItemId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["ItemName"] = dgList.Rows[RowIndex].Cells["cItemName"].Value;
                    keyValues["StockQty"] = dgList.Rows[RowIndex].Cells["cStockQty"].Value;
                    break;
                case SearchFor.JVCOA:
                    keyValues["COAId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["COAType"] = dgList.Rows[RowIndex].Cells["cCOAType"].Value;
                    keyValues["COACode"] = dgList.Rows[RowIndex].Cells["cCOACode"].Value;
                    keyValues["COAName"] = dgList.Rows[RowIndex].Cells["cCOAName"].Value;
                    break;
                case SearchFor.GLCOA:
                    keyValues["COAId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["COAType"] = dgList.Rows[RowIndex].Cells["cCOAType"].Value;
                    keyValues["COACode"] = dgList.Rows[RowIndex].Cells["cCOACode"].Value;
                    keyValues["COAName"] = dgList.Rows[RowIndex].Cells["cCOAName"].Value;
                    break;
                case SearchFor.Category:
                    keyValues["CategoryId"] = dgList.Rows[RowIndex].Cells["cListId"].Value;
                    keyValues["CategoryName"] = dgList.Rows[RowIndex].Cells["cCategoryName"].Value;
                    break;
                default:
                    break;
            }

            return keyValues;

        }
    }
}
