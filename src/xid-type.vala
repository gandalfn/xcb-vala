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
        public string base_type      { get; set; default = "CARD32"; }
        public bool   is_copy        { get; set; default = false; }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        private bool
        have_create_request ()
        {
            foreach (unowned XmlObject child in childs)
            {
                if (child is Request && ((Request)child).function_name == "create")
                {
                    return true;
                }
            }

            return false;
        }

        private bool
        have_iterator ()
        {
            bool ret = true;
            string[] t = base_type.split(":");
            if (t[1] != null)
            {
                ret = t[1].down () != name.down ();
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
            if (ValueType.get(name) != null)
            {
                GLib.List<unowned Enum?> enums = root.find_childs_of_type<Enum> ();
                foreach (unowned Enum @enum in enums)
                {
                    if (@enum.name.down() == name.down())
                    {
                        @enum.have_type_suffix = true;
                        break;
                    }
                }
            }

            ValueType.add (name, Root.format_vala_name (name), (root as Root).extension_name, true, have_iterator ());
        }

        public virtual string
        to_string (string inPrefix)
        {
            string ret = "";
            string cname;
            string[] t = base_type.split(":");

            if (!is_copy)
            {
                cname = Root.format_c_name ((root as Root).extension_name, name);
            }
            else
            {
                cname = Root.format_c_name (t[0], t[1]);
            }
            if (have_iterator ())
            {
                ret += inPrefix + "[SimpleType, CCode (cname = \"xcb_%s_iterator_t\")]\n".printf (cname);
                ret += inPrefix + "public struct _%sIterator\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "{\n";
                ret += inPrefix + "\tinternal int rem;\n";
                ret += inPrefix + "\tinternal int index;\n";
                ret += inPrefix + "\tinternal unowned %s? data;\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "}\n\n";

                ret += inPrefix + "[CCode (cname = \"xcb_%s_iterator_t\")]\n".printf (cname);
                ret += inPrefix + "public struct %sIterator\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "{\n";
                ret += inPrefix + "\t[CCode (cname = \"xcb_%s_next\")]\n".printf (cname);
                ret += inPrefix + "\tinternal void _next ();\n\n";
                ret += inPrefix + "\tpublic inline unowned %s?\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "\tnext_value ()\n";
                ret += inPrefix + "\t{\n";
                ret += inPrefix + "\t\tif (((_%sIterator)this).rem > 0)\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "\t\t{\n";
                ret += inPrefix + "\t\t\tunowned %s? d = ((_%sIterator)this).data;\n".printf (Root.format_vala_name (name),
                                                                                             Root.format_vala_name (name));
                ret += inPrefix + "\t\t\t_next ();\n";
                ret += inPrefix + "\t\t\treturn d;\n";
                ret += inPrefix + "\t\t}\n";
                ret += inPrefix + "\t\treturn null;\n";
                ret += inPrefix + "\t}\n";
                ret += inPrefix + "}\n\n";
            }

            ret += inPrefix + "[CCode (cname = \"xcb_%s_t\", has_type_id = false)]\n".printf (cname);

            string derived_type = ValueType.get_derived (base_type);
            ret += inPrefix + "public struct %s : %s {\n".printf (Root.format_vala_name (name), derived_type != null ? derived_type : "uint32");


            if (have_create_request ()                     ||
                Root.format_vala_name (name) == "GContext" ||
                Root.format_vala_name (name) == "Font")
            {
                ret += inPrefix + "\t[CCode (cname = \"xcb_generate_id\")]\n";
                ret += inPrefix + "\tpublic %s (Xcb.Connection connection);\n\n".printf (Root.format_vala_name (name));
            }

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
