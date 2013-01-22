/* xid-union.vala
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

namespace XCBVala.Codegen
{
    public class XidUnion : GLib.Object, XmlObject, XidClass
    {
        // properties
        private Set<XmlObject>       m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "xidunion";
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

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);

            XmlObject.register_object ("type", typeof (XidUnionType));
        }

        ~XidUnion ()
        {
            XmlObject.unregister_object ("type");
        }

        public void
        on_created ()
        {
            // Add class declation
            add_class_declaration ();
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            Parser.pop ();
        }

        public string
        to_string (string inPrefix)
        {
            return "";
        }
    }
}
