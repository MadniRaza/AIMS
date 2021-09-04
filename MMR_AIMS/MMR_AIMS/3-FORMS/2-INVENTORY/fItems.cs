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
    public partial class fItems : Form
    {
        #region Data Fields
        int ItemId = 0;
        int CategoryId = 0;
        #endregion
        public fItems()
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
                TaxTypeModel modelTaxType = new TaxTypeModel();
                DataTable dtTaxTypes = ((DataSet)modelTaxType.GetTaxTypes()).Tables[0];
                Utilities.PrepareOptionList(dtTaxTypes, "TaxTypeName", "TaxTypeId", ref cbTaxTypes);


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
                ItemModel modelItem = new ItemModel();
                DataTable dtitems = ((DataSet)modelItem.GetList()).Tables[0];
                dgList.AutoGenerateColumns = false;
                dgList.DataSource = dtitems;

                CategoryModel model1 = new CategoryModel();
                DataTable dt1 = ((DataSet)model1.GetCategories()).Tables[0];

                dt1.DefaultView.RowFilter = "ParentId = 0 ";
                DataTable dtParents = dt1.DefaultView.ToTable();

                tvCategories.Nodes.Clear();
                for (int i = 0; i < dtParents.Rows.Count; i++)
                {
                    TreeNode tn = new TreeNode();
                    tn.Name = dtParents.Rows[i]["CategoryId"].ToString();
                    tn.Text = dtParents.Rows[i]["CategoryName"].ToString();
                    tvCategories.Nodes.Add(tn);
                    LoadCateogoryChilds(Convert.ToInt32(dtParents.Rows[i]["CategoryId"]), tn, dt1);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        public void LoadCateogoryChilds(int _parentId, TreeNode tn, DataTable dt)
        {
            dt.DefaultView.RowFilter = "ParentId = " + _parentId;
            DataTable dtTemp = dt.DefaultView.ToTable();
            for (int i = 0; i < dtTemp.Rows.Count; i++)
            {
                TreeNode tnC = new TreeNode();
                tnC.Name = dtTemp.Rows[i]["CategoryId"].ToString();
                tnC.Text = dtTemp.Rows[i]["CategoryName"].ToString();
                tn.Nodes.Add(tnC);
                LoadCateogoryChilds(Convert.ToInt32(dtTemp.Rows[i]["CategoryId"]), tnC, dt);
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
                ItemId = Convert.ToInt32(dgList.Rows[dgList.SelectedRows[0].Index].Cells["cListId"].Value);
                ItemModel modelItem = new ItemModel();
                DataTable dt = ((DataSet)modelItem.Get(ItemId)).Tables[0];
                txtItemNo.Text = dt.Rows[0]["ItemId"].ToString();
                txtName.Text = dt.Rows[0]["ItemName"].ToString();

                txtCP.Text = dt.Rows[0]["CostPrice"].ToString();
                txtSP.Text = dt.Rows[0]["SellPrice"].ToString();
                cbTaxTypes.SelectedValue = dt.Rows[0]["TaxTypeId"];
                chkActive.Checked = Convert.ToBoolean(dt.Rows[0]["Active"]);
                if (!string.IsNullOrEmpty(dt.Rows[0]["ImagePath"].ToString()))
                {
                    pbLogo.ImageLocation = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dt.Rows[0]["ImagePath"].ToString()).Replace(@"\", "/");
                }
                else
                    pbLogo.Image = MMR_AIMS.Properties.Resources.no_image;
                CheckNode(tvCategories.Nodes, dt.Rows[0]["CategoryId"].ToString());
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
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtName.Text.Trim())))
                sb.AppendLine("Please enter Item Name.");

            if (string.IsNullOrEmpty(Utilities.ValidateText(txtCP.Text.Trim())))
                sb.AppendLine("Please enter Cost Price.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtSP.Text.Trim())))
                sb.AppendLine("Please enter Sell Price.");

            int a = 0;
            int b = 0;
            CategoryId = GetSelectedNode(tvCategories.Nodes,ref a,ref b);
            if (CategoryId == -1 || CategoryId == 0)
                sb.AppendLine("Multiple Categories not allowed.");
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
                    ItemId = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";
                    txtItemNo.Text = "Auto";
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
                    ItemId = 0;
                    txtSearch.Text = "";
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtItemNo.Text = "Auto";
                    txtCP.Text = "0";
                    txtSP.Text = "0";
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
                    ItemId = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";
                    cbTaxTypes.SelectedIndex = 0;
                    cbFilter.SelectedIndex = 0;
                    txtItemNo.Text = "Auto";
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
                    ItemId = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    cbTaxTypes.SelectedIndex = 0;
                    txtItemNo.Text = "Auto";

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
                filter_text += " ItemName LIKE '%" + search_value + "%'";
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

                string image_folder = Path.Combine("Images", "Items"); ;
                string long_path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, image_folder);

                string file_name = txtName.Text + ".jpg";
                string logo_path = Path.Combine(image_folder, file_name);

                if (!Directory.Exists(long_path))
                    Directory.CreateDirectory(long_path);
                if (pbLogo.Image != null)
                {
                    pbLogo.Image.Save(Path.Combine(long_path, file_name));
                }

                ItemModel modelItem = new ItemModel();
                ItemModel.Item modelItemDetail = new ItemModel.Item();
                modelItemDetail.ItemId = ItemId;

                modelItemDetail.CategoryId = CategoryId;
                modelItemDetail.ItemName = Utilities.ValidateText(txtName.Text);

                modelItemDetail.CostPrice = Convert.ToDecimal(Utilities.ValidateText(txtCP.Text));
                modelItemDetail.SellPrice = Convert.ToDecimal(Utilities.ValidateText(txtSP.Text));
                modelItemDetail.Active = chkActive.Checked;
                modelItemDetail.TaxTypeId = Convert.ToInt32(cbTaxTypes.SelectedValue);
                modelItemDetail.ImagePath = logo_path;
                modelItem.Save(modelItemDetail);

                Utilities.ShowSuccesMessage(this);
                SetFormState("on_reset");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        #endregion
        public int GetSelectedNode(TreeNodeCollection nodes, ref int count, ref int Id)
        {
            for (int i = 0; i < nodes.Count; i++)
            {
                string name = nodes[i].Name;

                if (nodes[i].Checked)
                {
                    if (count == 0)
                    {
                        Id = Convert.ToInt32(nodes[i].Name);
                    }
                    count++;
                }

                if (nodes[i].Nodes.Count > 0)
                {
                    GetSelectedNode(nodes[i].Nodes,ref count,ref Id);
                }
            }
            if (count > 1)
                return -1;
            else
                return Id;
        }

        private void btnUpload_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Multiselect = false;
            ofd.Title = "Select Item Image";
            DialogResult dr = ofd.ShowDialog();
            if (dr == System.Windows.Forms.DialogResult.OK)
            {
                string ext = Path.GetExtension(ofd.FileName);
                if (ext.Contains("jp"))
                {
                    pbLogo.ImageLocation = ofd.FileName;
                }
                else
                {
                    pbLogo.Image = MMR_AIMS.Properties.Resources.no_image;
                    MessageBox.Show("Only .Jpeg allowed.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
        }
        public void CheckNode(TreeNodeCollection nodes, string ParentId)
        {
            for (int i = 0; i < nodes.Count; i++)
            {
                string name = nodes[i].Name;
                if (ParentId.Equals(name))
                {
                    int a = 0;
                    tvCategories.SelectedNode = nodes[i];
                    tvCategories.SelectedNode.Checked = true;
                    tvCategories.SelectedNode.ForeColor = Color.Green;
                    tvCategories.SelectedNode.ExpandAll();
                    return;
                }
                if (nodes[i].Nodes.Count > 0)
                {
                    CheckNode(nodes[i].Nodes, ParentId);
                }
            }
        }

    }
}
