using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using FootballAPI;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using BasketballAPI;
using FantasyData.Api.Client;
using System.Security.Cryptography.X509Certificates;
using System.Data.SqlClient;

namespace Refactor
{

    static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            const string connectionString = @"Server=(localdb)\560Final;Integrated Security=true;Database=master;";

            #region FutureAPI stuff
            //Configuration.Default.ApiKey.Add("Authorization", "yooyz6srQ5nlsYY6UjvbretkZasnVOHvnCIvKuA/SC00EWxO4ksWSBWpTmd/jGpa\\r\\n");
            //Configuration.Default.ApiKeyPrefix.Add("Authorization", "Bearer ");
            //PullCollegeFootballAPI api = new PullCollegeFootballAPI(connectionString);
            //api.InsertAPIData().Wait();
            #endregion

            try
            {
                using(SqlConnection conn = new(connectionString))
                {
                    string tryQuery = $"SELECT COUNT(*) FROM {SqlScript.Schema}.Sport; ";

                    using(SqlCommand command = new(tryQuery, conn))
                    {
                        conn.Open();
                        int cnt = (int)command.ExecuteScalar();
                        if (cnt <= 0)
                        {
                            throw new Exception();
                        }

                    }
                }
            }
            catch (Exception ex)
            {
                CBBv3StatsClient fantasyBBClient = new CBBv3StatsClient("eb8cb780dea541bda420ae9469ac748f");
                BasketballDataImporter bdi = new BasketballDataImporter(fantasyBBClient, connectionString);
                bdi.InitializeDatabaseSchemaAsync().Wait();
                bdi.ImportPlayersIntoTables().Wait();
            }


            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();

            SportsDBUI view = new SportsDBUI(connectionString);

            Application.Run(view);
        }
    }
}