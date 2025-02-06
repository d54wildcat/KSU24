using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Refactor
{
    /// <summary>
    /// Entities are what is displayed in the list back, this defines the interface for them
    /// </summary>
    public interface IEntityObject
    {
        public int GetID();

        public string ToString();
    }

    /// <summary>
    /// Entity for the start of UI tree
    /// </summary>
    public class StartObj : IEntityObject
    {
        public int GetID()
        {
            throw new NotImplementedException();
        }

        public override string ToString()
        {
            return "Sport View";
        }
    }

    /// <summary>
    /// Sport object
    /// </summary>
    public class SportObj: IEntityObject
    {
        public string SportName { get; private set; }

        public SportObj(string SportName)
        {
            this.SportName = SportName;
        }

        public int GetID()
        {
            throw new NotImplementedException();
        }

        public override string ToString()
        {
            return this.SportName;
        }
    }

    /// <summary>
    /// Team object
    /// </summary>
    public class TeamObj : IEntityObject
    {
        private int _id;
        public string SchoolName { get; private set; }
        public string TeamKey { get; private set; }

        public TeamObj(int id, string SchoolName, string TeamKey)
        {
            this._id = id;
            this.SchoolName = SchoolName;
            this.TeamKey = TeamKey;
        }

        public int GetID()
        {
            return this._id;
        }

        public override string ToString()
        {
            return this.SchoolName;
        }
    }

    /// <summary>
    /// Conference object
    /// </summary>
    public class ConferenceObj : IEntityObject
    {
        private int _id;
        public string Name { get; private set; }
        public string ShortName { get; private set; }

        public ConferenceObj(int id, string name, string shortName)
        {
            this._id = id;
            this.Name = name;
            this.ShortName = shortName;
        }

        public override string ToString()
        {
            return this.ShortName;
        }

        public int GetID()
        {
            return this._id;
        }
    }

    /// <summary>
    /// Player object
    /// </summary>
    public class PlayerObj : IEntityObject
    {
        private int _id;
        public string Name { get; private set; }

        public PlayerObj(int id, string name)
        {
            this._id = id;
            this.Name = name;
        }

        public int GetID()
        {
            return this._id;
        }

        public override string ToString()
        {
            return this.Name;
        }
    }

    /// <summary>
    /// Coach Obejct
    /// </summary>
    public class CoachObj : IEntityObject
    {
        private int _id;
        public string Name { get; private set; }

        public CoachObj(int id, string name)
        {
            this._id = id;
            this.Name = name;
        }

        public int GetID()
        {
            return _id;
        }

        public override string ToString()
        {
            return this.Name;
        }
    }

    /// <summary>
    /// player postion object
    /// </summary>
    public class PosObj : IEntityObject
    {
        private string _position;

        public PosObj(string position)
        {
            this._position = position;
        }

        public int GetID()
        {
            int rt = (char)_position[0];
            return rt;
        }

        public override string ToString()
        {
            return this._position;
        }
    }

}
