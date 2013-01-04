/* method.vala
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

namespace XCBValaCodegen
{
    public class Method : XCBVala.Request, Member
    {
        // accessors
        public Visibility visibility { get; construct set; default = Visibility.PUBLIC; }

        public bool is_constructor {
            get {
                string f = function_name;
                return f == "create";
            }
        }

        public bool is_destructor {
            get {
                string f = function_name;
                return f == "destroy" || f == "free";
            }
        }

        // methods
        private string
        generate_constructor (string inPrefix)
        {
            string ret = "%s%s %s (Xcb.Connection inConnection".printf (inPrefix, visibility.to_string (),
                                                                        XCBVala.Root.format_vala_name (parent.name));
            foreach (unowned XCBVala.XmlObject child in childs_unsorted)
            {
                if (!(child is XCBVala.Reply))
                {
                    if (child.pos != owner_pos)
                    {
                        string str = child.to_string (", ");
                        if (str.length > 0)
                        {
                            ret += str;
                        }
                    }
                }
            }
            ret += ")\n";
            ret += inPrefix + "{\n";
            ret += inPrefix + "\tGLib.Oject (connection: inConnection, xid: Xcb.%s (inConnection));\n".printf (XCBVala.Root.format_vala_name (parent.name));
            ret += "\n";
            ret += inPrefix + "\t" + generate_call ();
            ret += inPrefix + "}\n";

            return ret;
        }

        private string
        generate_destructor (string inPrefix)
        {
            string ret = "%s~%s ()\n".printf (inPrefix, XCBVala.Root.format_vala_name (parent.name));
            ret += inPrefix + "{\n";
            ret += inPrefix + "\t" + generate_call ();
            ret += inPrefix + "}\n";

            return ret;
        }

        public string
        generate_call ()
        {
            string ret = "xid.%s (connection".printf (function_name);

            foreach (unowned XCBVala.XmlObject child in childs_unsorted)
            {
                if (!(child is XCBVala.Reply))
                {
                    if (child.pos != owner_pos)
                    {
                        if (child is Field && !(child as Field).is_ref)
                        {
                            ret += ", %s".printf ((child as Field).generate_call ());
                        }
                        else if (child is XCBVala.ValueParam)
                        {
                            bool found = false;
                            GLib.List<unowned XCBVala.Field> fields = find_childs_of_type<XCBVala.Field> ();

                            foreach (unowned XCBVala.Field field in fields)
                            {
                                if (field.name == (child as XCBVala.ValueParam).value_mask_name)
                                {
                                    found = true;
                                    break;
                                }
                            }
                            if (!found)
                            {
                                ret += ", %s".printf ((child as XCBVala.ValueParam).value_mask_name);
                            }

                            ret += ", %s".printf ((child as XCBVala.ValueParam).value_list_name);
                        }
                    }
                }
            }
            ret += ");\n";

            return ret;
        }

        public string
        generate_declaration (string inPrefix)
        {
            string ret = "";

            if (is_constructor)
                return generate_constructor (inPrefix);

            if (is_destructor)
                return generate_destructor (inPrefix);

            if (reply == null)
            {
                ret += inPrefix + "%s void\n%s%s (".printf (visibility.to_string (), inPrefix, function_name);

                bool first = true;
                foreach (unowned XCBVala.XmlObject child in childs_unsorted)
                {
                    if (!(child is XCBVala.Reply))
                    {
                        if (child.pos != owner_pos)
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
                ret += ")\n";
                ret += inPrefix + "{\n";
                ret += inPrefix + "\t%s".printf (generate_call ());
                ret += inPrefix + "}\n";
            }

            return ret;
        }

        public int
        compare (Method inOther)
        {
            if (is_constructor && !inOther.is_constructor)
                return -1;
            else if (!is_constructor && inOther.is_constructor)
                return 1;
            else if (is_destructor && !inOther.is_destructor)
                return -1;
            else if (!is_destructor && inOther.is_destructor)
                return 1;

            return 0;
        }
    }
}
