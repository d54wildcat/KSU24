namespace Refactor
{
    partial class SportsDBUI
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            uxEntityBox = new ListBox();
            uxEntityName = new Label();
            uxSearchBox = new TextBox();
            uxSearchButton = new Button();
            uxEnityFiltersBox = new CheckedListBox();
            uxInfoLbl_One = new Label();
            uxInfoLbl_Two = new Label();
            uxInfoLbl_Three = new Label();
            uxBackwardBtn = new Button();
            uxForwardBtn = new Button();
            uxSetFilterBtn = new Button();
            uxInfoLbl_Four = new Label();
            uxInfoLbl_Five = new Label();
            uxInfoLbl_Six = new Label();
            uxUpdateInfo = new Button();
            uxSearchLbl = new Label();
            uxInvalidSearch = new Label();
            uxAggQ_btn = new Button();
            SuspendLayout();
            // 
            // uxEntityBox
            // 
            uxEntityBox.FormattingEnabled = true;
            uxEntityBox.ItemHeight = 15;
            uxEntityBox.Location = new Point(10, 45);
            uxEntityBox.Margin = new Padding(2);
            uxEntityBox.Name = "uxEntityBox";
            uxEntityBox.Size = new Size(213, 259);
            uxEntityBox.TabIndex = 0;
            // 
            // uxEntityName
            // 
            uxEntityName.AutoSize = true;
            uxEntityName.Font = new Font("Segoe UI", 16F, FontStyle.Bold, GraphicsUnit.Point);
            uxEntityName.Location = new Point(11, 13);
            uxEntityName.Margin = new Padding(2, 0, 2, 0);
            uxEntityName.Name = "uxEntityName";
            uxEntityName.Size = new Size(74, 30);
            uxEntityName.TabIndex = 1;
            uxEntityName.Text = "Name";
            // 
            // uxSearchBox
            // 
            uxSearchBox.Location = new Point(236, 45);
            uxSearchBox.Name = "uxSearchBox";
            uxSearchBox.Size = new Size(242, 23);
            uxSearchBox.TabIndex = 2;
            // 
            // uxSearchButton
            // 
            uxSearchButton.Location = new Point(484, 45);
            uxSearchButton.Name = "uxSearchButton";
            uxSearchButton.Size = new Size(86, 23);
            uxSearchButton.TabIndex = 3;
            uxSearchButton.Text = "Search";
            uxSearchButton.UseVisualStyleBackColor = true;
            uxSearchButton.Click += uxSearchButton_Click;
            // 
            // uxEnityFiltersBox
            // 
            uxEnityFiltersBox.FormattingEnabled = true;
            uxEnityFiltersBox.Location = new Point(609, 45);
            uxEnityFiltersBox.Name = "uxEnityFiltersBox";
            uxEnityFiltersBox.Size = new Size(120, 256);
            uxEnityFiltersBox.TabIndex = 4;
            // 
            // uxInfoLbl_One
            // 
            uxInfoLbl_One.AutoSize = true;
            uxInfoLbl_One.Location = new Point(236, 115);
            uxInfoLbl_One.Name = "uxInfoLbl_One";
            uxInfoLbl_One.Size = new Size(38, 15);
            uxInfoLbl_One.TabIndex = 5;
            uxInfoLbl_One.Text = "label1";
            // 
            // uxInfoLbl_Two
            // 
            uxInfoLbl_Two.AutoSize = true;
            uxInfoLbl_Two.Location = new Point(236, 136);
            uxInfoLbl_Two.Name = "uxInfoLbl_Two";
            uxInfoLbl_Two.Size = new Size(38, 15);
            uxInfoLbl_Two.TabIndex = 6;
            uxInfoLbl_Two.Text = "label2";
            // 
            // uxInfoLbl_Three
            // 
            uxInfoLbl_Three.AutoSize = true;
            uxInfoLbl_Three.Location = new Point(236, 157);
            uxInfoLbl_Three.Name = "uxInfoLbl_Three";
            uxInfoLbl_Three.Size = new Size(38, 15);
            uxInfoLbl_Three.TabIndex = 7;
            uxInfoLbl_Three.Text = "label3";
            // 
            // uxBackwardBtn
            // 
            uxBackwardBtn.Location = new Point(11, 313);
            uxBackwardBtn.Margin = new Padding(2);
            uxBackwardBtn.Name = "uxBackwardBtn";
            uxBackwardBtn.Size = new Size(78, 36);
            uxBackwardBtn.TabIndex = 8;
            uxBackwardBtn.Text = "<-";
            uxBackwardBtn.UseVisualStyleBackColor = true;
            uxBackwardBtn.Click += uxBackwardBtn_Click;
            // 
            // uxForwardBtn
            // 
            uxForwardBtn.Location = new Point(144, 313);
            uxForwardBtn.Margin = new Padding(2);
            uxForwardBtn.Name = "uxForwardBtn";
            uxForwardBtn.Size = new Size(78, 36);
            uxForwardBtn.TabIndex = 9;
            uxForwardBtn.Text = "->";
            uxForwardBtn.UseVisualStyleBackColor = true;
            uxForwardBtn.Click += uxForwardBtn_Click;
            // 
            // uxSetFilterBtn
            // 
            uxSetFilterBtn.Location = new Point(609, 313);
            uxSetFilterBtn.Margin = new Padding(2);
            uxSetFilterBtn.Name = "uxSetFilterBtn";
            uxSetFilterBtn.Size = new Size(119, 20);
            uxSetFilterBtn.TabIndex = 10;
            uxSetFilterBtn.Text = "Set Filter";
            uxSetFilterBtn.UseVisualStyleBackColor = true;
            uxSetFilterBtn.Click += uxSetFilterBtn_Click;
            // 
            // uxInfoLbl_Four
            // 
            uxInfoLbl_Four.AutoSize = true;
            uxInfoLbl_Four.Location = new Point(236, 178);
            uxInfoLbl_Four.Margin = new Padding(2, 0, 2, 0);
            uxInfoLbl_Four.Name = "uxInfoLbl_Four";
            uxInfoLbl_Four.Size = new Size(38, 15);
            uxInfoLbl_Four.TabIndex = 11;
            uxInfoLbl_Four.Text = "label4";
            // 
            // uxInfoLbl_Five
            // 
            uxInfoLbl_Five.AutoSize = true;
            uxInfoLbl_Five.Location = new Point(236, 199);
            uxInfoLbl_Five.Margin = new Padding(2, 0, 2, 0);
            uxInfoLbl_Five.Name = "uxInfoLbl_Five";
            uxInfoLbl_Five.Size = new Size(38, 15);
            uxInfoLbl_Five.TabIndex = 12;
            uxInfoLbl_Five.Text = "label5";
            // 
            // uxInfoLbl_Six
            // 
            uxInfoLbl_Six.AutoSize = true;
            uxInfoLbl_Six.Location = new Point(236, 220);
            uxInfoLbl_Six.Margin = new Padding(2, 0, 2, 0);
            uxInfoLbl_Six.Name = "uxInfoLbl_Six";
            uxInfoLbl_Six.Size = new Size(38, 15);
            uxInfoLbl_Six.TabIndex = 13;
            uxInfoLbl_Six.Text = "label6";
            // 
            // uxUpdateInfo
            // 
            uxUpdateInfo.Location = new Point(236, 242);
            uxUpdateInfo.Margin = new Padding(2);
            uxUpdateInfo.Name = "uxUpdateInfo";
            uxUpdateInfo.Size = new Size(178, 27);
            uxUpdateInfo.TabIndex = 14;
            uxUpdateInfo.Text = "Update Above Data";
            uxUpdateInfo.UseVisualStyleBackColor = true;
            uxUpdateInfo.Click += uxUpdateInfo_Click;
            // 
            // uxSearchLbl
            // 
            uxSearchLbl.AutoSize = true;
            uxSearchLbl.Location = new Point(236, 28);
            uxSearchLbl.Name = "uxSearchLbl";
            uxSearchLbl.Size = new Size(61, 15);
            uxSearchLbl.TabIndex = 15;
            uxSearchLbl.Text = "Search: {}s";
            // 
            // uxInvalidSearch
            // 
            uxInvalidSearch.AutoSize = true;
            uxInvalidSearch.Location = new Point(236, 71);
            uxInvalidSearch.Name = "uxInvalidSearch";
            uxInvalidSearch.Size = new Size(80, 15);
            uxInvalidSearch.TabIndex = 16;
            uxInvalidSearch.Text = "Invalid Search";
            // 
            // uxAggQ_btn
            // 
            uxAggQ_btn.Location = new Point(351, 318);
            uxAggQ_btn.Name = "uxAggQ_btn";
            uxAggQ_btn.Size = new Size(127, 26);
            uxAggQ_btn.TabIndex = 17;
            uxAggQ_btn.Text = "Aggregating Queries";
            uxAggQ_btn.UseVisualStyleBackColor = true;
            uxAggQ_btn.Click += uxAggQ_btn_Click;
            // 
            // SportsDBUI
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(741, 356);
            Controls.Add(uxAggQ_btn);
            Controls.Add(uxInvalidSearch);
            Controls.Add(uxSearchLbl);
            Controls.Add(uxUpdateInfo);
            Controls.Add(uxInfoLbl_Six);
            Controls.Add(uxInfoLbl_Five);
            Controls.Add(uxInfoLbl_Four);
            Controls.Add(uxSetFilterBtn);
            Controls.Add(uxForwardBtn);
            Controls.Add(uxBackwardBtn);
            Controls.Add(uxInfoLbl_Three);
            Controls.Add(uxInfoLbl_Two);
            Controls.Add(uxInfoLbl_One);
            Controls.Add(uxEnityFiltersBox);
            Controls.Add(uxSearchButton);
            Controls.Add(uxSearchBox);
            Controls.Add(uxEntityName);
            Controls.Add(uxEntityBox);
            Margin = new Padding(2);
            Name = "SportsDBUI";
            Text = "Sports DB";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private ListBox uxEntityBox;
        private Label uxEntityName;
        private TextBox uxSearchBox;
        private Button uxSearchButton;
        private CheckedListBox uxEnityFiltersBox;
        private Label uxInfoLbl_One;
        private Label uxInfoLbl_Two;
        private Label uxInfoLbl_Three;
        private Button uxBackwardBtn;
        private Button uxForwardBtn;
        private Button uxSetFilterBtn;
        private Label uxInfoLbl_Four;
        private Label uxInfoLbl_Five;
        private Label uxInfoLbl_Six;
        private Button uxUpdateInfo;
        private Label uxSearchLbl;
        private Label uxInvalidSearch;
        private Button uxAggQ_btn;
    }
}
