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
    public partial class fSplash : Form
    {
        public fSplash()
        {
            InitializeComponent();
        }

        private void fSplash_Load(object sender, EventArgs e)
        {
            if (!bgLoader.IsBusy)
                bgLoader.RunWorkerAsync();
        }

        private void bgLoader_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                AppInitModel oModel = new AppInitModel();
                AppData.dtMenus = ((DataSet)oModel.GetAllMenus()).Tables[0];
                DataTable dt = ((DataSet)oModel.GetActiveFiscalYear()).Tables[0];
                if (dt.Rows.Count > 0)
                {
                    AppData.FiscalYearFromDate = Convert.ToDateTime(dt.Rows[0]["FromDate"]);
                    AppData.FiscalYearToDate = Convert.ToDateTime(dt.Rows[0]["ToDate"]);
                }
                AppData.IsLive = false ;

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void bgLoader_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            fDashboard frmDashboard = new fDashboard();
            frmDashboard.Show();
            this.Hide();

        }
    }
}
