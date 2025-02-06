using System;
using System.Net;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using CFBSharp.Api;
using CFBSharp.Client;
using CFBSharp.Model;
using System.Net.Http.Headers;
using NUnit.Framework.Constraints;

namespace FootballAPI
{
    public class PullCollegeFootballAPI
	{
		private readonly string _connectionString;
        private ConferencesApi _conferences;


        public PullCollegeFootballAPI(string connectionString)
		{
			_connectionString = connectionString;
            Configuration.Default.ApiKey.Add("Authorization", "yooyz6srQ5nlsYY6UjvbretkZasnVOHvnCIvKuA/SC00EWxO4ksWSBWpTmd/jGpa\\r\\n");
            Configuration.Default.ApiKeyPrefix.Add("Authorization", "Bearer ");
            _conferences = new ConferencesApi();

        }

        public async Task InsertAPIData()
        {
            ICollection<Conference> conferences = await _conferences.GetConferencesAsync();
            foreach(Conference c in conferences)
            {
                await InsertConferenceIntoDatabase(c);
            }
        }

        private async Task InsertConferenceIntoDatabase(Conference conference)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                string query = "INSERT INTO [560_proj_Group09].Conference (ConferenceID, [Name], ShortName)" +
                                "VALUES (@ConferenceID, @Name, @ShortName);";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    await connection.OpenAsync();

                    command.Parameters.AddWithValue("@ConferenceID", conference.Id) ;
                    command.Parameters.AddWithValue("@Name", conference.Name);
                    command.Parameters.AddWithValue("@ShortName", conference.ShortName);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

    }
}
