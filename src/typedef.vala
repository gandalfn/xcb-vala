/* typedef.vala
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
    public class Typedef : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "typedef";
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
                return newname;
            }
            set {
                newname = value;
            }
        }

        public int    pos            { get; set; default = 0; }
        public string characters     { get; set; default = null; }
        public string newname        { get; set; default = null; }
        public string oldname        { get; set; default = null; }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        public void
        on_child_added (XmlObject inChild)
        {
            message ("Add %s", inChild.tag_name);
        }

        public void
        on_end ()
        {
            ValueType.add (newname, Root.format_vala_name (newname), (root as Root).extension_name);
        }

        public string
        to_string (string inPrefix)
        {
            string ret = inPrefix + "[SimpleType, CCode (cname = \"xcb_%s_t\")]\n".printf (Root.format_c_name ((root as Root).extension_name, newname));

            ret += inPrefix + "public struct %s : %s {\n".printf (Root.format_vala_name (name), ValueType.get (oldname));
            ret += inPrefix + "}\n";

            return ret;
        }
    }
}
