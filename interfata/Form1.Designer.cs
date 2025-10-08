using System.Reflection.Emit;
using System.Windows.Forms;

namespace interfata
{
    partial class Form1
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
        /// Required method for Designer support - do not modify the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.comboBox1 = new System.Windows.Forms.ComboBox();
            this.comboBox3 = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.button1 = new System.Windows.Forms.Button();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.comboBox2 = new System.Windows.Forms.ComboBox();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.textbox_delete_value = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.combobox_delete_coloana = new System.Windows.Forms.ComboBox();
            this.delete_tabele = new System.Windows.Forms.ComboBox();
            this.label6 = new System.Windows.Forms.Label();
            this.delete_stergere = new System.Windows.Forms.Button();
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.combobox_coloane_update_where = new System.Windows.Forms.ComboBox();
            this.coloane_update_where = new System.Windows.Forms.Label();
            this.buton_update = new System.Windows.Forms.Button();
            this.input_where = new System.Windows.Forms.TextBox();
            this.input_set = new System.Windows.Forms.TextBox();
            this.Valoare_where = new System.Windows.Forms.Label();
            this.Valoare_set = new System.Windows.Forms.Label();
            this.coloane_update_set = new System.Windows.Forms.Label();
            this.combobox_coloane_update_set = new System.Windows.Forms.ComboBox();
            this.combobox_tabele_update = new System.Windows.Forms.ComboBox();
            this.tabele_update = new System.Windows.Forms.Label();
            this.tabPage4 = new System.Windows.Forms.TabPage();
            this.butonq = new System.Windows.Forms.Button();
            this.inputq = new System.Windows.Forms.RichTextBox();
            this.dataGridView2 = new System.Windows.Forms.DataGridView();
            this.tabPage5 = new System.Windows.Forms.TabPage();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.tabPage3.SuspendLayout();
            this.tabPage4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).BeginInit();
            this.SuspendLayout();
            // 
            // comboBox1
            // 
            this.comboBox1.FormattingEnabled = true;
            this.comboBox1.Items.AddRange(new object[] {
            "DISTRIBUITOR",
            "MEDIA",
            "SEZON",
            "EPISOD",
            "GEN",
            "MEDIA_GEN",
            "UTILIZATOR",
            "VIZIONEAZA",
            "DISPOZITIV",
            "TIP_ABONAMENT",
            "UTILIZATOR_ABONAMENT"});
            this.comboBox1.Location = new System.Drawing.Point(388, 61);
            this.comboBox1.Name = "comboBox1";
            this.comboBox1.Size = new System.Drawing.Size(243, 24);
            this.comboBox1.TabIndex = 1;
            this.comboBox1.SelectedIndexChanged += new System.EventHandler(this.comboBox1_SelectedIndexChanged);
            // 
            // comboBox3
            // 
            this.comboBox3.FormattingEnabled = true;
            this.comboBox3.Location = new System.Drawing.Point(1005, 218);
            this.comboBox3.Name = "comboBox3";
            this.comboBox3.Size = new System.Drawing.Size(169, 24);
            this.comboBox3.TabIndex = 3;
            // 
            // label1
            // 
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F);
            this.label1.Location = new System.Drawing.Point(388, 14);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(243, 44);
            this.label1.TabIndex = 4;
            this.label1.Text = "TABELE";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.label2.Location = new System.Drawing.Point(1048, 64);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(75, 24);
            this.label2.TabIndex = 5;
            this.label2.Text = "Sortare";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.label3.Location = new System.Drawing.Point(1048, 195);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(70, 20);
            this.label3.TabIndex = 6;
            this.label3.Text = "Coloana";
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(8, 91);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersWidth = 51;
            this.dataGridView1.RowTemplate.Height = 24;
            this.dataGridView1.Size = new System.Drawing.Size(974, 442);
            this.dataGridView1.TabIndex = 7;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(1052, 470);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(115, 53);
            this.button1.TabIndex = 8;
            this.button1.Text = "Afiseaza";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // tabControl1
            // 
            this.tabControl1.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Controls.Add(this.tabPage3);
            this.tabControl1.Controls.Add(this.tabPage4);
            this.tabControl1.Controls.Add(this.tabPage5);
            this.tabControl1.Location = new System.Drawing.Point(0, 1);
            this.tabControl1.Multiline = true;
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(1217, 578);
            this.tabControl1.TabIndex = 9;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.button1);
            this.tabPage1.Controls.Add(this.comboBox2);
            this.tabPage1.Controls.Add(this.label3);
            this.tabPage1.Controls.Add(this.dataGridView1);
            this.tabPage1.Controls.Add(this.comboBox3);
            this.tabPage1.Controls.Add(this.comboBox1);
            this.tabPage1.Controls.Add(this.label2);
            this.tabPage1.Controls.Add(this.label1);
            this.tabPage1.Location = new System.Drawing.Point(4, 25);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(1209, 549);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Listare si Sortare";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // comboBox2
            // 
            this.comboBox2.FormattingEnabled = true;
            this.comboBox2.Items.AddRange(new object[] {
            "ASC",
            "DESC"});
            this.comboBox2.Location = new System.Drawing.Point(1005, 91);
            this.comboBox2.Name = "comboBox2";
            this.comboBox2.Size = new System.Drawing.Size(169, 24);
            this.comboBox2.TabIndex = 2;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.textbox_delete_value);
            this.tabPage2.Controls.Add(this.label5);
            this.tabPage2.Controls.Add(this.label4);
            this.tabPage2.Controls.Add(this.combobox_delete_coloana);
            this.tabPage2.Controls.Add(this.delete_tabele);
            this.tabPage2.Controls.Add(this.label6);
            this.tabPage2.Controls.Add(this.delete_stergere);
            this.tabPage2.Location = new System.Drawing.Point(4, 25);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(1209, 549);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Delete";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // textbox_delete_value
            // 
            this.textbox_delete_value.Location = new System.Drawing.Point(789, 254);
            this.textbox_delete_value.Name = "textbox_delete_value";
            this.textbox_delete_value.Size = new System.Drawing.Size(169, 22);
            this.textbox_delete_value.TabIndex = 15;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.label5.Location = new System.Drawing.Point(841, 231);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(66, 20);
            this.label5.TabIndex = 14;
            this.label5.Text = "Valoare";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.label4.Location = new System.Drawing.Point(837, 88);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(70, 20);
            this.label4.TabIndex = 12;
            this.label4.Text = "Coloana";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // combobox_delete_coloana
            // 
            this.combobox_delete_coloana.FormattingEnabled = true;
            this.combobox_delete_coloana.Location = new System.Drawing.Point(789, 111);
            this.combobox_delete_coloana.Name = "combobox_delete_coloana";
            this.combobox_delete_coloana.Size = new System.Drawing.Size(169, 24);
            this.combobox_delete_coloana.TabIndex = 11;
            // 
            // delete_tabele
            // 
            this.delete_tabele.FormattingEnabled = true;
            this.delete_tabele.Items.AddRange(new object[] {
            "DISTRIBUITOR",
            "MEDIA",
            "SEZON",
            "EPISOD",
            "GEN",
            "MEDIA_GEN",
            "UTILIZATOR",
            "VIZIONEAZA",
            "DISPOZITIV",
            "TIP_ABONAMENT",
            "UTILIZATOR_ABONAMENT"});
            this.delete_tabele.Location = new System.Drawing.Point(327, 199);
            this.delete_tabele.Name = "delete_tabele";
            this.delete_tabele.Size = new System.Drawing.Size(243, 24);
            this.delete_tabele.TabIndex = 8;
            this.delete_tabele.SelectedIndexChanged += new System.EventHandler(this.delete_tabele_SelectedIndexChanged);
            // 
            // label6
            // 
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F);
            this.label6.Location = new System.Drawing.Point(327, 152);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(243, 44);
            this.label6.TabIndex = 9;
            this.label6.Text = "TABELE";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // delete_stergere
            // 
            this.delete_stergere.Location = new System.Drawing.Point(789, 385);
            this.delete_stergere.Name = "delete_stergere";
            this.delete_stergere.Size = new System.Drawing.Size(169, 44);
            this.delete_stergere.TabIndex = 4;
            this.delete_stergere.Text = "Stergere";
            this.delete_stergere.UseVisualStyleBackColor = true;
            this.delete_stergere.Click += new System.EventHandler(this.delete_stergere_Click);
            // 
            // tabPage3
            // 
            this.tabPage3.Controls.Add(this.combobox_coloane_update_where);
            this.tabPage3.Controls.Add(this.coloane_update_where);
            this.tabPage3.Controls.Add(this.buton_update);
            this.tabPage3.Controls.Add(this.input_where);
            this.tabPage3.Controls.Add(this.input_set);
            this.tabPage3.Controls.Add(this.Valoare_where);
            this.tabPage3.Controls.Add(this.Valoare_set);
            this.tabPage3.Controls.Add(this.coloane_update_set);
            this.tabPage3.Controls.Add(this.combobox_coloane_update_set);
            this.tabPage3.Controls.Add(this.combobox_tabele_update);
            this.tabPage3.Controls.Add(this.tabele_update);
            this.tabPage3.Location = new System.Drawing.Point(4, 25);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage3.Size = new System.Drawing.Size(1209, 549);
            this.tabPage3.TabIndex = 2;
            this.tabPage3.Text = "Update";
            this.tabPage3.UseVisualStyleBackColor = true;
            // 
            // combobox_coloane_update_where
            // 
            this.combobox_coloane_update_where.FormattingEnabled = true;
            this.combobox_coloane_update_where.Location = new System.Drawing.Point(789, 140);
            this.combobox_coloane_update_where.Name = "combobox_coloane_update_where";
            this.combobox_coloane_update_where.Size = new System.Drawing.Size(169, 24);
            this.combobox_coloane_update_where.TabIndex = 10;
            // 
            // coloane_update_where
            // 
            this.coloane_update_where.AutoSize = true;
            this.coloane_update_where.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.coloane_update_where.Location = new System.Drawing.Point(812, 117);
            this.coloane_update_where.Name = "coloane_update_where";
            this.coloane_update_where.Size = new System.Drawing.Size(120, 20);
            this.coloane_update_where.TabIndex = 9;
            this.coloane_update_where.Text = "Coloana where";
            this.coloane_update_where.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // buton_update
            // 
            this.buton_update.Location = new System.Drawing.Point(789, 385);
            this.buton_update.Name = "buton_update";
            this.buton_update.Size = new System.Drawing.Size(169, 44);
            this.buton_update.TabIndex = 8;
            this.buton_update.Text = "Update";
            this.buton_update.UseVisualStyleBackColor = true;
            this.buton_update.Click += new System.EventHandler(this.buton_update_Click);
            // 
            // input_where
            // 
            this.input_where.Location = new System.Drawing.Point(789, 322);
            this.input_where.Name = "input_where";
            this.input_where.Size = new System.Drawing.Size(169, 22);
            this.input_where.TabIndex = 7;
            // 
            // input_set
            // 
            this.input_set.Location = new System.Drawing.Point(789, 246);
            this.input_set.Name = "input_set";
            this.input_set.Size = new System.Drawing.Size(169, 22);
            this.input_set.TabIndex = 6;
            // 
            // Valoare_where
            // 
            this.Valoare_where.AutoSize = true;
            this.Valoare_where.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.Valoare_where.Location = new System.Drawing.Point(812, 299);
            this.Valoare_where.Name = "Valoare_where";
            this.Valoare_where.Size = new System.Drawing.Size(116, 20);
            this.Valoare_where.TabIndex = 5;
            this.Valoare_where.Text = "Valoare where";
            this.Valoare_where.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // Valoare_set
            // 
            this.Valoare_set.AutoSize = true;
            this.Valoare_set.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.Valoare_set.Location = new System.Drawing.Point(824, 223);
            this.Valoare_set.Name = "Valoare_set";
            this.Valoare_set.Size = new System.Drawing.Size(94, 20);
            this.Valoare_set.TabIndex = 4;
            this.Valoare_set.Text = "Valoare set";
            this.Valoare_set.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // coloane_update_set
            // 
            this.coloane_update_set.AutoSize = true;
            this.coloane_update_set.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.coloane_update_set.Location = new System.Drawing.Point(820, 34);
            this.coloane_update_set.Name = "coloane_update_set";
            this.coloane_update_set.Size = new System.Drawing.Size(98, 20);
            this.coloane_update_set.TabIndex = 3;
            this.coloane_update_set.Text = "Coloana set";
            this.coloane_update_set.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // combobox_coloane_update_set
            // 
            this.combobox_coloane_update_set.FormattingEnabled = true;
            this.combobox_coloane_update_set.Location = new System.Drawing.Point(789, 57);
            this.combobox_coloane_update_set.Name = "combobox_coloane_update_set";
            this.combobox_coloane_update_set.Size = new System.Drawing.Size(169, 24);
            this.combobox_coloane_update_set.TabIndex = 2;
            // 
            // combobox_tabele_update
            // 
            this.combobox_tabele_update.FormattingEnabled = true;
            this.combobox_tabele_update.Items.AddRange(new object[] {
            "DISTRIBUITOR",
            "MEDIA",
            "SEZON",
            "EPISOD",
            "GEN",
            "MEDIA_GEN",
            "UTILIZATOR",
            "VIZIONEAZA",
            "DISPOZITIV",
            "TIP_ABONAMENT",
            "UTILIZATOR_ABONAMENT"});
            this.combobox_tabele_update.Location = new System.Drawing.Point(327, 199);
            this.combobox_tabele_update.Name = "combobox_tabele_update";
            this.combobox_tabele_update.Size = new System.Drawing.Size(243, 24);
            this.combobox_tabele_update.TabIndex = 1;
            this.combobox_tabele_update.SelectedIndexChanged += new System.EventHandler(this.combobox_tabele_update_SelectedIndexChanged);
            // 
            // tabele_update
            // 
            this.tabele_update.AutoSize = true;
            this.tabele_update.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F);
            this.tabele_update.Location = new System.Drawing.Point(374, 155);
            this.tabele_update.Name = "tabele_update";
            this.tabele_update.Size = new System.Drawing.Size(149, 39);
            this.tabele_update.TabIndex = 0;
            this.tabele_update.Text = "TABELE";
            this.tabele_update.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // tabPage4
            // 
            this.tabPage4.Controls.Add(this.butonq);
            this.tabPage4.Controls.Add(this.inputq);
            this.tabPage4.Controls.Add(this.dataGridView2);
            this.tabPage4.Location = new System.Drawing.Point(4, 25);
            this.tabPage4.Name = "tabPage4";
            this.tabPage4.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage4.Size = new System.Drawing.Size(1209, 549);
            this.tabPage4.TabIndex = 3;
            this.tabPage4.Text = "CustomQuery";
            this.tabPage4.UseVisualStyleBackColor = true;
            // 
            // butonq
            // 
            this.butonq.Location = new System.Drawing.Point(159, 435);
            this.butonq.Name = "butonq";
            this.butonq.Size = new System.Drawing.Size(153, 45);
            this.butonq.TabIndex = 2;
            this.butonq.Text = "Ruleaza";
            this.butonq.UseVisualStyleBackColor = true;
            this.butonq.Click += new System.EventHandler(this.butonq_Click);
            // 
            // inputq
            // 
            this.inputq.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.inputq.Location = new System.Drawing.Point(0, 3);
            this.inputq.Name = "inputq";
            this.inputq.Size = new System.Drawing.Size(489, 426);
            this.inputq.TabIndex = 1;
            this.inputq.Text = "";
            // 
            // dataGridView2
            // 
            this.dataGridView2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView2.Location = new System.Drawing.Point(495, 0);
            this.dataGridView2.Name = "dataGridView2";
            this.dataGridView2.RowHeadersWidth = 51;
            this.dataGridView2.RowTemplate.Height = 24;
            this.dataGridView2.Size = new System.Drawing.Size(711, 504);
            this.dataGridView2.TabIndex = 0;
            // 
            // tabPage5
            // 
            this.tabPage5.Location = new System.Drawing.Point(4, 25);
            this.tabPage5.Name = "tabPage5";
            this.tabPage5.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage5.Size = new System.Drawing.Size(1209, 549);
            this.tabPage5.TabIndex = 4;
            this.tabPage5.Text = "Vizualizari";
            this.tabPage5.UseVisualStyleBackColor = true;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1218, 583);
            this.Controls.Add(this.tabControl1);
            this.Name = "Form1";
            this.Text = "Form1";
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            this.tabPage2.ResumeLayout(false);
            this.tabPage2.PerformLayout();
            this.tabPage3.ResumeLayout(false);
            this.tabPage3.PerformLayout();
            this.tabPage4.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.ComboBox comboBox1;
        private System.Windows.Forms.ComboBox comboBox3;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Button button1;
        private TabControl tabControl1;
        private TabPage tabPage1;
        private TabPage tabPage2;
        private TabPage tabPage3;
        private TabPage tabPage4;
        private TabPage tabPage5;
        private ComboBox comboBox2;
        private ComboBox delete_tabele;
        private System.Windows.Forms.Label label6;
        private Button delete_stergere;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        private ComboBox combobox_delete_coloana;
        private TextBox textbox_delete_value;
        private System.Windows.Forms.Label Valoare_where;
        private System.Windows.Forms.Label Valoare_set;
        private System.Windows.Forms.Label coloane_update_set;
        private ComboBox combobox_coloane_update_set;
        private ComboBox combobox_tabele_update;
        private System.Windows.Forms.Label tabele_update;
        private TextBox input_where;
        private TextBox input_set;
        private Button buton_update;
        private System.Windows.Forms.Label coloane_update_where;
        private ComboBox combobox_coloane_update_where;
        private RichTextBox inputq;
        private DataGridView dataGridView2;
        private Button butonq;
    }
}
