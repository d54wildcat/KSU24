using OpenQA.Selenium.DevTools.V121.Network;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Drawing;
using System.Linq;
using System.Net.Security;
using System.Security.AccessControl;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Refactor
{
    /// <summary>
    /// Userinterface form
    /// </summary>
    public partial class SportsDBUI : Form
    {
        /// <summary>
        /// Gives the current state view the UI is in
        /// </summary>
        private GUIStates _currState;

        /// <summary>
        /// Gives the connection string used to connect to the database
        /// </summary>
        private string _connStr;

        /// <summary>
        /// Stack is used to store the previous state, main sql script, and view title
        /// </summary>
        private Stack<ValueTuple<GUIStates, SqlScript, IEntityObject>> _treeStack;

        /// <summary>
        /// Main list that is displayed in the entity box
        /// </summary>
        private IList<IEntityObject> _entityList;

        /// <summary>
        /// The current main script
        /// </summary>
        private SqlScript _curScript;

        /// <summary>
        /// Constructor for the UI form
        /// </summary>
        /// <param name="connStr">string used to connect to sql database</param>
        public SportsDBUI(string connStr)
        {
            InitializeComponent();
            _connStr = connStr;

            _treeStack = new();
            ValueTuple<GUIStates, SqlScript, IEntityObject> vt = new(GUIStates.SportView, new SqlScript("Sport", "SportName"), new StartObj());
            _treeStack.Push(vt);

            _curScript = _treeStack.Peek().Item2;
            _entityList = GetDBTableItems(_curScript, "Sport");

            UpdateUI();
        }

        /// <summary>
        /// Seearch the current view for 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxSearchButton_Click(object sender, EventArgs e)
        {
            if (uxSearchBox.Text != "")
            {
                string searchQ = uxSearchBox.Text;
                foreach (IEntityObject entity in _entityList)
                {
                    if ((entity.ToString().ToLower()).Equals(searchQ.ToLower().Trim()))
                    {
                        uxEntityBox.SelectedIndex = _entityList.IndexOf(entity);
                        MoveToNextEnity();
                        return;
                    }
                }

                uxInvalidSearch.Visible = true;
            }
        }

        /// <summary>
        /// Updates the UI based on the current state in the tree stack
        /// </summary>
        public void UpdateUI()
        {
            ValueTuple<GUIStates, SqlScript, IEntityObject> vt = _treeStack.Peek();
            GUIStates state = vt.Item1;
            uxEntityName.Text = vt.Item3.ToString();
            _currState = state;
            uxEntityBox.DataSource = _entityList;
            uxEntityBox.SelectedIndex = -1;
            List<IEntityObject>? filterBoxItems = null;

            switch (_currState)
            {
                case GUIStates.SportView:
                    uxForwardBtn.Enabled = true;
                    uxBackwardBtn.Enabled = false;
                    uxSetFilterBtn.Enabled = false;
                    uxUpdateInfo.Enabled = false;
                    uxSearchButton.Enabled = true;
                    uxInvalidSearch.Visible = false;
                    uxSearchBox.Text = "";
                    uxSearchLbl.Text = $"Search Sports";
                    uxInfoLbl_One.Text = "";
                    uxInfoLbl_Two.Text = "";
                    uxInfoLbl_Three.Text = "";
                    uxInfoLbl_Four.Text = "";
                    uxInfoLbl_Five.Text = "";
                    uxInfoLbl_Six.Text = "";
                    break;
                case GUIStates.TeamView:
                    uxForwardBtn.Enabled = true;
                    uxBackwardBtn.Enabled = true;
                    uxSetFilterBtn.Enabled = true;
                    uxUpdateInfo.Enabled = false;
                    uxSearchButton.Enabled = true;
                    uxInvalidSearch.Visible = false;
                    uxSearchBox.Text = "";
                    uxSearchLbl.Text = $"Search Teams";
                    uxInfoLbl_One.Text = "";
                    uxInfoLbl_Two.Text = "";
                    uxInfoLbl_Three.Text = "";
                    uxInfoLbl_Four.Text = "";
                    uxInfoLbl_Five.Text = "";
                    uxInfoLbl_Six.Text = "";
                    filterBoxItems = GetTeamViewFilterObjects();
                    break;
                case GUIStates.PlayerView:
                    uxForwardBtn.Enabled = true;
                    uxBackwardBtn.Enabled = true;
                    uxSetFilterBtn.Enabled = true;
                    uxUpdateInfo.Enabled = false;
                    uxSearchButton.Enabled = true;
                    uxInvalidSearch.Visible = false;
                    uxSearchBox.Text = "";
                    uxSearchLbl.Text = $"Search Players";
                    uxInfoLbl_One.Text = "Current Conference: " + QueryForData(
                                                                                int.Parse(QueryForData(vt.Item3.GetID(), "ConferenceID", "Team", false)!),
                                                                                "Name",
                                                                                "Conference");
                    uxInfoLbl_Two.Text = "Current Head Coach: " + QueryFromCoachTable(vt.Item3.GetID(), "Name");
                    uxInfoLbl_Three.Text = "Number of years coached at this team: " + QueryFromCoachTable(vt.Item3.GetID(), "YearsCoached", false);
                    uxInfoLbl_Four.Text = "";
                    uxInfoLbl_Five.Text = "";
                    uxInfoLbl_Six.Text = "";
                    TeamObj t = vt.Item3 as TeamObj;
                    filterBoxItems = GetPlayerViewFilterObjects(t!.TeamKey);
                    break;
                case GUIStates.PlayerInfoView:
                    uxForwardBtn.Enabled = false;
                    uxBackwardBtn.Enabled = true;
                    uxSetFilterBtn.Enabled = false;
                    uxUpdateInfo.Enabled = true;
                    uxSearchButton.Enabled = false;
                    uxInvalidSearch.Visible = false;
                    uxSearchBox.Text = "";
                    uxSearchLbl.Text = "";
                    uxInfoLbl_One.Text = "Hometown: " + QueryForData(vt.Item3.GetID(), "Hometown", "Player");
                    uxInfoLbl_Two.Text = "Year in School: " + QueryForData(vt.Item3.GetID(), "YearInSchool", "Player");
                    uxInfoLbl_Three.Text = "Jersey Number: " + int.Parse(QueryForData(vt.Item3.GetID(), "Number", "Player", false)!);
                    uxInfoLbl_Four.Text = "Primary Position: " + QueryForData(vt.Item3.GetID(), "PrimaryPosition", "Player");
                    uxInfoLbl_Five.Text = "Weight: " + int.Parse(QueryForData(vt.Item3.GetID(), "Weight", "Player", false)!) + " lbs.";
                    uxInfoLbl_Six.Text = "Height: " + int.Parse(QueryForData(vt.Item3.GetID(), "Height", "Player", false)!) + " inches.";
                    break;
                default:
                    break;
            }

            uxEnityFiltersBox.Items.Clear();
            if (filterBoxItems != null)
            {
                foreach (IEntityObject item in filterBoxItems)
                {
                    uxEnityFiltersBox.Items.Add(item);
                }
            }
            uxEnityFiltersBox.Update();
        }

        /// <summary>
        /// For getting table in the Team or Player Table.
        /// </summary>
        /// <param name="objID"></param>
        /// <param name="data"></param>
        /// <param name="tblName"></param>
        /// <returns></returns>
        private string? QueryForData(int objID, string data, string tblName, bool nonInt = true)
        {
            try
            {
                SqlScript script = new(tblName, data);
                script.WhereClauseLines.Add($"WHERE a.{tblName}ID = {objID}");
                DataTable dt = MakeDTFromQuery(script.ToString());

                if (nonInt)
                    return (string)dt.Rows[0][data];
                else
                {
                    return Convert.ToString(dt.Rows[0][data]);
                }
            }
            catch (Exception e)
            {
                return "";
            }

        }

        /// <summary>
        /// For getting table in the Coach Table.
        /// </summary>
        /// <param name="teamID"></param>
        /// <param name="returnColName"></param>
        /// <param name="nonInt"></param>
        /// <returns></returns>
        private string? QueryFromCoachTable(int teamID, string returnColName, bool nonInt = true)
        {
            try
            {
                SqlScript script = new("Coach", returnColName);
                script.WhereClauseLines.Add($"WHERE a.TeamID = {teamID}");
                DataTable dt = MakeDTFromQuery(script.ToString());

                if (nonInt)
                    return (string)dt.Rows[0][returnColName];
                else
                {
                    return Convert.ToString(dt.Rows[0][returnColName]);
                }
            }
            catch (Exception e)
            {
                return "";
            }
        }

        /// <summary>
        /// Moves foward in the UI to the next selected entity
        /// </summary>
        private void MoveToNextEnity()
        {
            int index = uxEntityBox.SelectedIndex;
            List<IEntityObject>? l = uxEntityBox.DataSource as List<IEntityObject>;
            IEntityObject selectedName = l![index];
            GUIStates nextState = 0;
            SqlScript newScript = new();

            string enity = "";
            switch (_currState)
            {
                case GUIStates.SportView:
                    nextState = GUIStates.TeamView;

                    newScript.OgTblName = "Team"; newScript.SelectCol = "SchoolName, a.TeamID, a.TeamKey";
                    newScript.JoinTableLines.Add($"JOIN {SqlScript.Schema}.Sport S ON a.SportName = S.SportName ");
                    newScript.JoinTableLines.Add($"JOIN {SqlScript.Schema}.Conference C ON C.ConferenceID = a.ConferenceID ");
                    newScript.WhereClauseLines.Add($"WHERE S.SportName = N'{selectedName.ToString()}' ");

                    enity = "Team";

                    _curScript = newScript;
                    _entityList = GetDBTableItems(newScript, enity);

                    break;

                case GUIStates.TeamView:
                    nextState = GUIStates.PlayerView;

                    newScript.OgTblName = "Player"; newScript.SelectCol = "Name, a.PlayerID";
                    newScript.JoinTableLines.Add($"JOIN {SqlScript.Schema}.Team T ON a.TeamKey = T.TeamKey ");
                    newScript.JoinTableLines.Add($"JOIN {SqlScript.Schema}.Sport S ON T.SportName = S.SportName ");
                    //newScript.JoinTableLines.Add($"JOIN {SqlScript.Schema}.Conference C ON C.ConferenceID = T.ConferenceID ");
                    newScript.WhereClauseLines.Add($"WHERE S.SportName = N'{_treeStack.Peek().Item3}' AND T.SchoolName = N'{selectedName.ToString()}' ");

                    enity = "Player";

                    _curScript = newScript;
                    _entityList = GetDBTableItems(newScript, enity);

                    break;

                case GUIStates.PlayerView:
                    _entityList = new List<IEntityObject>();
                    nextState = GUIStates.PlayerInfoView;
                    break;
            }

            ValueTuple<GUIStates, SqlScript, IEntityObject> vt = new(nextState, newScript, selectedName);
            _treeStack.Push(vt);

            UpdateUI();
        }

        /// <summary>
        /// Event handler for the entity box foward button
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxForwardBtn_Click(object sender, EventArgs e)
        {
            if (uxEntityBox.SelectedIndex >= 0)
            {
                MoveToNextEnity();
            }
        }

        /// <summary>
        /// Event handler for the entity box backwards button
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxBackwardBtn_Click(object sender, EventArgs e)
        {
            _treeStack.Pop();
            _curScript = _treeStack.Peek().Item2;
            string entity = "";
            switch (_currState)
            {
                case GUIStates.TeamView:
                    entity = "Sport";
                    break;
                case GUIStates.PlayerView:
                    entity = "Team";
                    break;
                case GUIStates.PlayerInfoView:
                    entity = "Player";
                    break;
            }
            _entityList = GetDBTableItems(_curScript, entity);
            UpdateUI();
        }

        /// <summary>
        /// Gets a list of items for the entity box based on <paramref name="scriptObj"/>
        /// </summary>
        /// <param name="scriptObj">Script object's string is used to query DB</param>
        /// <returns></returns>
        private IList<IEntityObject> GetDBTableItems(SqlScript scriptObj, string enity)
        {
            List<IEntityObject> list = new();
            DataTable dt = MakeDTFromQuery(scriptObj.ToString());

            switch (enity)
            {
                case "Sport":
                    foreach (var row in dt.AsEnumerable())
                    { list.Add(new SportObj((string)row["SportName"])); }
                    break;
                case "Team":
                    foreach (var row in dt.AsEnumerable())
                    { list.Add(new TeamObj((int)row["TeamID"], (string)row["SchoolName"], (string)row["TeamKey"])); }
                    break;
                case "Player":
                    foreach (var row in dt.AsEnumerable())
                    { list.Add(new PlayerObj((int)row["PlayerID"], (string)row["Name"])); }
                    break;

            }
            return list;

            //var list = (from rw in dt.AsEnumerable() select rw[scriptObj.SelectCol].ToString()).ToList();
            //return list;
        }

        /// <summary>
        /// Overload of <see cref="GetDBTableItems(SqlScript, string)"/> but with the script as a string and column if defined
        /// </summary>
        /// <param name="script">Script object's string is used to query DB</param>
        /// <param name="enity">Table column to get data from</param>
        /// <returns></returns>
        private IList<IEntityObject> GetDBTableItems(string script, string enity)
        {
            List<IEntityObject> list = new();
            DataTable dt = MakeDTFromQuery(script);

            switch (enity)
            {
                case "Sport":
                    foreach (var row in dt.AsEnumerable())
                    { list.Add(new SportObj((string)row["SportName"])); }
                    break;
                case "Team":
                    foreach (var row in dt.AsEnumerable())
                    { list.Add(new TeamObj((int)row["TeamID"], (string)row["SchoolName"], (string)row["TeamKey"])); }
                    break;
                case "Player":
                    foreach (var row in dt.AsEnumerable())
                    { list.Add(new PlayerObj((int)row["PlayerID"], (string)row["Name"])); }
                    break;

            }
            return list;

            //var list = (from rw in dt.AsEnumerable() select rw[scriptObj.SelectCol].ToString()).ToList();
            //return list;
        }

        /// <summary>
        /// Gets query from <paramref name="script"/>
        /// </summary>
        /// <param name="script">script that is being querried</param>
        /// <returns>Data Table of the resulting query from script</returns>
        private DataTable MakeDTFromQuery(string script)
        {
            DataTable dt = new();

            // DataAdapter
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
        /// Gets filter obeject for team view filter box
        /// </summary>
        /// <returns>List of objects to be added to filter box</returns>
        private List<IEntityObject> GetTeamViewFilterObjects()
        {
            SqlScript script = new("[Conference]", "ConferenceID, [Name], ShortName");
            DataTable dt = MakeDTFromQuery(script.ToString());
            List<IEntityObject> l = new();

            foreach (var row in dt.AsEnumerable())
            {
                ConferenceObj conf = new((int)row["ConferenceID"], (string)row["Name"], (string)row["ShortName"]);
                l.Add(conf);
            }

            return l;
        }

        /// <summary>
        /// Gets filter obejects for player view filter box
        /// </summary>
        /// <param name="teamKey">The team that player belongs to</param>
        /// <returns></returns>
        private List<IEntityObject> GetPlayerViewFilterObjects(string teamKey)
        {
            SqlScript script = new("Player", "PrimaryPosition");
            script.WhereClauseLines.Add($"WHERE a.TeamKey = N'{teamKey}' GROUP BY a.PrimaryPosition ");

            DataTable dt = MakeDTFromQuery(script.ToString());
            List<IEntityObject> l = new();

            foreach (var row in dt.AsEnumerable())
            {
                l.Add(new PosObj((string)row["PrimaryPosition"]));
            }

            return l;
        }

        /// <summary>
        /// Handles for when the set filter button is clicked
        /// If no filter items are selected, original query will be displayed
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxSetFilterBtn_Click(object sender, EventArgs e)
        {
            if (uxEnityFiltersBox.CheckedItems.Count > 0)
            {
                string s = "";
                string entity = "";
                switch (_currState)
                {
                    case GUIStates.TeamView:
                        s = AddFilterToScript("C.ConferenceID");
                        entity = "Team";
                        break;
                    case GUIStates.PlayerView:
                        s = AddFilterToScript("a.PrimaryPosition", true);
                        entity = "Player";
                        break;
                    default:
                        break;
                }
                DataTable dt = MakeDTFromQuery(s);
                _entityList = GetDBTableItems(s, entity);
                uxEntityBox.DataSource = _entityList;
            }
            else
            {
                uxEntityBox.DataSource = GetDBTableItems(_curScript, _curScript.OgTblName!);
            }
        }

        /// <summary>
        /// Adds specific <paramref name="filterID"/> where clause to the current script string
        /// </summary>
        /// <param name="filterID">Property to filter by (i.e C.ConferenceID)</param>
        /// <returns></returns>
        private string AddFilterToScript(string filterID, bool nonID = false)
        {
            string s = _curScript.ToString();
            s += "AND ( ";
            int count = 0;
            foreach (IEntityObject item in uxEnityFiltersBox.CheckedItems)
            {
                string data = "";
                if (nonID)
                    data = $"N'{item.ToString()}'";
                else
                    data = (item.GetID()).ToString();

                if (count > 0)
                    s += " OR ";
                s += $"{filterID} = {data} ";
                count++;
            }
            s += " ) ";

            return s;
        }

        /// <summary>
        /// Handler for Update info button click. 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxUpdateInfo_Click(object sender, EventArgs e)
        {
            UpdatePlayerData updatePlayerForm = new(_treeStack.Peek().Item3.GetID(), _connStr);
            if (updatePlayerForm.ShowDialog() == DialogResult.OK)
            {
                UpdateUI();
            }
        }

        /// <summary>
        /// Goes to Aggregating queries form
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uxAggQ_btn_Click(object sender, EventArgs e)
        {
            AggregatingQueries aq = new(_connStr);
            if (aq.ShowDialog() == DialogResult.OK)
            {
                return;
            }
        }
    }
}