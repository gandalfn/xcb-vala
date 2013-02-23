/* switch.vala
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
    public class Switch : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;
        private char           m_Generic;

        // accessors
        protected string tag_name {
            get {
                return "switch";
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
        public bool   first_bitcase  { get; set; default = true; }

        public char generic_name {
            get {
                return m_Generic;
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
            if (parent is Request)
            {
                m_Generic = (parent as Request).add_generic ();
            }
        }

        public string
        to_string (string inPrefix)
        {
            string ret = "";

            first_bitcase = true;
            if (parent is Request)
            {
                foreach (unowned XmlObject child in childs_unsorted)
                {
                    if (child is Bitcase)
                    {
                        ret += child.to_string (", ");
                        first_bitcase = false;
                        break;
                    }
                }
            }
            else if (parent is Reply)
            {
                foreach (unowned XmlObject child in childs_unsorted)
                {
                    if (child is Bitcase)
                    {
                        ret += child.to_string (inPrefix);
                        first_bitcase = false;
                    }
                }
            }

            return ret;
        }
    }
}
