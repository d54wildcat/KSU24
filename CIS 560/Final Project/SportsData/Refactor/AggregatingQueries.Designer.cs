namespace Refactor
{
    partial class AggregatingQueries
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
            uxResultBox = new ListBox();
            uxAggOne_btn = new Button();
            uxAggTwo_btn = new Button();
            uxAggThree_btn = new Button();
            uxAggFour_btn = new Button();
            uxLbl_aggOne = new Label();
            uxLbl_aggTwo = new Label();
            uxLbl_aggThree = new Label();
            uxLbl_AggFour = new Label();
            uxConfCmbBox = new ComboBox();
            uxLbl_xConf = new Label();
            uxLbl_yJerseyNum = new Label();
            uxJersyNumUpDwn = new NumericUpDown();
            uxDone_btn = new Button();
            ((System.ComponentModel.ISupportInitialize)uxJersyNumUpDwn).BeginInit();
            SuspendLayout();
            // 
            // uxResultBox
            // 
            uxResultBox.FormattingEnabled = true;
            uxResultBox.ItemHeight = 15;
            uxResultBox.Location = new Point(496, 10);
            uxResultBox.Name = "uxResultBox";
            uxResultBox.Size = new Size(162, 304);
            uxResultBox.TabIndex = 0;
            // 
            // uxAggOne_btn
            // 
            uxAggOne_btn.Location = new Point(12, 58);
            uxAggOne_btn.Name = "uxAggOne_btn";
            uxAggOne_btn.Size = new Size(117, 48);
            uxAggOne_btn.TabIndex = 1;
            uxAggOne_btn.Text = "Aggregating Q #1";
            uxAggOne_btn.UseVisualStyleBackColor = true;
            uxAggOne_btn.Click += uxAggOne_btn_Click;
            // 
            // uxAggTwo_btn
            // 
            uxAggTwo_btn.Location = new Point(12, 112);
            uxAggTwo_btn.Name = "uxAggTwo_btn";
            uxAggTwo_btn.Size = new Size(117, 48);
            uxAggTwo_btn.TabIndex = 2;
            uxAggTwo_btn.Text = "Aggregating Q #2";
            uxAggTwo_btn.UseVisualStyleBackColor = true;
            uxAggTwo_btn.Click += uxAggTwo_btn_Click;
            // 
            // uxAggThree_btn
            // 
            uxAggThree_btn.Location = new Point(12, 166);
            uxAggThree_btn.Name = "uxAggThree_btn";
            uxAggThree_btn.Size = new Size(117, 48);
            uxAggThree_btn.TabIndex = 3;
            uxAggThree_btn.Text = "Aggregating Q #3";
            uxAggThree_btn.UseVisualStyleBackColor = true;
            uxAggThree_btn.Click += uxAggThree_btn_Click;
            // 
            // uxAggFour_btn
            // 
            uxAggFour_btn.Location = new Point(12, 220);
            uxAggFour_btn.Name = "uxAggFour_btn";
            uxAggFour_btn.Size = new Size(117, 48);
            uxAggFour_btn.TabIndex = 4;
            uxAggFour_btn.Text = "Aggregating Q #4";
            uxAggFour_btn.UseVisualStyleBackColor = true;
            uxAggFour_btn.Click += uxAggFour_btn_Click;
            // 
            // uxLbl_aggOne
            // 
            uxLbl_aggOne.AutoSize = true;
            uxLbl_aggOne.Location = new Point(135, 68);
            uxLbl_aggOne.Name = "uxLbl_aggOne";
            uxLbl_aggOne.Size = new Size(273, 30);
            uxLbl_aggOne.TabIndex = 5;
            uxLbl_aggOne.Text = "List all coaches from the Big 12 that have coached \r\ntheir current team for more than 5 years.\r\n";
            // 
            // uxLbl_aggTwo
            // 
            uxLbl_aggTwo.AutoSize = true;
            uxLbl_aggTwo.Location = new Point(135, 122);
            uxLbl_aggTwo.Name = "uxLbl_aggTwo";
            uxLbl_aggTwo.Size = new Size(185, 30);
            uxLbl_aggTwo.TabIndex = 6;
            uxLbl_aggTwo.Text = "List all guards from X Conference \r\nwho is a Junior or Senior";
            // 
            // uxLbl_aggThree
            // 
            uxLbl_aggThree.AutoSize = true;
            uxLbl_aggThree.Location = new Point(135, 175);
            uxLbl_aggThree.Name = "uxLbl_aggThree";
            uxLbl_aggThree.Size = new Size(163, 30);
            uxLbl_aggThree.TabIndex = 7;
            uxLbl_aggThree.Text = "List all teams that have fewer \r\nthan 14 players on their team.";
            // 
            // uxLbl_AggFour
            // 
            uxLbl_AggFour.AutoSize = true;
            uxLbl_AggFour.Location = new Point(135, 230);
            uxLbl_AggFour.Name = "uxLbl_AggFour";
            uxLbl_AggFour.Size = new Size(243, 30);
            uxLbl_AggFour.TabIndex = 8;
            uxLbl_AggFour.Text = "List all players that are over 6'5 (77 inches.) in\r\nX conference and that have a jersey # >Y";
            // 
            // uxConfCmbBox
            // 
            uxConfCmbBox.FormattingEnabled = true;
            uxConfCmbBox.Items.AddRange(new object[] { "Big 12", "Big Ten", "Atlantic Coast", "Pac-12", "Southeastern" });
            uxConfCmbBox.Location = new Point(96, 12);
            uxConfCmbBox.Name = "uxConfCmbBox";
            uxConfCmbBox.Size = new Size(202, 23);
            uxConfCmbBox.TabIndex = 9;
            uxConfCmbBox.Text = "Big 12";
            // 
            // uxLbl_xConf
            // 
            uxLbl_xConf.AutoSize = true;
            uxLbl_xConf.Location = new Point(9, 15);
            uxLbl_xConf.Name = "uxLbl_xConf";
            uxLbl_xConf.Size = new Size(81, 15);
            uxLbl_xConf.TabIndex = 10;
            uxLbl_xConf.Text = "X Conference:";
            // 
            // uxLbl_yJerseyNum
            // 
            uxLbl_yJerseyNum.AutoSize = true;
            uxLbl_yJerseyNum.Location = new Point(323, 15);
            uxLbl_yJerseyNum.Name = "uxLbl_yJerseyNum";
            uxLbl_yJerseyNum.Size = new Size(98, 15);
            uxLbl_yJerseyNum.TabIndex = 11;
            uxLbl_yJerseyNum.Text = "Y Jersey Number:";
            // 
            // uxJersyNumUpDwn
            // 
            uxJersyNumUpDwn.Location = new Point(427, 13);
            uxJersyNumUpDwn.Name = "uxJersyNumUpDwn";
            uxJersyNumUpDwn.Size = new Size(45, 23);
            uxJersyNumUpDwn.TabIndex = 12;
            // 
            // uxDone_btn
            // 
            uxDone_btn.DialogResult = DialogResult.OK;
            uxDone_btn.Location = new Point(12, 290);
            uxDone_btn.Name = "uxDone_btn";
            uxDone_btn.Size = new Size(81, 24);
            uxDone_btn.TabIndex = 13;
            uxDone_btn.Text = "Done";
            uxDone_btn.UseVisualStyleBackColor = true;
            uxDone_btn.Click += uxDone_btn_Click;
            // 
            // AggregatingQueries
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(670, 326);
            Controls.Add(uxDone_btn);
            Controls.Add(uxJersyNumUpDwn);
            Controls.Add(uxLbl_yJerseyNum);
            Controls.Add(uxLbl_xConf);
            Controls.Add(uxConfCmbBox);
            Controls.Add(uxLbl_AggFour);
            Controls.Add(uxLbl_aggThree);
            Controls.Add(uxLbl_aggTwo);
            Controls.Add(uxLbl_aggOne);
            Controls.Add(uxAggFour_btn);
            Controls.Add(uxAggThree_btn);
            Controls.Add(uxAggTwo_btn);
            Controls.Add(uxAggOne_btn);
            Controls.Add(uxResultBox);
            Name = "AggregatingQueries";
            Text = "AggregatingQueries";
            ((System.ComponentModel.ISupportInitialize)uxJersyNumUpDwn).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private ListBox uxResultBox;
        private Button uxAggOne_btn;
        private Button uxAggTwo_btn;
        private Button uxAggThree_btn;
        private Button uxAggFour_btn;
        private Label uxLbl_aggOne;
        private Label uxLbl_aggTwo;
        private Label uxLbl_aggThree;
        private Label uxLbl_AggFour;
        private ComboBox uxConfCmbBox;
        private Label uxLbl_xConf;
        private Label uxLbl_yJerseyNum;
        private NumericUpDown uxJersyNumUpDwn;
        private Button uxDone_btn;
    }
}