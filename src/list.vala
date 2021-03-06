/* list.vala
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
    public class List : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject> m_Childs;
        private int            m_ArrayLenPos = -1;
        private bool           m_FixedSize = true;

        // accessors
        protected string tag_name {
            get {
                return "list";
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
        public string field_ref      { get; set; default = null; }
        public char   generic_name   { get; set; default = -1; }

        public int array_len_pos {
            get {
                return m_ArrayLenPos;
            }
        }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        private string
        attrtype_valuetype ()
        {
            return generic_name != -1 ? "%c".printf (generic_name) : ValueType.get (attrtype);
        }

        private string
        generate_switch_accessor (string inPrefix)
        {
            string ret = "";
            string cname = Root.format_c_name (null, name);
            string cswitchname = Root.format_c_name (null, parent.parent.name);
            string cparentname = Root.format_c_name ((root as Root).extension_name, parent.parent.parent.parent.name);
            string ctype = attrtype_valuetype ();

            if ((parent.parent as Switch).first_bitcase)
            {
                ret += inPrefix + "[CCode (array_length = false)]\n";
                ret += inPrefix + "public unowned void[] %s {\n".printf (cswitchname);
                ret += inPrefix + "\t[CCode (cname = \"xcb_%s_%s\")]\n".printf (cparentname, cswitchname);
                ret += inPrefix + "\tget;\n";
                ret += inPrefix + "}\n";
            }

            ret += inPrefix + "[CCode (cname = \"xcb_%s_%s_%s_length\")]\n".printf (cparentname, cswitchname, cname);
            ret += inPrefix + "public int %s_%s_length ([CCode (array_length = false)]void[] %s);\n".printf (cswitchname, cname, cswitchname);
            ret += inPrefix + "[CCode (array_length = false)]\n";
            ret += inPrefix + "public unowned %s[] %s_%s {\n".printf (ctype, cswitchname, cname);
            ret += inPrefix + "\t[CCode (cname = \"xcb_%s_%s\")]\n".printf (cparentname, cswitchname);
            ret += inPrefix + "\tget;\n";
            ret += inPrefix + "}\n";

            return ret;
        }

        private string
        generate_accessor (string inPrefix, string inParentName)
        {
            string ret = "";
            string cname = Root.format_c_name (null, name);
            string cparentname = Root.format_c_name ((root as Root).extension_name, inParentName);
            string ctype = attrtype_valuetype ();

            if (cname == "names" && (ctype.down () == "uint8" || ctype.down () == "char"))
            {
                ret += inPrefix + "[CCode (cname = \"xcb_%s_%s_length\")]\n".printf (cparentname, cname);
                ret += inPrefix + "int _%s_length ();\n".printf (cname);
                ret += inPrefix + "[CCode (cname = \"xcb_%s_%s\", array_length = false)]\n".printf (cparentname, cname);
                ret += inPrefix + "unowned %s[] _%s ();\n".printf (ctype, cname);
                ret += inPrefix + "public string[] %s {\n".printf (cname);
                ret += inPrefix + "\towned get {\n";
                ret += inPrefix + "\t\tstring[] ret = {};\n";
                ret += inPrefix + "\t\tint pos = 0;\n";
                ret += inPrefix + "\t\tfor (int cpt = 0; cpt < _%s_length (); ++cpt) {\n".printf (cname);
                ret += inPrefix + "\t\t\t(string)((char*)_%s () + pos);\n".printf (cname);
                ret += inPrefix + "\t\t\tpos += ret[cpt].length + 1;\n";
                ret += inPrefix + "\t\t}\n";
                ret += inPrefix + "\t\treturn ret;\n";
                ret += inPrefix + "\t}\n";
                ret += inPrefix + "}\n";
            }
            else if (ctype.down () == "char" || (cname == "name" && ctype.down () == "uint8"))
            {
                ret += inPrefix + "[CCode (cname = \"xcb_%s_%s_length\")]\n".printf (cparentname, cname);
                ret += inPrefix + "int _%s_length ();\n".printf (cname);
                ret += inPrefix + "[CCode (cname = \"xcb_%s_%s\", array_length = false)]\n".printf (cparentname, cname);
                ret += inPrefix + "unowned %s[] _%s ();\n".printf (ctype, cname);
                ret += inPrefix + "public string %s {\n".printf (cname);
                ret += inPrefix + "\towned get {\n";
                ret += inPrefix + "\t\tGLib.StringBuilder ret = new GLib.StringBuilder ();\n";
                ret += inPrefix + "\t\tret.append_len ((string)_%s (), _%s_length ());\n".printf (cname, cname);
                ret += inPrefix + "\t\treturn ret.str;\n";
                ret += inPrefix + "\t}\n";
                ret += inPrefix + "}\n";
            }
            else
            {
                string with_value = "";

                foreach (unowned XmlObject child in childs_unsorted)
                {
                    if (child is ValueItem)
                    {
                        with_value += "[%i]".printf (int.parse (child.characters));
                    }
                }

                if (with_value.length == 0)
                {
                    ret += inPrefix + "public int %s_length {\n".printf (cname);
                    ret += inPrefix + "\t[CCode (cname = \"xcb_%s_%s_length\")]\n".printf (cparentname, cname);
                    ret += inPrefix + "\tget;\n";
                    ret += inPrefix + "}\n";

                    ret += inPrefix + "[CCode (array_length = false)]\n";
                    ret += inPrefix + "public unowned %s[] %s {\n".printf (ctype, cname);
                    ret += inPrefix + "\t[CCode (cname = \"xcb_%s_%s\")]\n".printf (cparentname, cname);
                    ret += inPrefix + "\tget;\n";
                    ret += inPrefix + "}\n";
                }
                else
                {
                    ret += inPrefix + "public %s %s%s;\n".printf (attrtype_valuetype (), name, with_value);
                }
            }

            return ret;
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            unowned XmlObject p = parent;

            if (parent != null)
            {
                if (parent is Bitcase)
                {
                    p = parent.parent.parent;
                }
            }

            if (p != null)
            {
                GLib.List<unowned FieldRef> fieldrefs = find_childs_of_type<FieldRef> ();
                foreach (unowned FieldRef fieldref in fieldrefs)
                {
                    foreach (unowned XmlObject child in p)
                    {
                        if (child is Field)
                        {
                            unowned Field field = child as Field;
                            if (fieldref.characters == field.name)
                            {
                                field.is_ref = true;
                                field_ref = fieldref.characters;
                                if (p is Request)
                                {
                                    m_ArrayLenPos = child.pos;
                                }
                                return;
                            }
                        }
                    }
                }
            }
        }

        public string
        to_string (string inPrefix)
        {
            string ret = "";
            if (attrtype != null && attrtype_valuetype () != null)
            {
                bool is_reply = false;
                bool is_struct = false;

                unowned XmlObject p = parent;
                if (parent is Bitcase)
                {
                    p = parent.parent.parent;
                }

                if (field_ref != null)
                {
                    if (p is Request)
                    {
                        if (m_ArrayLenPos >= 0)
                        {
                            int pos = m_ArrayLenPos + 1;
                            if ((p as Request).owner_pos <= m_ArrayLenPos)
                                pos = int.max (m_ArrayLenPos, 0);
                            ret += inPrefix +  "[CCode (array_length_pos = %i.%i)]".printf (pos, m_ArrayLenPos + 1);
                        }

                        ret += "%s[]? %s".printf (attrtype_valuetype (), name);
                    }
                    else if (p is Reply)
                    {
                        is_reply = true;
                    }
                    else if (p is Struct)
                    {
                        is_struct = true;
                    }
                    else
                    {
                        ret += generate_accessor (inPrefix, p.name);
                    }
                }
                else if (childs.length == 1)
                {
                    if (p is Request)
                    {
                        ret += inPrefix + "[CCode (array_length = false)]%s %s".printf (attrtype_valuetype (), name);
                        foreach (unowned XmlObject child in childs_unsorted)
                        {
                            if (child is ValueItem)
                                ret += "[%i]".printf (int.parse (child.characters));
                        }
                    }
                    else if (p is Reply)
                    {
                        is_reply = true;
                    }
                    else if (p is Struct)
                    {
                        is_struct = true;
                    }
                    else
                    {
                        ret += inPrefix + "public %s %s".printf (attrtype_valuetype (), name);
                        foreach (unowned XmlObject child in childs_unsorted)
                        {
                            if (child is ValueItem)
                                ret += "[%i]".printf (int.parse (child.characters));
                        }
                        ret += ";\n";
                    }
                }
                else
                {
                    if (p is Request)
                    {
                        ret += inPrefix + "[CCode (array_length_pos = %i.%i)]".printf (pos, pos);
                        ret += "%s[]? %s".printf (attrtype_valuetype (), name);
                    }
                    else if (p is Reply)
                    {
                        is_reply = true;
                    }
                    else if (p is Struct)
                    {
                        is_struct = true;
                    }
                    else
                    {
                        ret += inPrefix + "[CCode (array_length = false)]\n";
                        ret += inPrefix + "public %s[] %s;\n".printf (attrtype_valuetype (), name);
                    }
                }

                if (is_reply || is_struct)
                {
                    if (!(parent is Bitcase))
                    {
                        if (p.name.down () != "setup")
                        {
                            m_FixedSize = true;
                            bool have_child = false;
                            bool found_this = false;
                            foreach (unowned XmlObject child in parent.childs_unsorted)
                            {
                                if (!found_this && child == this)
                                {
                                    found_this = true;
                                }
                                else if (child is Field)
                                {
                                    have_child = true;
                                }
                                else if (found_this && child is List)
                                {
                                    string cname = Root.format_c_name (null, child.name);
                                    string ctype = ((List)child).attrtype_valuetype ();
                                    if (!(ctype.down () == "char" || ((cname == "name" || cname == "names") && ctype.down () == "uint8")))
                                    {
                                        m_FixedSize = false;
                                        break;
                                    }
                                }
                            }
                            if (!have_child) m_FixedSize = false;

                            if (ValueType.have_iterator (attrtype))
                            {
                                if (m_FixedSize)
                                {
                                    if (is_struct)
                                        ret += inPrefix + "[CCode (cname = \"xcb_%s_%s_iterator\")]\n".printf (Root.format_c_name ((root as Root).extension_name, p.name),
                                                                                                               Root.format_c_name (null, name));
                                    else
                                        ret += inPrefix + "[CCode (cname = \"xcb_%s_%s_iterator\")]\n".printf (Root.format_c_name ((root as Root).extension_name, p.parent.name),
                                                                                                               Root.format_c_name (null, name));
                                    ret += inPrefix + "_%sIterator _iterator ();\n".printf (attrtype_valuetype ());
                                    ret += inPrefix + "public %sIterator iterator () {\n".printf (attrtype_valuetype ());
                                    ret += inPrefix + "\treturn (%sIterator) _iterator ();\n".printf (attrtype_valuetype ());
                                    ret += inPrefix + "}\n";
                                }
                            }

                            if (!is_struct)
                            {
                                ret += generate_accessor (inPrefix, p.parent.name);
                            }
                        }
                    }
                    else
                    {
                        ret += generate_switch_accessor (inPrefix);
                    }
                }
            }
            else
                warning ("Type %s of %s not found", attrtype, name);

            return ret;
        }
    }
}
