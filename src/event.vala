/* event.vala
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
    public class Event : GLib.Object, XmlObject
    {
        // properties
        private string         m_Name = null;
        private string         m_EventName;
        private Set<XmlObject> m_Childs;
        private unowned Doc?   m_Doc = null;

        // accessors
        protected string tag_name {
            get {
                return "event";
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
                return m_EventName;
            }
            set {
                m_Name = value;
                m_EventName = value + "event";
            }
        }

        public string event_name {
            get {
                return m_Name;
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

        public Event
        copy (string inName, int inNumber)
        {
            Event event = new Event ();
            event.name = inName;
            event.number = inNumber;

            foreach (unowned XmlObject child in this)
            {
                event.append_child (child);
            }
            return event;
        }

        public void
        on_child_added (XmlObject inChild)
        {
            if (inChild is Doc)
            {
                m_Doc = inChild as Doc;
            }
        }

        public void
        on_end ()
        {
        }

        public string
        to_string (string inPrefix)
        {
            string ret = "";

            if (m_Doc != null)
            {
                ret += m_Doc.to_string (inPrefix);
            }
            ret += inPrefix + "[Compact, CCode (cname = \"xcb_%s_event_t\", has_type_id = false)]\n".printf (Root.format_c_name ((root as Root).extension_name, m_Name));
            ret += inPrefix + "public class %sEvent : Xcb.GenericEvent {\n".printf (Root.format_vala_name (m_Name));
            foreach (unowned XmlObject child in childs_unsorted)
            {
                if (!(child is Doc))
                {
                    if (m_Doc != null)
                    {
                        ret += m_Doc.field_to_string (child.name, inPrefix + "\t");
                    }
                    ret += child.to_string (inPrefix + "\t");
                }
            }
            ret += inPrefix + "}\n";

            return ret;
        }

        public int
        compare_number (Event inOther)
        {
            return number - inOther.number;
        }
    }
}
