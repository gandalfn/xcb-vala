/* error.vala
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
    public class Error : XCBVala.Request
    {
        // types
        public struct Entry
        {
            public int    num;
            public string name;
            public string comment;

            public static int
            compare (Entry? inA, Entry? inB)
            {
                return inA.num - inB.num;
            }
        }

        // properties
        private XCBVala.Set<Entry?> m_Items;

        // static methods
        public static string
        format_name (string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (c.isupper())
                {
                    if (!previous_is_upper) ret.append_unichar ('_');
                    ret.append_unichar (c.toupper ());
                    previous_is_upper = true;
                }
                else
                {
                    ret.append_unichar (c.toupper ());
                    previous_is_upper = false;
                }
            }

            return ret.str;
        }

        // methods
        public Error (string inFilename)
        {
            m_Items = new XCBVala.Set<Entry?> (Entry.compare);

            try
            {
                GLib.MappedFile file = new GLib.MappedFile (inFilename, false);
                string[] lines = ((string)file.get_contents ()).split("\n");

                foreach (unowned string line in lines)
                {
                    if (line.has_prefix ("XProtoError."))
                    {
                        string cur = line.substring ("XProtoError.".length);
                        unowned char[] s = (char[])cur;
                        int num = int.parse (cur);
                        if (num > 0)
                        {
                            GLib.StringBuilder name = new GLib.StringBuilder("");
                            GLib.StringBuilder comment = new GLib.StringBuilder("");
                            for (int cpt = 0; s[cpt] != 0; ++cpt)
                            {
                                char c = s [cpt];
                                if (c == ':')
                                {
                                    bool begin = false;
                                    bool is_name = false;
                                    for (int i = cpt + 1; s[i] != 0; ++i)
                                    {
                                        if (s[i] == ' ' && !is_name)
                                        {
                                            if (!begin)
                                            {
                                                begin = true;
                                                continue;
                                            }
                                            else if (!is_name)
                                            {
                                                is_name = true;
                                                continue;
                                            }
                                        }
                                        else if (is_name)
                                        {
                                            if (s[i] != '(' && s[i] != ')')
                                                comment.append_unichar (s[i]);
                                        }
                                        else
                                        {
                                            name.append_unichar (s[i]);
                                        }
                                    }
                                }
                            }
                            m_Items.insert ({ num, format_name (name.str), comment.str });
                        }
                    }
                }
            }
            catch (GLib.Error err)
            {
                GLib.critical ("Error on parse %s: %s", inFilename, err.message);
            }
        }

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

        public void
        generate (string inPath)
        {
            try
            {
                string filename = "%s/error.vala".printf (inPath);

                string ret = header ();

                ret += "public errordomain Xcb.Vala.Error\n";
                ret += "{\n";
                bool is_first = true;
                foreach (unowned Entry? entry in m_Items)
                {
                    if (is_first)
                        ret += "\t%s".printf (entry.name);
                    else
                        ret += ",\n\t%s".printf (entry.name);
                    is_first = false;
                }
                ret += ";\n\n";
                ret += "`\tpublic void\n\tfrom_xerror (int inCode) throws Error\n";
                ret += "\t{\n";
                ret += "\t\tswitch (inCode)\n";
                ret += "\t\t{\n";
                foreach (unowned Entry? entry in m_Items)
                {
                    ret += "\t\t\tcase %i:\n".printf (entry.num);
                    ret += "\t\t\t\tthrow new Error.%s (\"%s\");\n".printf (entry.name, entry.comment);
                }
                ret += "\t\t}\n";
                ret += "\t\treturn;\n";
                ret += "\t}\n";
                ret += "}\n";

                GLib.FileUtils.set_contents (filename, ret);
            }
            catch (GLib.Error e)
            {
                warning ("%s", e.message);
            }
        }
    }
}
