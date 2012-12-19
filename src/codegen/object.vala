/* object.vala
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
    public interface Object : GLib.Object, XCBVala.XmlObject
    {
        // types
        public enum Visibility
        {
            PRIVATE,
            PROTECTED,
            PUBLIC,
            INTERNAL;

            public string
            to_string ()
            {
                switch (this)
                {
                    case PRIVATE:
                        return "private";
                    case PROTECTED:
                        return "protected";
                    case PUBLIC:
                        return "public";
                    case INTERNAL:
                        return "internal";
                }

                return "";
            }
        }

        [Flags]
        public enum AccessorFlags
        {
            GET       = 1 << 0,
            SET       = 1 << 1,
            CONSTRUCT = 1 << 2,
            DEFAULT   = 1 << 3;

            public string
            to_string (string? inDefault = null)
            {
                string ret = " { ";
                if ((this & GET) == GET)
                    ret += "get; ";

                if (((this & CONSTRUCT) == CONSTRUCT) && ((this & SET) == SET))
                    ret += "construct set; ";
                else if (((this & CONSTRUCT) == CONSTRUCT) && ((this & SET) != SET))
                    ret += "construct; ";
                else if (((this & CONSTRUCT) != CONSTRUCT) && ((this & SET) == SET))
                    ret += "set; ";

                if (((this & DEFAULT) == DEFAULT) && inDefault != null)
                    ret += "default = %s; ".printf (inDefault);

                ret += "}";

                return ret == " { }" ? ";" : ret;
            }
        }

        // methods
        private string
        header ()
        {
            return "/*\n" +
                   " * Copyright (C) 2012  Nicolas Bruguier\n" +
                   " *\n" +
                   " * This library is free software: you can redistribute it and/or modify\n" +
                   " * it under the terms of the GNU Lesser General Public License as published by\n" +
                   " * the Free Software Foundation, either version 3 of the License, or\n" +
                   " * (at your option) any later version.\n" +
                   " *\n" +
                   " * This library is distributed in the hope that it will be useful,\n" +
                   " * but WITHOUT ANY WARRANTY; without even the implied warranty of\n" +
                   " * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n" +
                   " * GNU Lesser General Public License for more details.\n" +
                   " *\n" +
                   " * You should have received a copy of the GNU Lesser General Public License\n" +
                   " * along with this library.  If not, see <http://www.gnu.org/licenses/>.\n" +
                   " *\n" +
                   " * Author:\n" +
                   " *  Nicolas Bruguier <gandalfn@club-internet.fr>\n" +
                   " */\n\n";
        }

        private string
        accessor (Visibility inVisibility, string inTypeName, string inName, AccessorFlags inFlags, string? inDefault)
        {
            return "%s Xcb.%s %s%s\n".printf (inVisibility.to_string (), XCBVala.Root.format_vala_name (inTypeName),
                                              inName, inFlags.to_string (inDefault));
        }

        private string
        constructor ()
        {
            string ret = "";

            GLib.List<unowned XCBValaCodegen.Method> methods = find_childs_of_type<XCBValaCodegen.Method> ();
            foreach (unowned XCBValaCodegen.Method method in methods)
            {
                if (method.function_name == "create")
                {
                    ret += "\tpublic %s (Xcb.Connection inConnection".printf (XCBVala.Root.format_vala_name (name));
                    foreach (unowned XCBVala.XmlObject child in method.childs_unsorted)
                    {
                        if (!(child is XCBVala.Reply))
                        {
                            if (child.pos != method.owner_pos)
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
                    ret += "\t{\n";
                    ret += "\t\tGLib.Oject (connection: inConnection, xid: Xcb.%s (inConnection));\n".printf (XCBVala.Root.format_vala_name (name));
                    ret += "\n";
                    ret += "\t\t" + method.generate_call ();

                    ret += "\t}\n";

                    break;
                }
            }


            return ret;
        }

        public string
        generate ()
        {
            string ret = header ();

            string derived_type;

            if (this is XCBVala.XIDType)
                derived_type = XCBVala.ValueType.get_derived ((this as XCBVala.XIDType).base_type);
            else
                derived_type = XCBVala.ValueType.get_derived ((this as XCBVala.XIDUnion).base_type);
            ret += "public class Xcb.Vala.%s : %s\n".printf (XCBVala.Root.format_vala_name (name), derived_type != null ? derived_type : "GLib.Object");
            ret += "{\n";
            ret += "\t// accessors\n";
            ret += "\t" + accessor (Visibility.PUBLIC, "Connection", "connection",
                                    AccessorFlags.GET | AccessorFlags.CONSTRUCT | AccessorFlags.DEFAULT, "null");
            ret += "\t" + accessor (Visibility.PUBLIC, name, "xid",
                                    AccessorFlags.GET | AccessorFlags.CONSTRUCT | AccessorFlags.DEFAULT, "0");
            ret += "\n";
            ret += "\t// methods\n";
            ret += constructor ();
            ret += "}";

            return ret;
        }
    }
}
