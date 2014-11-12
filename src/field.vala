/* field.vala
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
    public class Field : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "field";
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
        public string attrtype       { get; set; default = null; }
        public string characters     { get; set; default = null; }
        public string mask           { get; set; default = null; }
        public string @enum          { get; set; default = null; }
        public bool   is_ref         { get; set; default = false; }

        // methods
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
            if (parent != null && (!(parent is Request) || !is_ref))
            {
                if (attrtype != null && ValueType.get (attrtype) != null)
                {
                    if (parent is Request)
                        return inPrefix + "%s %s".printf (ValueType.get (attrtype), Root.format_c_field_name (name));
                    else
                        return inPrefix + "public %s %s;\n".printf (ValueType.get (attrtype), Root.format_c_field_name (name));
                }
                else
                    warning ("Type %s of %s not found", attrtype, name);
            }

            return "";
        }
    }
}
