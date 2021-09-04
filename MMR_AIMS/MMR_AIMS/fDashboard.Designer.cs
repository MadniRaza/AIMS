namespace MMR_AIMS
{
    partial class fDashboard
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(fDashboard));
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.ssUserName = new System.Windows.Forms.ToolStripStatusLabel();
            this.ssSuccessMessage = new System.Windows.Forms.StatusStrip();
            this.sSuccessMsg = new System.Windows.Forms.ToolStripStatusLabel();
            this.ribbonTab1 = new System.Windows.Forms.RibbonTab();
            this.rbMnu = new System.Windows.Forms.Ribbon();
            this.ribbonTab2 = new System.Windows.Forms.RibbonTab();
            this.ribbonPanel2 = new System.Windows.Forms.RibbonPanel();
            this.ribbonButton1 = new System.Windows.Forms.RibbonButton();
            this.timerMessage = new System.Windows.Forms.Timer(this.components);
            this.toolStripStatusLabel2 = new System.Windows.Forms.ToolStripStatusLabel();
            this.statusStrip1.SuspendLayout();
            this.ssSuccessMessage.SuspendLayout();
            this.SuspendLayout();
            // 
            // statusStrip1
            // 
            this.statusStrip1.ImageScalingSize = new System.Drawing.Size(24, 24);
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1,
            this.ssUserName,
            this.toolStripStatusLabel2});
            this.statusStrip1.Location = new System.Drawing.Point(0, 578);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(800, 22);
            this.statusStrip1.TabIndex = 0;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(36, 17);
            this.toolStripStatusLabel1.Text = "User: ";
            // 
            // ssUserName
            // 
            this.ssUserName.Name = "ssUserName";
            this.ssUserName.Size = new System.Drawing.Size(118, 17);
            this.ssUserName.Text = "toolStripStatusLabel2";
            // 
            // ssSuccessMessage
            // 
            this.ssSuccessMessage.ImageScalingSize = new System.Drawing.Size(24, 24);
            this.ssSuccessMessage.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.sSuccessMsg});
            this.ssSuccessMessage.Location = new System.Drawing.Point(0, 549);
            this.ssSuccessMessage.Name = "ssSuccessMessage";
            this.ssSuccessMessage.Size = new System.Drawing.Size(800, 29);
            this.ssSuccessMessage.TabIndex = 1;
            this.ssSuccessMessage.Text = "statusStrip2";
            this.ssSuccessMessage.Visible = false;
            // 
            // sSuccessMsg
            // 
            this.sSuccessMsg.Image = global::MMR_AIMS.Properties.Resources.success;
            this.sSuccessMsg.Name = "sSuccessMsg";
            this.sSuccessMsg.Size = new System.Drawing.Size(167, 24);
            this.sSuccessMsg.Text = "Record Saved Succesfully.";
            // 
            // ribbonTab1
            // 
            this.ribbonTab1.Name = "ribbonTab1";
            this.ribbonTab1.Text = "ribbonTab1";
            // 
            // rbMnu
            // 
            this.rbMnu.BorderMode = System.Windows.Forms.RibbonWindowMode.InsideWindow;
            this.rbMnu.CaptionBarVisible = false;
            this.rbMnu.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.rbMnu.Location = new System.Drawing.Point(0, 0);
            this.rbMnu.Minimized = false;
            this.rbMnu.Name = "rbMnu";
            // 
            // 
            // 
            this.rbMnu.OrbDropDown.BorderRoundness = 8;
            this.rbMnu.OrbDropDown.Location = new System.Drawing.Point(0, 0);
            this.rbMnu.OrbDropDown.Name = "";
            this.rbMnu.OrbDropDown.Size = new System.Drawing.Size(527, 447);
            this.rbMnu.OrbDropDown.TabIndex = 0;
            this.rbMnu.OrbVisible = false;
            // 
            // 
            // 
            this.rbMnu.QuickAccessToolbar.Visible = false;
            this.rbMnu.RibbonTabFont = new System.Drawing.Font("Trebuchet MS", 9F);
            this.rbMnu.Size = new System.Drawing.Size(800, 106);
            this.rbMnu.TabIndex = 2;
            this.rbMnu.Tabs.Add(this.ribbonTab2);
            this.rbMnu.Text = "ribbon1";
            // 
            // ribbonTab2
            // 
            this.ribbonTab2.Name = "ribbonTab2";
            this.ribbonTab2.Panels.Add(this.ribbonPanel2);
            this.ribbonTab2.Text = "ribbonTab2";
            // 
            // ribbonPanel2
            // 
            this.ribbonPanel2.Items.Add(this.ribbonButton1);
            this.ribbonPanel2.Name = "ribbonPanel2";
            this.ribbonPanel2.Text = "ribbonPanel2";
            // 
            // ribbonButton1
            // 
            this.ribbonButton1.Image = ((System.Drawing.Image)(resources.GetObject("ribbonButton1.Image")));
            this.ribbonButton1.LargeImage = ((System.Drawing.Image)(resources.GetObject("ribbonButton1.LargeImage")));
            this.ribbonButton1.MinSizeMode = System.Windows.Forms.RibbonElementSizeMode.Large;
            this.ribbonButton1.Name = "ribbonButton1";
            this.ribbonButton1.SmallImage = ((System.Drawing.Image)(resources.GetObject("ribbonButton1.SmallImage")));
            // 
            // timerMessage
            // 
            this.timerMessage.Tick += new System.EventHandler(this.timerMessage_Tick);
            // 
            // toolStripStatusLabel2
            // 
            this.toolStripStatusLabel2.Name = "toolStripStatusLabel2";
            this.toolStripStatusLabel2.Size = new System.Drawing.Size(600, 17);
            this.toolStripStatusLabel2.Spring = true;
            this.toolStripStatusLabel2.Text = "Powered By MMR";
            this.toolStripStatusLabel2.Click += new System.EventHandler(this.toolStripStatusLabel2_Click);
            // 
            // fDashboard
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.BackgroundImage = global::MMR_AIMS.Properties.Resources.dashboard_bg;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(800, 600);
            this.Controls.Add(this.rbMnu);
            this.Controls.Add(this.ssSuccessMessage);
            this.Controls.Add(this.statusStrip1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.IsMdiContainer = true;
            this.KeyPreview = true;
            this.MinimumSize = new System.Drawing.Size(800, 600);
            this.Name = "fDashboard";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "A I M S";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.fDashboard_FormClosing);
            this.Load += new System.EventHandler(this.fDashboard_Load);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ssSuccessMessage.ResumeLayout(false);
            this.ssSuccessMessage.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
        private System.Windows.Forms.ToolStripStatusLabel ssUserName;
        private System.Windows.Forms.RibbonTab ribbonTab1;
        private System.Windows.Forms.RibbonPanel ribbonPanel1;
        private System.Windows.Forms.RibbonTab ribbonTab2;
        private System.Windows.Forms.RibbonPanel ribbonPanel2;
        private System.Windows.Forms.RibbonButton ribbonButton1;
        private System.Windows.Forms.Ribbon rbMnu;
        public System.Windows.Forms.Timer timerMessage;
        public System.Windows.Forms.ToolStripStatusLabel sSuccessMsg;
        public System.Windows.Forms.StatusStrip ssSuccessMessage;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel2;
    }
}