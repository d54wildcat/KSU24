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
    /// For that updates a player's information
    /// </summary>
    public partial class UpdatePlayerData : Form
    {
        /// <summary>
        /// Server connection string
        /// </summary>
        private string _connStr;

        /// <summary>
        /// ID for the player being updated
        /// </summary>
        private int _playerID;

        /// <summary>
        /// Form constructor
        /// Sets all fields in the form to the player's current information
        /// </summary>
        /// <param name="playerID">Players primary key</param>
        /// <param name="connectionString"></param>
        public UpdatePlayerData(int playerID, string connectionString)
        {
            InitializeComponent();

            _playerID = playerID;
            _connStr = connectionString;
            DataTable playerInfo = GetPlayerInfo();


            uxPlayerName.Text = (string)playerInfo.Rows[0]["Name"];

            uxHmeTwn_txtBox.Text = (string)playerInfo.Rows[0]["Hometown"];
            uxJrsyNum_numUpDwn.Value = int.Parse((string)playerInfo.Rows[0]["Number"]);
            uxPosition_txtBox.Text = (string)playerInfo.Rows[0]["PrimaryPosition"];
            uxSchlYr_cmboBox.Text = (string)playerInfo.Rows[0]["YearInSchool"];
            uxWeight_numUpDwn.Value = (int)playerInfo.Rows[0]["Weight"];
            uxHeight_numUpDwn.Value = (int)playerInfo.Rows[0]["Height"];
        }

        /// <summary>
        /// Gets the players info we need to use by qureying the Player table
        /// </summary>
        /// <returns>The players queried info as a data table</returns>
        private DataTable GetPlayerInfo()
        {
            DataTable dt = new();
            string script = "SELECT P.[Name], P.Hometown, P.[Number], P.PrimaryPosition, P.YearInSchool, P.[Weight], P.Height " +
                            $"FROM {SqlScript.Schema}.Player P " +
                            $"WHERE P.PlayerID = {_playerID}";
            using (var conn = new SqlConnection(_connStr))
            {
                using (SqlDataAdapter adpt = new SqlDataAdapter())
                {
                    conn.Open();
                    adpt.SelectCommand = new SqlCommand(script, conn);
                    adpt.Fill(dt);
                }
            }
            return dt;
        }

        /// <summary>
        /// Handler for when OK button is clicked, will automaticlly set DialogResult to OK
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxOK_btn_Click(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(_connStr))
            {
                string updateScript = "UPDATE [560_proj_Group09].Player " +
                                      "SET Hometown = @Hometown, [Number] = @Number, PrimaryPosition = @PrimaryPosition, " +
                                            "YearInSchool = @YearInSchool, [Weight] = @Weight, Height = @Height " +
                                      "WHERE PlayerID = @PlayerID";
                using (SqlCommand command = new SqlCommand(updateScript, conn))
                {
                    conn.Open();

                    command.Parameters.AddWithValue("@Hometown", uxHmeTwn_txtBox.Text);
                    command.Parameters.AddWithValue("@Number", Convert.ToString(uxJrsyNum_numUpDwn.Value));
                    command.Parameters.AddWithValue("@PrimaryPosition", uxPosition_txtBox.Text);
                    command.Parameters.AddWithValue("@YearInSchool", (string)uxSchlYr_cmboBox.SelectedItem);
                    command.Parameters.AddWithValue("@Weight", uxWeight_numUpDwn.Value);
                    command.Parameters.AddWithValue("@Height", uxHeight_numUpDwn.Value);
                    command.Parameters.AddWithValue("@PlayerID", _playerID);

                    command.ExecuteNonQuery();
                }
            }

            this.Close();
        }

        /// <summary>
        /// Handler for when canceled is clicked, will automatically set DialogResult to Cancel
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxCancel_btn_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
