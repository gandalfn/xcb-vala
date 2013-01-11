/* request.vala
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
    public class Request : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject>    m_Childs;
        private unowned XmlObject m_Owner;
        private int               m_OwnerPos = -1;
        private unowned Reply?    m_Reply = null;

        // accessors
        protected string tag_name {
            get {
                return "request";
            }
        }

        protected unowned XmlObject? parent { get; set; default = null; }

        protected unowned Set<XmlObject>? childs {
            get {
                return m_Childs;
            }
        }

        public string  name           { get; set; default = null; }
        public int     pos            { get; set; default = 0; }
        public string  characters     { get; set; default = null; }
        public XmlObject owner {
            get {
                return m_Owner;
            }
        }
        public int owner_pos {
            get {
                return m_OwnerPos;
            }
        }
        public string function_name {
            owned get {
                return format_function_name ();
            }
        }

        public Reply? reply {
            get {
                return m_Reply;
            }
        }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        private string
        format_function_name ()
        {
            string ret = Root.format_c_name (null, name);

            if (m_Owner != null)
            {
                string low_c_name = Root.format_c_name (null, name.down ());
                string suffix = "_%s".printf (m_Owner.name.down ());
                string prefix = "%s_".printf (m_Owner.name.down ());
                string middle = "_%s_".printf (m_Owner.name.down ());

                if (ret.has_suffix (suffix) && (ret.length - suffix.length) > 0)
                    ret = ret.substring (0, ret.length - suffix.length);
                else if (ret.has_prefix (prefix) && (ret.length - prefix.length) > 0)
                    ret = ret.substring (prefix.length);
                else if (middle in ret)
                    ret = ret.replace (middle, "_");
                else if (low_c_name.has_suffix (m_Owner.name.down ()))
                    ret = low_c_name.substring (0, low_c_name.length - m_Owner.name.down ().length);
            }

            return ret;
        }

        public bool
        search_owner (XmlObject inRoot)
        {
            GLib.List<unowned XIDType> xid_types = inRoot.find_childs_of_type<XIDType> ();
            GLib.List<unowned XIDUnion> xid_unions = inRoot.find_childs_of_type<XIDUnion> ();
            GLib.List<unowned Field> fields = find_childs_of_type<Field> ();
            foreach (unowned Field field in fields)
            {
                foreach (unowned XIDType xid_type in xid_types)
                {
                    if (ValueType.get (field.attrtype) == Root.format_vala_name (xid_type.name))
                    {
                        m_Owner = xid_type;
                        m_OwnerPos = field.pos;
                        if (ValueType.get_extension_name (field.attrtype) != (root as Root).extension_name)
                            continue;
                        return true;
                    }
                }
                if (m_Owner != null) return true;
                foreach (unowned XIDUnion xid_union in xid_unions)
                {
                    if (ValueType.get (field.attrtype) == Root.format_vala_name (xid_union.name))
                    {
                        m_Owner = xid_union;
                        m_OwnerPos = field.pos;
                        if (ValueType.get_extension_name (field.attrtype) != (root as Root).extension_name)
                            continue;
                        return true;
                    }
                }
                if (m_Owner != null) return true;
            }

            return false;
        }

        public void
        on_child_added (XmlObject inChild)
        {
            if (inChild is Reply)
            {
                m_Reply = inChild as Reply;
            }
        }

        public void
        on_end ()
        {
            if (root != null)
            {
                search_owner (root);
            }
        }

        public string
        to_string (string inPrefix)
        {
            string[] suffix = { "", "_checked" };
            string ret = "";
            int nb = 1;

            if (m_Reply == null)
                nb = 2;

            for (int cpt = 0; cpt < nb; ++cpt)
            {
                if (m_OwnerPos >= 0)
                {
                    GLib.List<unowned Field> fields = find_childs_of_type<unowned Field> ();
                    if (m_OwnerPos == fields.length ())
                    {
                        ret += inPrefix + "[CCode (cname = \"xcb_%s%s\", instance_pos=-1)]\n".printf (Root.format_c_name ((root as Root).extension_name, name), suffix[cpt]);
                    }
                    else
                    {
                        int pos = m_OwnerPos;
                        GLib.List<unowned List> lists = find_childs_of_type<List> ();
                        foreach (unowned List list in lists)
                        {
                            if (list.array_len_pos + 1 <= m_OwnerPos)
                                pos = int.max (--pos, 0);
                        }
                        ret += inPrefix + "[CCode (cname = \"xcb_%s%s\", instance_pos=%i.%i)]\n".printf (Root.format_c_name ((root as Root).extension_name, name), suffix[cpt],
                                                                                                         pos + 1, m_OwnerPos + 1);
                    }
                }
                else
                    ret += inPrefix + "[CCode (cname = \"xcb_%s%s\")]\n".printf (Root.format_c_name ((root as Root).extension_name, name), suffix[cpt]);

                string reply = "VoidCookie";
                if (m_Reply != null)
                    reply = "%sCookie".printf (Root.format_vala_name (name));

                bool first = true;
                if (m_Owner != null)
                {
                    ret += inPrefix + "public %s %s%s (Connection connection".printf (reply, format_function_name (), suffix[cpt]);
                    first = false;
                }
                else
                {
                    ret += inPrefix + "public %s %s%s (".printf (reply, format_function_name (), suffix[cpt]);
                    first = true;
                }
                foreach (unowned XmlObject child in childs_unsorted)
                {
                    if (!(child is Reply))
                    {
                        if (child.pos != m_OwnerPos)
                        {
                            string str;

                            if (!first)
                                str = child.to_string (", ");
                            else
                                str = child.to_string ("");

                            if (str.length > 0)
                            {
                                ret += str;
                                first = false;
                            }
                        }
                    }
                }
                ret += ");\n";
            }

            return ret;
        }
    }
}
