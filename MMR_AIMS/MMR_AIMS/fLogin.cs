using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fLogin : Form
    {
        public fLogin()
        {
            InitializeComponent();
           //txtUserName.Text = "madni";
           //txtUserPwd.Text = "00000";
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                PauseActions(true);
                LoginModel oModel = new LoginModel();
                LoginModel.User oModelInfo = new LoginModel.User();
                oModelInfo.UserName = Utilities.ValidateText(txtUserName.Text);
                oModelInfo.UserPwd = Utilities.ValidateText(txtUserPwd.Text);
                DataTable dtUser =((DataSet)oModel.ValidateUser(oModelInfo)).Tables[0];
                AppData.UserId = Convert.ToInt32(dtUser.Rows[0]["UserId"]);
                AppData.UserName = oModelInfo.UserName;
                PauseActions(false);
                fSplash frmSplash = new fSplash();
                frmSplash.Show();
                this.Hide();
                

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                PauseActions(false);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            
                // Console app
                System.Environment.Exit(1);
            


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

        private void fLogin_FormClosing(object sender, FormClosingEventArgs e)
        {
            System.Environment.Exit(1);

        }
    }
}
