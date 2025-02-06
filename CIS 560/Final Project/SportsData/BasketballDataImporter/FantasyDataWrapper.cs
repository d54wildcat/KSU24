using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FantasyData.Api.Client;
using FantasyData.Api.Client.Model;
using System.Data.SqlClient;

namespace BasketballDataImporter
{
    public class FantasyDataWrapper
    {
        private FantasyDataClient _client;
        private string _apiKey;
        private string _connectionString;

        public FantasyDataWrapper(string apiKey, string connectionString)
        {
            _client = new FantasyDataClient(apiKey);
            _apiKey = apiKey;
            _connectionString = connectionString;
        }

        public void InsertPlayersIntoTables()
        {
            var playerInfo = _client.CollegeBasketballv3.GetPlayers();


            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();

                foreach(var player in playerInfo)
                {
                    string insertQuery = "INSERT INTO Player([Name] VALUES (@Name)";
                    using (SqlCommand command = new SqlCommand(insertQuery, connection))
                    {
                        command.Parameters.AddWithValue("@Name", $"{player.FirstName} {player.LastName}");
                        command.ExecuteNonQuery();
                    }
                }
            }
        }
    }
}
