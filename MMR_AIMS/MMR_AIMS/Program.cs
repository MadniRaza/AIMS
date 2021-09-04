using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MMR_AIMS
{
    static class Program
    {
        private static Mutex mutex = null;
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            const string appName = "MMR_AIMS";
            bool createdNew;

            mutex = new Mutex(true, appName, out createdNew);

            if (!createdNew)
            {
                MessageBox.Show("System is already running.", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Information);
                //app is already running! Exiting the application  
                return;
            }
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.ThreadException += new ThreadExceptionEventHandler(ThreadException);

            Application.Run(new fLogin());
           
        }
        static void ThreadException(object sender, ThreadExceptionEventArgs e)
        {
            MessageBox.Show("Unknown Error Occured. Contact IT Team.", AppData.ErrorCaption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

    }
}
