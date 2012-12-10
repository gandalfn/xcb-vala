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

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            foreach (unowned XmlObject item in this)
            {
                if (item is FieldRef && parent != null)
                {
                    foreach (unowned XmlObject child in parent)
                    {
                        if ((child is Field) && item.characters == child.name)
                        {
                            (child as Field).is_ref = true;
                            field_ref = item.characters;
                            if (parent is Request)
                            {
                                m_ArrayLenPos = child.pos;
                            }
                            break;
                        }
                    }
                }
            }
        }

        public string
        to_string (string inPrefix)
        {
            string ret = "";
            if (attrtype != null && ValueType.get (attrtype) != null)
            {
                if (field_ref != null)
                {
                    if (parent is Request)
                    {
                        if (m_ArrayLenPos >= 0)
                        {
                            int pos = m_ArrayLenPos + 1;
                            if ((parent as Request).owner_pos <= m_ArrayLenPos)
                                pos = int.max (m_ArrayLenPos, 1);
                            ret += inPrefix +  "[CCode (array_length_pos = %i.%i)]".printf (pos, m_ArrayLenPos + 1);
                        }

                        ret += "%s[] %s".printf (ValueType.get (attrtype), name);
                    }
                    else
                    {
                        ret += inPrefix + "[CCode (array_length_cname = \"%s\")]\n".printf (field_ref);
                        ret += inPrefix + "public %s[] %s;\n".printf (ValueType.get (attrtype), name);
                    }
                }
                else if (childs.length == 1)
                {
                    if (parent is Request)
                    {
                        ret += inPrefix + "%s %s".printf (ValueType.get (attrtype), name);
                        foreach (unowned XmlObject child in childs_unsorted)
                        {
                            if (child is ValueItem)
                                ret += "[%i]".printf (int.parse (child.characters));
                        }
                    }
                    else
                    {
                        ret += inPrefix + "public %s %s".printf (ValueType.get (attrtype), name);
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
                    if (parent is Request)
                    {
                        ret += inPrefix + "[CCode (array_length_pos = %i.%i)]".printf (pos, pos);
                        ret += "%s[] %s".printf (ValueType.get (attrtype), name);
                    }
                    else
                    {
                        ret += inPrefix + "[CCode (array_length = false)]\n";
                        ret += inPrefix + "public %s[] %s;\n".printf (ValueType.get (attrtype), name);
                    }
                }
            }
            else
                warning ("Type %s of %s not found", attrtype, name);

            return ret;
        }
    }
}
