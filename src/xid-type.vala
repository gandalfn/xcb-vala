/* xid-type.vala
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
    public class XIDType : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "xidtype";
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
        public string base_type      { get; set; default = "uint32"; }

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
            ValueType.add (name, Root.format_vala_name (name), (root as Root).extension_name);
        }

        public string
        to_string (string inPrefix)
        {
            string ret = inPrefix + "[CCode (cname = \"xcb_%s_t\")]\n".printf (Root.format_c_name ((root as Root).extension_xname, name));
            string derived_type = ValueType.get_derived (base_type);
            ret += inPrefix + "public struct %s : %s\n".printf (Root.format_vala_name (name), derived_type != null ? derived_type : "uint32");
            ret += inPrefix + "{\n";
            ret += inPrefix + "}\n";

            return ret;
        }
    }
}
