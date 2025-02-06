using OpenQA.Selenium.DevTools.V123.Storage;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Refactor
{
    /// <summary>
    /// Object used create a simple "SELECT..FROM..JOIN..WHERE" sql script.
    /// Each part of the script can be changed or added/removed to.
    /// This SELECT only produces one column. 
    /// </summary>
    public class SqlScript
    {
        /// <summary>
        /// Table schema name used in our DB
        /// </summary>
        public static string Schema = "[560_proj_Group09]";

        /// <summary>
        /// Table name; used in FROM
        /// </summary>
        public string? OgTblName { get; set; }

        /// <summary>
        /// Column name; used in SELECT
        /// </summary>
        public string? SelectCol { get; set; }

        /// <summary>
        /// Lines to use for JOIN (full line)
        /// </summary>
        public List<string> JoinTableLines { get; set; } = new();

        /// <summary>
        /// Lines to use for WHERE (full) 
        /// (lines that are added on begin with AND)
        /// </summary>
        public List<string> WhereClauseLines { get; set; } = new();

        /// <summary>
        /// Makes string based on object properties.
        /// </summary>
        /// <returns>Script that can be used to querry the DB</returns>
        public override string ToString()
        {
            string script = $"SELECT a.{SelectCol} FROM {Schema}.{OgTblName} a ";

            if (JoinTableLines.Count > 0)
            {
                foreach(string line in JoinTableLines)
                {
                    script += line;
                }
            }
            if (WhereClauseLines.Count > 0)
            {
                foreach(string line in WhereClauseLines)
                {
                    script += line;
                }
            }

            return script;
        }

        /// <summary>
        /// Empty constructor
        /// </summary>
        public SqlScript() {}

        /// <summary>
        /// Constructor sets the select and from clauses
        /// </summary>
        /// <param name="tblName">Table name used for from clause</param>
        /// <param name="colName"> column name used for select clause</param>
        public SqlScript(string tblName, string colName)
        {
            OgTblName = tblName;
            SelectCol = colName;
        }

        /// <summary>
        /// Sets all properties to empty.
        /// </summary>
        public void ResetScript()
        {
            OgTblName = "";
            SelectCol = "";
            JoinTableLines = new();
            WhereClauseLines = new();
        }
    }
}
