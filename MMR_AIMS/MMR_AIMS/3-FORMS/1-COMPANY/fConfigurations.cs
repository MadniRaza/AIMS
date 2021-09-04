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
    public partial class fConfigurations : Form
    {
        #region Data Fields
        string LogoPath = "";
        #endregion
        public fConfigurations()
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
                CompanyModel model = new CompanyModel();
                DataTable dt = ((DataSet)model.Get()).Tables[0];
                if (dt.Rows.Count == 0)
                    return;
                txtName.Text = dt.Rows[0]["CompanyName"].ToString();
                txtContactPer.Text = dt.Rows[0]["ContactPerson"].ToString();
                txtTel.Text = dt.Rows[0]["TelNo"].ToString();
                txtSTR.Text = dt.Rows[0]["STRNo"].ToString();
                txtNTN.Text = dt.Rows[0]["NTNNo"].ToString();
                txtAddr1.Text = dt.Rows[0]["AddressLine1"].ToString();
                txtAddr2.Text = dt.Rows[0]["AddressLine2"].ToString();
                txtEmail.Text = dt.Rows[0]["Email"].ToString();
                txtDesc.Text = dt.Rows[0]["ShortDesc"].ToString();
                txtInvoiceFooter.Text = dt.Rows[0]["InvoiceFooterRemarks"].ToString();
                if (!string.IsNullOrEmpty(dt.Rows[0]["LogoPath"].ToString())) 
                {
                    pbLogo.ImageLocation = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, dt.Rows[0]["LogoPath"].ToString()).Replace(@"\","/");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }



        public string ValidateFields()
        {
            StringBuilder sb = new StringBuilder();
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtName.Text.Trim())))
                sb.AppendLine("Please enter Company Name.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtAddr1.Text.Trim())))
                sb.AppendLine("Please enter Address 1.");
            if (string.IsNullOrEmpty(Utilities.ValidateText(txtContactPer.Text.Trim())))
                sb.AppendLine("Please enter Contact person.");
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

                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Enabled = true;
                        txt.ReadOnly = false;
                    }


                    btnSave.Enabled = true;
                    btnReset.Enabled = true;
                    break;

                case "on_reset":
                    PauseActions(true);
                    //LOAD OBJECTS
                    LoadInitialData();
                    PauseActions(false);
                    // CLEAR VALUES
                    foreach (TextBox txt in gb.Controls.OfType<TextBox>())
                    {
                        txt.Enabled = true;
                        txt.ReadOnly = false;
                    }
                    btnSave.Enabled = true;
                    btnReset.Enabled = true;
                    
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
                string image_folder = Path.Combine("Images", "Company"); ;
                string long_path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, image_folder);

                string file_name = "Logo.jpg";
                string logo_path = Path.Combine(image_folder, file_name);

                if (!Directory.Exists(long_path))
                    Directory.CreateDirectory(long_path);

                pbLogo.Image.Save(Path.Combine(long_path, file_name));



                CompanyModel modelItem = new CompanyModel();
                CompanyModel.CompanyInfo obj = new CompanyModel.CompanyInfo();
                obj.CompanyName = txtName.Text;
                obj.ContactPerson = txtContactPer.Text;
                obj.AddressLine1 = txtAddr1.Text;
                obj.AddressLine2 = txtAddr2.Text;
                obj.STRNo = txtSTR.Text;
                obj.NTNNo = txtNTN.Text;
                obj.TelNo = txtTel.Text;
                obj.LogoPath = logo_path;
                obj.InvoiceFooterRemarks = txtInvoiceFooter.Text;
                obj.Email = txtEmail.Text;
                obj.ShortDesc = txtDesc.Text;
                obj.Slogan = txtSlogan.Text;
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

        private void button1_Click(object sender, EventArgs e)
        {

        }

        private void btnUpload_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Multiselect = false;
            ofd.Title = "Select Company Logo";
            DialogResult dr = ofd.ShowDialog();
            if (dr == System.Windows.Forms.DialogResult.OK)
            {
                string ext = Path.GetExtension(ofd.FileName);
                if (ext.Contains("jp"))
                {

                    //string image_folder = Path.Combine("Madni", "Company"); ;
                    //string long_path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, image_folder);

                    //string file_name = "Logo.jpg";
                    //string logo_path = Path.Combine(image_folder, file_name);

                    //if (!Directory.Exists(long_path))
                    //    Directory.CreateDirectory(long_path);
                    pbLogo.ImageLocation = ofd.FileName;
                }
                else
                {
                    pbLogo.Image = MMR_AIMS.Properties.Resources.no_image;
                    MessageBox.Show("Only .Jpeg allowed.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
        }
    }
}
