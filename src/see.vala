/* see.vala
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
    public class See : GLib.Object, XmlObject
    {
        // static properties
        private static ulong s_Count = 0;

        // properties
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "see";
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
        public string attrtype       { get; set; default = null; }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
            s_Count++;
            name = "see-%lu".printf (s_Count);
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
            string ret = "";

            if (name != null)
            {
                switch (attrtype)
                {
                    case "request":
                        GLib.List<unowned Request?> requests = root.find_childs_of_type<Request> ();
                        foreach (unowned Request? request in requests)
                        {
                            if (request.name != null && request.owner != null && Root.format_c_name(null, request.name) == Root.format_c_name(null, name))
                            {
                                ret += inPrefix + " * @see %s.%s\n".printf (Root.format_vala_name (request.owner.name), request.function_name);
                                break;
                            }
                        }
                        break;

                    case "event":
                        GLib.List<unowned Event?> events = root.find_childs_of_type<Event> ();
                        foreach (unowned Event? event in events)
                        {
                            if (event.name != null && event.event_name == name)
                            {
                                ret += inPrefix + " * @see %sEvent\n".printf (Root.format_vala_name(event.event_name));
                                break;
                            }
                        }
                        break;
                }
            }

            return ret;
        }
    }
}
