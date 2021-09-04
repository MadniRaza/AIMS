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
    public partial class fCategories : Form
    {
        #region Data Fields
        int ID = 0;
        int ParentId = 0;

        #endregion
        public fCategories()
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
       
        public void LoadCateogoryChilds(int _parentId, TreeNode tn, DataTable dt) 
        {
            dt.DefaultView.RowFilter = "ParentId = "+_parentId;
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
        void LoadList()
        {
            try
            {
                CategoryModel model = new CategoryModel();
                DataTable dt = ((DataSet)model.GetList()).Tables[0];
                dgList.AutoGenerateColumns = false;
                dgList.DataSource = dt;

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
                CategoryModel model = new CategoryModel();
                DataTable dt = ((DataSet)model.GetById(ID)).Tables[0];
                txtName.Text = dt.Rows[0]["CategoryName"].ToString();
                chkActive.Checked= Convert.ToBoolean(dt.Rows[0]["Active"]);

                CheckNode(tvCategories.Nodes,dt.Rows[0]["ParentId"].ToString());
                
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

        }
        public string ValidateFields()
        {
            StringBuilder sb = new StringBuilder();
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtName.Text.Trim())))
                sb.AppendLine("Please enter Category.");
            int a = 0;
            int b = 0;
            ParentId = GetSelectedNode(tvCategories.Nodes, ref a, ref b);
            if(ParentId == -1)
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
                    ID = 0;
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Text = "";
                    }
                    txtSearch.Text = "";
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
                filter_text += " CategoryName LIKE '%" + search_value + "%'";
                filter_text += " OR ParentName LIKE '%" + search_value + "%'";
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
                CategoryModel modelItem = new CategoryModel();
                CategoryModel.Category obj = new CategoryModel.Category();
                obj.CategoryId = ID;
                obj.CategoryName = txtName.Text;
                
                
                    obj.ParentId = ParentId;
                obj.Active = chkActive.Checked;
                modelItem.Save(obj);

                Utilities.ShowSuccesMessage(this);
                SetFormState("on_reset");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
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
                if(nodes[i].Nodes.Count> 0) 
                {
                   CheckNode(nodes[i].Nodes,ParentId);
                }
            }
        }
        public int GetSelectedNode(TreeNodeCollection nodes,ref int count,ref int Id)
        {
            for (int i = 0; i < nodes.Count; i++)
            {
                string name = nodes[i].Name;

                if (nodes[i].Checked) 
                {
                    if(count == 0) 
                    {
                        Id =Convert.ToInt32(nodes[i].Name);
                    }
                    count++;
                }
                
                if (nodes[i].Nodes.Count > 0)
                {
                    GetSelectedNode(nodes[i].Nodes, ref count,ref Id);
                }
            }
            if (count > 1)
                return -1;
            else
                return Id;
        }

        #endregion
    }
}
