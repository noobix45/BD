using Oracle.ManagedDataAccess.Client;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace interfata
{
    public partial class Form1 : Form
    {
        private OracleConnection con; // Declare the connection at the class level for reuse

        public Form1()
        {
            InitializeComponent();
            string connectionString = "Data Source=(DESCRIPTION=" +
                          "(ADDRESS =(PROTOCOL=TCP)(HOST=LOCALHOST)(PORT=1521))" +
                          "(CONNECT DATA = " +
                          "(SERVER=DEDICATED)" +
                          "(SID=XE)));User Id=user_test;password=mypass";

            con = new OracleConnection(connectionString);

            try
            {
                con.Open();
                MessageBox.Show("Conexiunea a fost realizată cu succes!", "Succes", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }
            catch (Exception ex)
            {
                MessageBox.Show($"Eroare la conectare: {ex.Message}", "Eroare", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // Button click to display table content in DataGridView
        private void button1_Click(object sender, EventArgs e)
        {
            // Get the selected values from the combo boxes
            string selectedTable = comboBox1.SelectedItem?.ToString();
            string selectedColumn = comboBox3.SelectedItem?.ToString();  // Get the selected column from ComboBox3
            string sortOrder = comboBox2.SelectedItem?.ToString(); // "asc" or "desc" from ComboBox2

            Console.WriteLine($"Button clicked");
            Console.WriteLine($"Selected Table: {selectedTable}"); // Debugging line
            Console.WriteLine($"Selected Column: {selectedColumn}"); // Debugging line
            Console.WriteLine($"Sort Order: {sortOrder}"); // Debugging line
            Console.WriteLine($"Connection state: {con.State}"); // Debugging line

            // Check if the table is selected
            if (string.IsNullOrEmpty(selectedTable))
            {
                MessageBox.Show("Please select a table first!", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Base query
            string query = $"SELECT * FROM {selectedTable}";

            // If both the column and sort order are selected, add ORDER BY clause
            if (!string.IsNullOrEmpty(selectedColumn) && !string.IsNullOrEmpty(sortOrder))
            {
                // Construct the ORDER BY clause correctly
                query += $" ORDER BY {selectedColumn} {sortOrder.ToUpper()}"; // Ensure the sort order is in uppercase (ASC/DESC)
            }

            Console.WriteLine($"Executing query: {query}"); // Debugging line

            try
            {
                if (con.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }

                using (OracleCommand cmd = new OracleCommand(query, con))
                {
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            var dataTable = new System.Data.DataTable();
                            dataTable.Load(reader);
                            dataGridView1.DataSource = dataTable;
                        }
                        else
                        {
                            MessageBox.Show("No records found.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (con.State == System.Data.ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }
        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Get the selected table from comboBox1
            string selectedTable = comboBox1.SelectedItem?.ToString();

            // Clear comboBox3 before adding new items
            comboBox3.Items.Clear();

            // Check if a valid table is selected
            if (!string.IsNullOrEmpty(selectedTable))
            {
                try
                {
                    // Prepare the query to get columns of the selected table
                    string query = $"SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '{selectedTable.ToUpper()}'"; // Ensure uppercase for table names

                    // Create a new OracleCommand object
                    using (OracleCommand cmd = new OracleCommand(query, con))
                    {
                        // Open connection if it's not open
                        if (con.State != System.Data.ConnectionState.Open)
                        {
                            con.Open();
                        }

                        // Execute the query and fetch column names
                        using (OracleDataReader reader = cmd.ExecuteReader())
                        {
                            // Check if there are columns available
                            while (reader.Read())
                            {
                                string columnName = reader.GetString(0); // Get the column name
                                comboBox3.Items.Add(columnName); // Add the column name to comboBox3
                            }
                        }
                    }

                    // Close the connection
                    if (con.State == System.Data.ConnectionState.Open)
                    {
                        con.Close();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error fetching columns: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void delete_tabele_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Get the selected table from comboBox1
            string selectedTable = delete_tabele.SelectedItem?.ToString();

            // Clear comboBox3 before adding new items
            combobox_delete_coloana.Items.Clear();

            // Check if a valid table is selected
            if (!string.IsNullOrEmpty(selectedTable))
            {
                try
                {
                    // Prepare the query to get columns of the selected table
                    string query = $"SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '{selectedTable.ToUpper()}'"; // Ensure uppercase for table names

                    // Create a new OracleCommand object
                    using (OracleCommand cmd = new OracleCommand(query, con))
                    {
                        // Open connection if it's not open
                        if (con.State != System.Data.ConnectionState.Open)
                        {
                            con.Open();
                        }

                        // Execute the query and fetch column names
                        using (OracleDataReader reader = cmd.ExecuteReader())
                        {
                            // Check if there are columns available
                            while (reader.Read())
                            {
                                string columnName = reader.GetString(0); // Get the column name
                                combobox_delete_coloana.Items.Add(columnName); // Add the column name to comboBox3
                            }
                        }
                    }

                    // Close the connection
                    if (con.State == System.Data.ConnectionState.Open)
                    {
                        con.Close();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error fetching columns: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }


        private void button2_Click(object sender, EventArgs e)
        {
            Console.WriteLine("Button clicked");
        }



        private void delete_stergere_Click(object sender, EventArgs e)
        {
            if (delete_tabele.SelectedItem == null || combobox_delete_coloana.SelectedItem == null || string.IsNullOrWhiteSpace(textbox_delete_value.Text))
            {
                MessageBox.Show("Please select a table, column, and provide a value.");
                return;
            }

            string selectedTable = delete_tabele.SelectedItem.ToString();
            string selectedColumn = combobox_delete_coloana.SelectedItem.ToString();
            string userInput = textbox_delete_value.Text;

            // Query to delete the selected row based on column value
            string query = $"DELETE FROM {selectedTable} WHERE {selectedColumn} = :Value"; // Use :Value for Oracle

            try
            {
                // Check if the connection is open
                if (con.State != System.Data.ConnectionState.Open)
                {
                    con.Open();  // Open the connection if it's not already open
                }

                using (OracleCommand command = new OracleCommand(query, con))
                {
                    // Add parameter for the value based on user input
                    if (int.TryParse(userInput, out int numericValue))
                    {
                        command.Parameters.Add(new OracleParameter(":Value", OracleDbType.Int32)).Value = numericValue;
                    }
                    else
                    {
                        command.Parameters.Add(new OracleParameter(":Value", OracleDbType.Varchar2)).Value = userInput;
                    }

                    // Execute the delete query
                    int rowsAffected = command.ExecuteNonQuery();

                    // Show the result to the user
                    MessageBox.Show($"{rowsAffected} rows deleted.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Optionally close the connection here if you're not using it elsewhere
                if (con.State == System.Data.ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }
        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Ensure the connection is closed when the form is closing
            if (con != null && con.State == System.Data.ConnectionState.Open)
            {
                con.Close();
            }
        }
        private void combobox_tabele_update_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Get the selected table from comboBox1
            string selectedTable = combobox_tabele_update.SelectedItem?.ToString();

            // Clear comboBox3 before adding new items
            combobox_coloane_update_set.Items.Clear();
            combobox_coloane_update_where.Items.Clear();

            // Check if a valid table is selected
            if (!string.IsNullOrEmpty(selectedTable))
            {
                try
                {
                    // Prepare the query to get columns of the selected table
                    string query = $"SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '{selectedTable.ToUpper()}'"; // Ensure uppercase for table names

                    // Create a new OracleCommand object
                    using (OracleCommand cmd = new OracleCommand(query, con))
                    {
                        // Open connection if it's not open
                        if (con.State != System.Data.ConnectionState.Open)
                        {
                            con.Open();
                        }

                        // Execute the query and fetch column names
                        using (OracleDataReader reader = cmd.ExecuteReader())
                        {
                            // Check if there are columns available
                            while (reader.Read())
                            {
                                string columnName = reader.GetString(0); // Get the column name
                                combobox_coloane_update_set.Items.Add(columnName); // Add the column name to comboBox3
                                combobox_coloane_update_where.Items.Add(columnName);
                            }
                        }
                    }

                    // Close the connection
                    if (con.State == System.Data.ConnectionState.Open)
                    {
                        con.Close();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error fetching columns: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void buton_update_Click(object sender, EventArgs e)
        {
            // Ensure that all necessary inputs are selected and filled
            if (combobox_tabele_update.SelectedItem == null ||
                combobox_coloane_update_set.SelectedItem == null ||
                combobox_coloane_update_where.SelectedItem == null ||
                string.IsNullOrWhiteSpace(input_set.Text) ||
                string.IsNullOrWhiteSpace(input_where.Text))
            {
                MessageBox.Show("Please select a table, column, and provide values for both the SET and WHERE parts.");
                return;
            }

            // Get the selected table, columns, and input values
            string selectedTable = combobox_tabele_update.SelectedItem.ToString();
            string columnToSet = combobox_coloane_update_set.SelectedItem.ToString();
            string columnToWhere = combobox_coloane_update_where.SelectedItem.ToString();
            string valueToSet = input_set.Text;
            string valueToWhere = input_where.Text;

            // Construct the SQL UPDATE query
            string query = $"UPDATE {selectedTable} SET {columnToSet} = :valueToSet WHERE {columnToWhere} = :valueToWhere";

            // Create the Oracle command with parameters
            using (OracleCommand command = new OracleCommand(query, con))
            {
                // Add parameters with the appropriate data types
                command.Parameters.Add("valueToSet", OracleDbType.Varchar2).Value = valueToSet;
                command.Parameters.Add("valueToWhere", OracleDbType.Varchar2).Value = valueToWhere;

                // Open the connection if it's not open
                if (con.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }

                try
                {
                    // Execute the update query
                    int rowsAffected = command.ExecuteNonQuery();
                    MessageBox.Show($"{rowsAffected} row(s) updated.");
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                finally
                {
                    // Close the connection after executing the command
                    if (con.State == System.Data.ConnectionState.Open)
                    {
                        con.Close();
                    }
                }
            }
        }

        private void butonq_Click(object sender, EventArgs e)
        {
            // Get the SQL query from the RichTextBox
            string query = inputq.Text;

            try
            {
                // Create a command object to execute the query
                using (OracleCommand cmd = new OracleCommand(query, con))
                {
                    // Check if the connection is open, if not, open it
                    if (con.State != System.Data.ConnectionState.Open)
                    {
                        con.Open();
                    }

                    // Create a DataAdapter to fill the DataGridView
                    OracleDataAdapter dataAdapter = new OracleDataAdapter(cmd);
                    DataTable dt = new DataTable(); // Create a DataTable to hold the query results

                    // Fill the DataTable with data
                    dataAdapter.Fill(dt);

                    // Set the DataSource of the DataGridView to the DataTable
                    dataGridView2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                // Display an error message if something goes wrong
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Close the connection if it's open
                if (con.State == System.Data.ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

    }

}
