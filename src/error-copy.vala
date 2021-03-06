/* error-copy.vala
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
    public class ErrorCopy : GLib.Object, XmlObject
    {
        // properties
        private string m_Name;
        private string m_Ref;
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "errorcopy";
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

        public int    pos            { get; set; default = 0; }
        public string characters     { get; set; default = null; }
        public int    number         { get; set; default = 0; }
        public new string @ref {
            get {
                return m_Ref;
            }
            set {
                m_Ref = value + "Error";
            }
            default = null;
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
        }

        public string
        to_string (string inPrefix)
        {
            return "";
        }
    }
}
