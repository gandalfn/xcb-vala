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

namespace XCBVala
{
    public class XIDUnion : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;

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
        public string base_type      { get; set; default = "uint32"; }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);

            XmlObject.register_object ("type", typeof (XIDUnionType));
        }

        private bool
        have_iterator ()
        {
            bool ret = false;
            string[] t = base_type.split(":");
            if (t[1] != null)
            {
                ret = ValueType.is_simple_type (t[1]);
            }
            else
            {
                ret = ValueType.have_iterator (t[0]) || ValueType.is_simple_type (t[0]);
            }

            return ret;
        }

        public XIDType
        copy (Root inRoot)
        {
            string ext = inRoot.extension_name == null ? "proto" : inRoot.extension_name;

            XIDType xid_type = new XIDType ();
            xid_type.name = name;
            xid_type.base_type = ext + ":" + name;
            xid_type.is_copy = true;
            ValueType.add (ext + ":" + name, Root.format_vala_name (name), ext, true, have_iterator ());

            return xid_type;
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            ValueType.add (name, Root.format_vala_name (name), (root as Root).extension_name, true, have_iterator ());

            GLib.List<unowned XIDType> xidtypes = root.find_childs_of_type<XIDType> ();

            foreach (unowned XmlObject child in m_Childs)
            {
                if (child is XIDUnionType)
                {
                    foreach (unowned XIDType xidtype in xidtypes)
                    {
                        if (xidtype.name == child.characters)
                        {
                            xidtype.base_type = name;
                        }
                    }
                }
            }
            XmlObject.unregister_object ("type");
        }

        public virtual string
        to_string (string inPrefix)
        {
            string ret = inPrefix + "[CCode (cname = \"xcb_%s_t\", has_type_id = false)]\n".printf (Root.format_c_name ((root as Root).extension_name, name));

            ret += inPrefix + "public struct %s : %s {\n".printf (Root.format_vala_name (name), base_type);
            foreach (unowned XmlObject child in childs_unsorted)
            {
                ret += child.to_string (inPrefix + "\t");
            }
            ret += inPrefix + "}\n";

            foreach (unowned XmlObject child in childs_unsorted)
            {
                if (child is Request && (child as Request).reply != null)
                {
                    ret += "\n" + (child as Request).reply.to_string (inPrefix);
                }
            }

            return ret;
        }
    }
}
