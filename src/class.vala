/* class.vala
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
    public class Class : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "struct";
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
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            ValueType.add (name, Root.format_vala_name (name), (root as Root).extension_name, false, true);
        }

        public string
        to_string (string inPrefix)
        {
            string ret;

            if (name.down () == "setup" || name.down () == "screen")
            {
                ret = inPrefix + "[Compact, Immutable, CCode (cname = \"xcb_%s_t\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name));
                ret += inPrefix + "public class %s {\n".printf (Root.format_vala_name (name));
            }
            else
            {
                ret = inPrefix + "[SimpleType, CCode (cname = \"xcb_%s_iterator_t\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name));
                ret += inPrefix + "struct _%sIterator\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "{\n";
                ret += inPrefix + "\tinternal int rem;\n";
                ret += inPrefix + "\tinternal int index;\n";
                ret += inPrefix + "\tinternal unowned %s? data;\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "}\n\n";

                ret += inPrefix + "[CCode (cname = \"xcb_%s_iterator_t\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name));
                ret += inPrefix + "public struct %sIterator\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "{\n";
                ret += inPrefix + "\t[CCode (cname = \"xcb_%s_next\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name));
                ret += inPrefix + "\tinternal void _next ();\n\n";
                ret += inPrefix + "\tpublic inline unowned %s?\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "\tnext_value ()\n";
                ret += inPrefix + "\t{\n";
                ret += inPrefix + "\t\tif (((_%sIterator)this).rem > 0)\n".printf (Root.format_vala_name (name));
                ret += inPrefix + "\t\t{\n";
                ret += inPrefix + "\t\t\tunowned %s d = ((_%sIterator)this).data;\n".printf (Root.format_vala_name (name),
                                                                                             Root.format_vala_name (name));
                ret += inPrefix + "\t\t\t_next ();\n";
                ret += inPrefix + "\t\t\treturn d;\n";
                ret += inPrefix + "\t\t}\n";
                ret += inPrefix + "\t\treturn null;\n";
                ret += inPrefix + "\t}\n";
                ret += inPrefix + "}\n\n";

                ret += inPrefix + "[CCode (cname = \"xcb_%s_t\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name));
                ret += inPrefix + "public struct %s {\n".printf (Root.format_vala_name (name));
            }

            foreach (unowned XmlObject child in childs_unsorted)
            {
                ret += child.to_string (inPrefix + "\t");
            }
            ret += inPrefix + "}\n";

            return ret;
        }
    }
}
