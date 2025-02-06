using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Refactor
{
    /// <summary>
    /// Form that demonstrates the aggregating queries for the database
    /// </summary>
    public partial class AggregatingQueries : Form
    {
        /// <summary>
        /// String to connect to sql server
        /// </summary>
        private string _connStr;

        /// <summary>
        /// Constructor for form
        /// </summary>
        /// <param name="connectionString"></param>
        public AggregatingQueries(string connectionString)
        {
            InitializeComponent();

            _connStr = connectionString;
        }

        /// <summary>
        /// Sends script for agg query #1
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxAggOne_btn_Click(object sender, EventArgs e)
        {
            string script = "SELECT C.Name FROM [560_proj_Group09].Coach C " +
                            "JOIN [560_proj_Group09].Team T ON T.TeamID = C.TeamID " +
                            "JOIN [560_proj_Group09].Conference CF ON CF.ConferenceID = T.ConferenceID " +
                            "WHERE CF.Name = N'Big 12' AND C.YearsCoached > 5;";

            DataTable results = QueryFromScript(script);

            FillResultsBox(results, "Name");
        }

        /// <summary>
        /// Sends script for agg query #2
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxAggTwo_btn_Click(object sender, EventArgs e)
        {
            string script = "SELECT P.[Name] FROM [560_proj_Group09].[Player] P " +
                            "JOIN [560_proj_Group09].Team T ON P.TeamKey = T.TeamKey " +
                           $"JOIN [560_proj_Group09].Conference C ON C.ConferenceID = T.ConferenceID AND C.Name = N'{uxConfCmbBox.SelectedItem}' " +
                            "WHERE (P.YearInSchool = N'Junior' OR P.YearInSchool = N'Senior') " +
                            "AND P.PrimaryPosition = N'G' " +
                            "ORDER BY P.YearInSchool ASC; ";

            DataTable results = QueryFromScript(script);

            FillResultsBox(results, "Name");

            return;
        }

        /// <summary>
        /// Sends script for agg query #3
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxAggThree_btn_Click(object sender, EventArgs e)
        {
            string script = "SELECT T.SchoolName FROM [560_proj_Group09].Team T " +
                            "WHERE ( SELECT COUNT(P.PlayerID) FROM [560_proj_Group09].[Player] P " +
                                "WHERE P.TeamKey = T.TeamKey " +
                            ") < 14;";

            DataTable results = QueryFromScript(script);

            FillResultsBox(results, "SchoolName");

            return;
        }

        /// <summary>
        /// Sends script for agg query #4
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxAggFour_btn_Click(object sender, EventArgs e)
        {
            string script = "SELECT P.[Name], P.Number FROM [560_proj_Group09].[Player] P " +
                            "JOIN [560_proj_Group09].[Team] T ON T.TeamKey = P.TeamKey " +
                           $"JOIN [560_proj_Group09].Conference C ON C.ConferenceID = T.ConferenceID AND C.Name = N'{uxConfCmbBox.SelectedItem}' " +
                           $"WHERE P.Number > {(int)uxJersyNumUpDwn.Value} " +
                           $"AND P.Height > 77;";

            DataTable results = QueryFromScript(script);

            FillResultsBox(results, "Name");
        }

        /// <summary>
        /// Executes <paramref name="sqlScript"/> and gets resulting table
        /// </summary>
        /// <param name="sqlScript">Script being executed</param>
        /// <returns>The resulting table from query as a DataTable</returns>
        private DataTable QueryFromScript(string sqlScript)
        {
            DataTable dt = new();

            // DataAdapter
            using (var conn = new SqlConnection(_connStr))
            {
                using (SqlDataAdapter adpt = new SqlDataAdapter())
                {
                    conn.Open();
                    adpt.SelectCommand = new SqlCommand(sqlScript, conn);
                    adpt.Fill(dt);
                }
            }
            return dt;
        }

        /// <summary>
        /// Fills the Listbox with data from <paramref name="colName"/> in <paramref name="table"/>
        /// </summary>
        /// <param name="table">Data table that was queried</param>
        /// <param name="colName">column that data being displayed in list is in</param>
        private void FillResultsBox(DataTable table, string colName)
        {
            List<string> list = new();
            foreach (var row in table.AsEnumerable())
            {
                list.Add((string)row[colName]);
            }

            uxResultBox.DataSource = list;
        }

        /// <summary>
        /// Done button, closes form
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxDone_btn_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
