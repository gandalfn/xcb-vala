/* doc.vala
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
    public class Doc : GLib.Object, XmlObject
    {
        // static properties
        private static ulong s_Count = 0;

        // properties
        private Set<XmlObject>       m_Childs;
        private unowned Brief?       m_Brief = null;
        private unowned Description? m_Description = null;

        // accessors
        protected string tag_name {
            get {
                return "doc";
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
            s_Count++;
            name = "doc-%lu".printf (s_Count);
        }

        public void
        on_child_added (XmlObject inChild)
        {
            if (inChild is Brief)
                m_Brief = inChild as Brief;
            else if (inChild is Description)
                m_Description = inChild as Description;
        }

        public void
        on_end ()
        {
        }

        public string
        field_to_string (string inName, string inPrefix)
        {
            string ret = inPrefix + "/**\n";

            unowned XmlObject? found = childs.search<string> (inName, XmlObject.compare_with_name);
            if (found is Field)
            {
                if (found.characters != null)
                {
                    foreach (string line in found.characters_unformatted.split ("\n"))
                    {
                        string l = line.strip ();
                        if (l.length > 0)
                        {
                            ret += inPrefix + " * " + l + "\n";
                        }
                    }
                }
            }

            if (ret == inPrefix + "/**\n")
            {
                ret = "";
            }
            else
            {
                ret += inPrefix + " */\n";
            }

            return ret;
        }

        public string
        to_string (string inPrefix)
        {
            string ret = inPrefix + "/**\n";

            if (m_Brief != null && m_Brief.characters_unformatted.length > 0)
            {
                foreach (string line in m_Brief.characters_unformatted.split ("\n"))
                {
                    ret += inPrefix + " * " + line + "\n";
                }
            }

            if (m_Description != null && m_Description.characters_unformatted.length > 0)
            {
                foreach (string line in m_Description.characters_unformatted.split ("\n"))
                {
                    ret += inPrefix + " * " + line.strip () + "\n";
                }
            }

            if (parent is Request)
            {
                if ((parent as Request).owner != null)
                {
                    ret += inPrefix + " * @param connection The connection.\n";
                }

                foreach (unowned XmlObject? child in parent.childs_unsorted)
                {
                    if ((child is Field && !(child as Field).is_ref && (child as Field).pos != (parent as Request).owner_pos) ||
                        (child is List))
                    {
                        unowned XmlObject? found = childs.search<string> (child.name, XmlObject.compare_with_name);
                        if (found is Field)
                        {
                            string begin = "@param %s ".printf (found.name);
                            string pad = string.nfill (begin.length, ' ');

                            ret += inPrefix + " * " + begin;
                            if (found.characters != null)
                            {
                                bool is_first = true;
                                foreach (string line in found.characters_unformatted.split ("\n"))
                                {
                                    string l = line.strip ();
                                    if (l.length > 0)
                                    {
                                        if (is_first)
                                            ret += l + "\n";
                                        else
                                            ret += inPrefix + " * " + pad + l + "\n";
                                        is_first = false;
                                    }
                                }
                                if (is_first)
                                {
                                    ret += "%s\n".printf (found.name);
                                }
                            }
                            else
                            {
                                ret += "%s\n".printf (found.name);
                            }
                        }
                    }
                }
            }

            bool is_first = true;
            foreach (unowned XmlObject? child in childs_unsorted)
            {
                if (child is See)
                {
                    if (is_first) ret += inPrefix + " *\n";
                    ret += child.to_string (inPrefix);
                    is_first = false;
                }
            }

            if (ret == inPrefix + "/**\n")
            {
                ret = "";
            }
            else
            {
                ret += inPrefix + " */\n";
            }

            return ret;
        }
    }
}