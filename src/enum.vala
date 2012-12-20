/* enum.vala
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
    public class Enum : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;
        private bool           m_HaveTypeSuffix = false;

        // accessors
        protected string tag_name {
            get {
                return "enum";
            }
        }

        protected unowned XmlObject? parent { get; set; default = null; }

        protected unowned Set<XmlObject>? childs {
            get {
                return m_Childs;
            }
        }

        public string name           { get; set; default = null; }
        public int    pos            { get; set; default = 0; }
        public string characters     { get; set; default = null; }
        public bool   is_mask        { get; set; default = false; }
        public bool have_type_suffix {
            get {
                return m_HaveTypeSuffix;
            }
            set {
                m_HaveTypeSuffix = value;
            }
        }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            if (ValueType.get(name) != null)
            {
                m_HaveTypeSuffix = true;
            }
            else if (Root.format_vala_name (name) == "Connection")
            {
                m_HaveTypeSuffix = true;
                ValueType.add (name, Root.format_vala_name (name) + "Type", (root as Root).extension_name);
            }
            else if (Root.format_vala_name (name) == "ScreenSaver")
            {
                m_HaveTypeSuffix = true;
                ValueType.add (name, Root.format_vala_name (name) + "Type", (root as Root).extension_name);
            }
            else
            {
                ValueType.add (name, Root.format_vala_name (name), (root as Root).extension_name);
            }
        }

        public string
        to_string (string inPrefix)
        {
            string ret = "";

            if (name == "EventType")
                ret += inPrefix + "[CCode (cname = \"uint8\", cprefix =  \"XCB_\")]\n";
            else if (!is_mask)
                ret += inPrefix + "[CCode (cname = \"xcb_%s_t\", cprefix =  \"XCB_%s_\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name), Root.format_c_enum_name ((root as Root).extension_name, name));
            else
                ret += inPrefix + "[Flags, CCode (cname = \"xcb_%s_t\", cprefix =  \"XCB_%s_\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name), Root.format_c_enum_name ((root as Root).extension_name, name));

            ret += inPrefix + "public enum %s%s {\n".printf (Root.format_vala_name (name), m_HaveTypeSuffix ? "Type" : "");
            int length = childs.length;
            int cpt = 0;
            foreach (unowned XmlObject child in childs_unsorted)
            {
                ret += child.to_string (inPrefix + "\t");
                cpt++;
                if (cpt != length) ret += ",";
                ret += "\n";
            }
            ret += inPrefix + "}\n";

            return ret;
        }
    }
}
