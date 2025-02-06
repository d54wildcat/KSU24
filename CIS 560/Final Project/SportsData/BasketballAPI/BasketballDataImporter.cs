using System.Data;
using System.Collections.Generic;
using System.Data.SqlClient;
using FantasyData.Api.Client;
using FantasyData.Api.Client.Model;
using System.Numerics;
using FantasyData.Api.Client.Model.CBB;
using System.Text.RegularExpressions;

namespace BasketballAPI
{
    public class BasketballDataImporter
    {
        //String to use for connecting to the SQL database
        private readonly string _connectionString;
        //Api client we are connecting to in order to pull the data we need.
        private readonly CBBv3StatsClient _fantasyDataClient;

        /// <summary>
        /// Constructor for the Data Importer
        /// </summary>
        /// <param name="client">API we're using</param>
        /// <param name="connectionString">connection to the SQL database</param>
        public BasketballDataImporter(CBBv3StatsClient client, string connectionString)
        {
            _fantasyDataClient = client;
            _connectionString = connectionString;
        }

        /// <summary>
        /// Sets up the Database if not already set up.
        /// </summary>
        public async Task InitializeDatabaseSchemaAsync()
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                string debugPathBuff = "..\\..\\..\\..\\..\\";
                string script = File.ReadAllText(debugPathBuff + "Scripts\\DBTCreateTables.sql");
                await connection.OpenAsync();
                SqlCommand command = new SqlCommand(script, connection);
                await command.ExecuteNonQueryAsync();
            }
        }

        /// <summary>
        /// Used to import all of the player information from the API into the database after checking to see if the 
        /// data is already present in the database. If it is, it skips over that section and moves on.
        /// </summary>
        public async Task ImportPlayersIntoTables()
        {
            //This checks to see if the data has already been pulled into the tables. This will not work if you want to update the table.
            bool playerDataExists = await CheckIfDataExists("Player");
            bool teamDataExists = await CheckIfDataExists("Team");
            bool schoolDataExists = await CheckIfDataExists("School");
            bool sportDataExists = await CheckIfDataExists("Sport");
            //bool seasonDataExists = await CheckIfDataExists("Season"); //Future
            bool conferenceDataExists = await CheckIfDataExists("Conference");
            bool coachDataExists = await CheckIfDataExists("Coach");
            //bool conferenceSeasonDataExists = await CheckIfDataExists("ConferenceSeason"); //Future
            //bool teamSeasonDataExists = await CheckIfDataExists("TeamSeason"); //Future
            //Do this for all of the tables.

            if (!await SportExists("Basketball"))
            {
                //Adds basketball to sports section
                await InsertSport("Basketball");
            }

            if (!conferenceDataExists)
            {
                //Conference Data into table
                await InsertConferences();
            }

            if (!teamDataExists)
            {
                List<Team> teams = await _fantasyDataClient.GetTeamsAsync();

                foreach (Team team in teams)
                {
                    await InsertSchool(team.School);

                    await InsertTeam(team);
                }
            }

            if (!coachDataExists)
            {
                await InsertCoaches();
            }

            //Pulls Player table data
            if (!playerDataExists)
            {
                List<Player> players = await _fantasyDataClient.GetPlayersAsync();
                List<Team> teams = await _fantasyDataClient.GetTeamsAsync();

                foreach (Player player in players)
                {
                    string teamKey = teams.FirstOrDefault(t => t.Key == player.Team)?.Key;
                    string playerName = player.FirstName + " " + player.LastName;
                    string primaryPosition = player.Position ?? "";
                    string hometown = $"{player.BirthCity}, {player.BirthState}";
                    int playerId = player.PlayerID;

                    if (await PlayerExists(playerName, primaryPosition, hometown))
                    {
                        continue;
                    }

                    using (SqlConnection connection = new SqlConnection(_connectionString))
                    {
                        await connection.OpenAsync();

                        string setIdentityInsertOn = "SET IDENTITY_INSERT [560_proj_Group09].Player ON";
                        SqlCommand setIdentityInsertOnCommand = new SqlCommand(setIdentityInsertOn, connection);
                        await setIdentityInsertOnCommand.ExecuteNonQueryAsync();

                        string insertCommand = "INSERT INTO [560_proj_Group09].Player (PlayerID, [Name], PrimaryPosition, Hometown, TeamKey, [Number], YearInSchool, [Weight], Height) " +
                                                "VALUES (@PlayerID, @Name, @PrimaryPosition, @Hometown, @TeamKey, @Number, @YearInSchool, @Weight, @Height)";

                        using (SqlCommand command = new SqlCommand(insertCommand, connection))
                        {
                            command.Parameters.AddWithValue("@PlayerID", playerId);
                            command.Parameters.AddWithValue("@Name", playerName);
                            command.Parameters.AddWithValue("@PrimaryPosition", primaryPosition);
                            command.Parameters.AddWithValue("@Hometown", hometown);
                            command.Parameters.AddWithValue("@TeamKey", player.Team ?? "");
                            command.Parameters.AddWithValue("@Number", player.Jersey ?? 0);
                            command.Parameters.AddWithValue("@YearInSchool", player.Class ?? "");
                            command.Parameters.AddWithValue("@Weight", player.Weight ?? 0);
                            command.Parameters.AddWithValue("@Height", player.Height ?? 0);

                            await command.ExecuteNonQueryAsync();
                        }
                    }
                }
            }


            // For future use: Allows the addition of Seasons, TeamSeasons, ConferenceSeasons, etc.
            /*if (!seasonDataExists)
            {
                await ImportSeasonData();
            }

            if (!conferenceSeasonDataExists)
            {
                await InsertConferenceSeason();
            }

            

            if (!teamSeasonDataExists)
           {
                await InsertTeamSeason();
           }*/
        }


        ///////////////////////////////////////////////////////////////////////////////////Everything below is for the teams model

        /// <summary>
        /// Gets the conferenceID for each conference from the GetConferences class.
        /// </summary>
        /// <returns></returns>
        public async Task InsertConferences()
        {
            List<string> conferenceNames = GetConferences.GetConferenceNames();

            foreach (string conferenceName in conferenceNames)
            {
                int conferenceID = await InsertConference(conferenceName);
            }
        }

        //Actual method that sends the SQL command to insert the conference name and abbreviation as well as the ConferenceID
        private async Task<int> InsertConference(string conferenceName)
        {
            string shortName = GetConferences.ConferenceNamesAndAbv[conferenceName];

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string insertCommand = "INSERT INTO [560_proj_Group09].Conference ([Name], ShortName) " +
                                       "VALUES (@ConferenceName, @ShortName);" +
                                       "SELECT SCOPE_IDENTITY();";

                using (SqlCommand command = new SqlCommand(insertCommand, connection))
                {
                    command.Parameters.AddWithValue("@ConferenceName", conferenceName);
                    command.Parameters.AddWithValue("@ShortName", shortName);

                    // Execute the insert command and retrieve the new conference ID
                    int conferenceID = Convert.ToInt32(await command.ExecuteScalarAsync());
                    return conferenceID;
                }
            }
        }

        /// <summary>
        /// Gets all the coaches from the GetCoaches class and gets the necessary information to send to the method that will INSERT the data into the table.
        /// </summary>
        public async Task InsertCoaches()
        {
            var coachesAndYearsAndTeamID = GetCoaches.CoachesAndYearsAndTeamID;

            foreach (var coachEntry in coachesAndYearsAndTeamID)
            {
                string coachName = coachEntry.Key;
                int yearsCoached = coachEntry.Value.Item1;
                int teamID = coachEntry.Value.Item2;

                await InsertCoach(coachName, yearsCoached, teamID);
            }
        }

        //Actual method that sends the SQL command to insert the conference name and abbreviation
        private async Task<int> InsertCoach(string coachName, int yearsCoached, int teamID)
        {

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string insertCommand = "INSERT INTO [560_proj_Group09].Coach ([Name], Hometown, YearsCoached, TeamID) " +
                                        "VALUES (@CoachName, @Hometown, @YearsCoached, @TeamID);" +
                                        "SELECT SCOPE_IDENTITY();";

                using (SqlCommand command = new SqlCommand(insertCommand, connection))
                {
                    command.Parameters.AddWithValue("@CoachName", coachName);
                    command.Parameters.AddWithValue("@Hometown", "");
                    command.Parameters.AddWithValue("@YearsCoached", yearsCoached);
                    command.Parameters.AddWithValue("@TeamID", teamID);

                    object result = await command.ExecuteScalarAsync();
                    if (result != null && int.TryParse(result.ToString(), out int coachID))
                    {
                        return coachID;
                    }
                    else
                    {
                        throw new Exception("Unable to retrieve the coach ID after insertion.");
                    }
                }
            }
        }


        //Helper Method to insert the school name into the correct table
        private async Task InsertSchool(string schoolName)
        {
            if (await SchoolExists(schoolName))
            {
                return;
            }

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string insertCommand = "INSERT INTO [560_proj_Group09].School (SchoolName) " +
                                        "VALUES (@SchoolName)";

                using (SqlCommand command = new SqlCommand(insertCommand, connection))
                {
                    command.Parameters.AddWithValue("@SchoolName", schoolName);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        //Helper method to check for duplicate schools.
        private async Task<bool> SchoolExists(string schoolName)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = "SELECT COUNT(*) FROM [560_proj_Group09].School WHERE SchoolName = @SchoolName";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@SchoolName", schoolName);

                    int count = (int)await command.ExecuteScalarAsync();
                    return count > 0;
                }
            }
        }


        //Helper method to insert the Sport name.
        private async Task InsertSport(string sportName)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string insertCommand = "INSERT INTO [560_proj_Group09].Sport (SportName) " +
                                        "VALUES (@SportName)";

                using (SqlCommand command = new SqlCommand(insertCommand, connection))
                {
                    command.Parameters.AddWithValue("@SportName", sportName);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        //Checks if the sport exists 
        private async Task<bool> SportExists(string sportName)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = "SELECT COUNT(*) FROM [560_proj_Group09].Sport WHERE SportName = @SportName";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@SportName", sportName);

                    int count = (int)await command.ExecuteScalarAsync();
                    return count > 0;
                }
            }
        }

        /// <summary>
        /// Method to insert all the teams into the database. If the team is already present in the database it skips that and moves on.
        /// </summary>
        /// <param name="team"></param>
        /// <returns></returns>
        private async Task InsertTeam(Team team)
        {
            // If the school is already in the database or ConferenceID is null, skip insertion.
            if (await TeamExists(team.School) || team.ConferenceID == null)
            {
                return;
            }

            int teamID = team.TeamID;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                // Sets the Identity Insert to On for the table so we can pull the unique ID from the database
                string setIdentityInsertOn = "SET IDENTITY_INSERT [560_proj_Group09].Team ON";
                SqlCommand setIdentityInsertOnCommand = new SqlCommand(setIdentityInsertOn, connection);
                await setIdentityInsertOnCommand.ExecuteNonQueryAsync();

                string insertCommand = "INSERT INTO [560_proj_Group09].Team (TeamID, SportName, SchoolName, TeamKey, ConferenceID) " +
                                        "VALUES (@TeamID, @SportName, @SchoolName, @TeamKey, @ConferenceID);";
                // Add another number onto the front of the ID for football when get there.

                using (SqlCommand command = new SqlCommand(insertCommand, connection))
                {
                    command.Parameters.AddWithValue("@TeamID", teamID);
                    command.Parameters.AddWithValue("@SportName", "Basketball");
                    command.Parameters.AddWithValue("@SchoolName", team.School);
                    command.Parameters.AddWithValue("@TeamKey", team.Key ?? "");
                    command.Parameters.AddWithValue("@ConferenceID", team.ConferenceID);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        //Helper method to check if the school already exists in the database.
        private async Task<bool> TeamExists(string schoolName)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = "SELECT COUNT(*) FROM [560_proj_Group09].Team WHERE SchoolName = @SchoolName";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@SchoolName", schoolName);

                    int count = (int)await command.ExecuteScalarAsync();
                    return count > 0;
                }
            }
        }


        ///////////////////////////////////////////////////////////////////////////////////Everything above is for the Teams Model

        /// <summary>
        /// Helper method to see if the player already exists in the database
        /// </summary>
        /// <param name="name">Players name</param>
        /// <param name="position">Players position</param>
        /// <param name="hometown">Players hometown</param>
        /// <returns>T/F if the player exists</returns>
        private async Task<bool> PlayerExists(string name, string position, string hometown)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = "SELECT COUNT(*) FROM [560_proj_Group09].Player WHERE [Name] = @Name AND PrimaryPosition = @PrimaryPosition AND Hometown = @Hometown";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@Name", name);
                    command.Parameters.AddWithValue("@PrimaryPosition", position ?? "");
                    command.Parameters.AddWithValue("@Hometown", hometown);

                    int count = (int)await command.ExecuteScalarAsync();
                    return count > 0;
                }
            }
        }

        //Checks if the data has already been pulled(Not the same as Player or Team exists)
        private async Task<bool> CheckIfDataExists(string tableName)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = $"SELECT COUNT(*) FROM [560_proj_Group09].{tableName}";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    int count = (int)await command.ExecuteScalarAsync();
                    return count > 0;
                }
            }
        }

        ///Everything below this can be used to add almost everything related to Seasons into the database. Ran out of time to fully implement.
        // Inserts the ConferenceSznID into the ConferenceSeason Table as well as the ConferenceID and seasonID
        /*private async Task InsertConferenceSeason()
        {
            List<(int, int)> conferenceSeasonList = new List<(int, int)>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                // Get all unique combinations of ConferenceID and SeasonID
                string query = "SELECT DISTINCT c.ConferenceID, s.SeasonID " +
                                "FROM [560_proj_Group09].Conference c, [560_proj_Group09].Season s";

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = await command.ExecuteReaderAsync())
                {
                    while (reader.Read())
                    {
                        int conferenceID = reader.GetInt32(0);
                        int seasonID = reader.GetInt32(1);
                        conferenceSeasonList.Add((conferenceID, seasonID));
                    }
                }
            }

            foreach (var tuple in conferenceSeasonList)
            {
                int conferenceID = tuple.Item1;
                int seasonID = tuple.Item2;
                int conferenceSznID = GenerateConferenceSeasonID(conferenceID, seasonID);

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    string setIdentityInsertOn = "SET IDENTITY_INSERT [560_proj_Group09].ConferenceSeason ON";
                    SqlCommand setIdentityInsertOnCommand = new SqlCommand(setIdentityInsertOn, connection);
                    await setIdentityInsertOnCommand.ExecuteNonQueryAsync();

                    string insertCommand = "INSERT INTO [560_proj_Group09].ConferenceSeason (ConferenceSznID, ConferenceID, SeasonID) " +
                                           "VALUES (@ConferenceSznID, @ConferenceID, @SeasonID)";

                    using (SqlCommand insert = new SqlCommand(insertCommand, connection))
                    {
                        insert.Parameters.AddWithValue("@ConferenceSznID", conferenceSznID);
                        insert.Parameters.AddWithValue("@ConferenceID", conferenceID);
                        insert.Parameters.AddWithValue("@SeasonID", seasonID);

                        await insert.ExecuteNonQueryAsync();
                    }
                }
            }
        }

        // Method to generate ConferenceSznID using ConferenceID and SeasonID
        private int GenerateConferenceSeasonID(int conferenceID, int seasonID)
        {
            // Concatenate ConferenceID and SeasonID to create a unique identifier
            // For example, if ConferenceID is 1 and SeasonID is 2022, ConferenceSznID could be 12022
            return int.Parse($"{conferenceID}{seasonID}");
        }


        private async Task InsertTeamSeason()
        {
            using (SqlConnection outerConnection = new SqlConnection(_connectionString))
            {
                await outerConnection.OpenAsync();

                // Get all unique combinations of TeamID and ConferenceSznID
                string query = "SELECT DISTINCT t.TeamID, cs.ConferenceSznID " +
                                "FROM [560_proj_Group09].Team t, [560_proj_Group09].ConferenceSeason cs";

                using (SqlCommand outerCommand = new SqlCommand(query, outerConnection))
                using (SqlDataReader outerReader = await outerCommand.ExecuteReaderAsync())
                {
                    while (outerReader.Read())
                    {
                        int teamID = outerReader.GetInt32(0);
                        int conferenceSznID = outerReader.GetInt32(1);
                        int teamSznID = GenerateTeamSeasonID(teamID, conferenceSznID);

                        using (SqlConnection innerConnection = new SqlConnection(_connectionString))
                        {
                            await innerConnection.OpenAsync();

                            // Check if the record already exists
                            string checkIfExistsQuery = "SELECT COUNT(*) FROM [560_proj_Group09].TeamSeason WHERE TeamSznID = @TeamSznID";

                            using (SqlCommand checkIfExistsCommand = new SqlCommand(checkIfExistsQuery, innerConnection))
                            {
                                checkIfExistsCommand.Parameters.AddWithValue("@TeamSznID", teamSznID);

                                int existingCount = (int)await checkIfExistsCommand.ExecuteScalarAsync();

                                // If the record already exists, skip the insertion
                                if (existingCount > 0)
                                {
                                    continue;
                                }
                            }

                            // If the record does not exist, proceed with insertion
                            string insertCommand = "INSERT INTO [560_proj_Group09].TeamSeason (TeamSznID, TeamID, ConferenceSznID) " +
                                                   "VALUES (@TeamSznID, @TeamID, @ConferenceSznID)";

                            using (SqlCommand insert = new SqlCommand(insertCommand, innerConnection))
                            {
                                insert.Parameters.AddWithValue("@TeamSznID", teamSznID);
                                insert.Parameters.AddWithValue("@TeamID", teamID);
                                insert.Parameters.AddWithValue("@ConferenceSznID", conferenceSznID);

                                await insert.ExecuteNonQueryAsync();
                            }
                        }
                    }
                }
            }
        }

        private int GenerateTeamSeasonID(int teamID, int seasonID)
        {
            // Concatenate TeamID and SeasonID to create a unique identifier
            // For example, if TeamID is 6540 and SeasonID is 2022, TeamSznID could be 65402022
            return int.Parse($"{teamID}{seasonID}");
        }



        Populates the Season Table with the ID being the year and then the Description being the years the season went through
        private async Task ImportSeasonData()
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string setIdentityInsertOn = "SET IDENTITY_INSERT [560_proj_Group09].Season ON";
                SqlCommand setIdentityInsertOnCommand = new SqlCommand(setIdentityInsertOn, connection);
                await setIdentityInsertOnCommand.ExecuteNonQueryAsync();

                // Insert seasons from 2010 to 2024
                for (int year = 2010; year <= 2024; year++)
                {
                    string years = GetSeasonDescription(year);

                    string insertCommand = "INSERT INTO [560_proj_Group09].Season (SeasonID, [Year]) " +
                                            "VALUES (@SeasonID,@Year)";

                    using (SqlCommand command = new SqlCommand(insertCommand, connection))
                    {
                        command.Parameters.AddWithValue("@SeasonID", year);
                        command.Parameters.AddWithValue("@Year", years);

                        await command.ExecuteNonQueryAsync();

                    }
                }
            }
        }

        //Helper method to get the correct years i.e. 2018-2019, 2012-2013, etc.
        private string GetSeasonDescription(int year)
        {
            // Generate the season description based on the year
            // Example: "2017-18", "2018-19", etc.
            return $"{year}-{year + 1}";
        }*/
    }
}

