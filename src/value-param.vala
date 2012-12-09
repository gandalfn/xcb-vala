/* value-param.vala
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
    public class ValueParam : GLib.Object, XmlObject
    {
        // static properties
        private static ulong s_Count = 0;

        // properties
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "valueparam";
            }
        }

        protected unowned XmlObject? parent { get; set; default = null; }

        protected unowned Set<XmlObject>? childs {
            get {
                return m_Childs;
            }
        }

        public string name            { get; set; default = null; }
        public int    pos             { get; set; default = 0; }
        public string characters      { get; set; default = null; }
        public string value_mask_type { get; set; default = null; }
        public string value_mask_name { get; set; default = null; }
        public string value_list_name { get; set; default = null; }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
            s_Count++;
            name = "value-param-%lu".printf (s_Count);
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
            string ret = inPrefix;
            bool found = false;

            if (parent is Request)
            {
                GLib.List<unowned Field> fields = parent.find_childs_of_type<Field> ();

                foreach (unowned Field child in fields)
                {
                    if (child.name == value_mask_name)
                    {
                        found = true;
                        break;
                    }
                }
            }
            if (!found)
            {
                ret += "%s %s = 0, ".printf (ValueType.get (value_mask_type), value_mask_name);
            }

            ret += "[CCode (array_length = false)]uint32[]? %s = null".printf (value_list_name);
            return ret;
        }
    }
}
