/* error.vala
 *
 * Copyright (C) 2012  Nicolas Bruguier
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Nicolas Bruguier <nicolas.bruguier@supersonicimagine.fr>
 */

namespace XCBVala
{
    public class Error : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;
        private string m_Name;
        private string m_Type;

        // accessors
        protected string tag_name {
            get {
                return "error";
            }
        }

        protected unowned XmlObject? parent { get; set; default = null; }

        protected unowned Set<XmlObject>? childs {
            get {
                return m_Childs;
            }
        }

        public string name {
            get {
                return m_Name;
            }
            set {
                m_Name = value + "Error";
            }
            default = null;
        }
        public string attrtype {
            get {
                return m_Type;
            }
            set {
                m_Type = value + "Error";
            }
        }
        public int    pos            { get; set; default = 0; }
        public string characters     { get; set; default = null; }
        public int    number         { get; set; default = 0; }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        public Error
        copy (string inName, int inNumber)
        {
            Error error = new Error ();
            error.m_Name = inName;
            error.number = inNumber;

            foreach (unowned XmlObject child in this)
            {
                error.append_child (child);
            }
            return error;
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
        }

        public string
        to_string (string inPrefix)
        {
            string ret = inPrefix + "[Compact, CCode (cname = \"xcb_%s_t\", has_type_id = false)]\n".printf (Root.format_c_name ((root as Root).extension_name, name));

            ret += inPrefix + "public class %s : Xcb.GenericError {\n".printf (Root.format_vala_name (name));
            foreach (unowned XmlObject child in childs_unsorted)
            {
                ret += child.to_string (inPrefix + "\t");
            }
            ret += inPrefix + "}\n";

            return ret;
        }

        public int
        compare_number (Error inOther)
        {
            return number - inOther.number;
        }
    }
}
