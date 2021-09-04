using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    public partial class fDashboard : Form
    {
        public fDashboard()
        {
            InitializeComponent();
            this.IsMdiContainer = true;
        }

        public void BindMenus()
        {
            DataTable dtMenus = AppData.dtMenus;
            dtMenus.DefaultView.RowFilter = "ParentId = 0";
            DataTable dtTmpParents = dtMenus.DefaultView.ToTable();
            rbMnu.Tabs[0].Visible = false;
            for (int i = 0; i < dtTmpParents.Rows.Count; i++)
            {
                RibbonTab rbTab = new RibbonTab();
                rbTab.Text = dtTmpParents.Rows[i]["MenuName"].ToString();

                dtMenus.DefaultView.RowFilter = "ParentId = " + dtTmpParents.Rows[i]["MenuId"];
                DataTable dtTmpChilds = dtMenus.DefaultView.ToTable();
                dtMenus.DefaultView.RowFilter = "ParentId = " + dtTmpParents.Rows[i]["MenuId"] + " AND MenuGroupId IS NOT NULL";
                DataTable dtTmpGroups = dtMenus.DefaultView.ToTable(true, "MenuGroupId", "MenuGroupName");
                for (int j = 0; j < dtTmpGroups.Rows.Count; j++)
                {
                    RibbonPanel rbPanel = new RibbonPanel();
                    rbPanel.Text = dtTmpGroups.Rows[j]["MenuGroupName"].ToString();

                    dtTmpChilds.DefaultView.RowFilter = "ParentId = " + dtTmpParents.Rows[i]["MenuId"] + " AND MenuGroupId = " + dtTmpGroups.Rows[j]["MenuGroupId"];

                    DataTable dtTmpForms = dtTmpChilds.DefaultView.ToTable();
                    for (int k = 0; k < dtTmpForms.Rows.Count; k++)
                    {
                        RibbonButton rbBtn = new RibbonButton();
                        rbBtn.Name = dtTmpForms.Rows[k]["MenuPath"].ToString();
                        rbBtn.Text = dtTmpForms.Rows[k]["MenuName"].ToString();
                        //rbBtn.Value = dtTmpForms.Rows[k]["MenuPath"].ToString();
                        rbBtn.Visible = true;
                        rbBtn.Image = MMR_AIMS.Properties.Resources.m3;
                        rbBtn.Click += new EventHandler(mnuClick);
                        rbBtn.MinimumSize = new Size(60, 20);

                        rbPanel.Items.Add(rbBtn);
                    }
                    rbPanel.Visible = true;

                    rbTab.Panels.Add(rbPanel);
                }
                rbMnu.Tabs.Add(rbTab);
            }
        }


        private void fDashboard_Load(object sender, EventArgs e)
        {
            ssSuccessMessage.Visible = false;
            ssSuccessMessage.Text = AppData.SuccessMessage;
            ssUserName.Text = "| " + AppData.UserName;
            timerMessage.Interval = 1000;
            BindMenus();
        }


        private void mnuClick(object sender, EventArgs e)
        {
            try
            {


                string frmName = ((RibbonButton)sender).Name;
                Type tp = Type.GetType("MMR_AIMS." + frmName);
                Form frm = (Form)Activator.CreateInstance(tp);
                ShowForm(frm);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);


            }
        }
        public void ShowForm(Form frm)
        {
            if (frm.Name == "fLogin")
            {
                frm.Show();
                this.Hide();
                return;

            }
            //CHECK WEATHER FORM IS OPENED
            Form[] forms = this.MdiChildren;
            foreach (Form f in forms)
            {
                if (f.Name == frm.Name)
                {
                    f.BringToFront();
                    f.Activate();
                    return;
                }
            }
            frm.MdiParent = this;
            frm.BringToFront();
            frm.WindowState = FormWindowState.Normal;
            frm.Show();
        }

        public static void aa()
        {

        }
        public int messageInterval = 0;
        private void timerMessage_Tick(object sender, EventArgs e)
        {
            if (messageInterval > 4)
            {
                this.ssSuccessMessage.Visible = false;
                timerMessage.Enabled = false;
            }
            messageInterval += 1;

        }

        private void fDashboard_FormClosing(object sender, FormClosingEventArgs e)
        {
            fLogin frm = new fLogin();
            this.Hide();
            frm.Show();
        }

        private void toolStripStatusLabel2_Click(object sender, EventArgs e)
        {

        }
    }
}
