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
        // properties
        private GLib.HashTable<int?, string> m_Items;

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
            m_Items = new GLib.HashTable<int?, string> (GLib.int_hash, GLib.int_equal);

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
                            bool end = false;
                            for (int cpt = 0; !end && s[cpt] != 0; ++cpt)
                            {
                                char c = s [cpt];
                                if (c == ':')
                                {
                                    GLib.StringBuilder name = new GLib.StringBuilder("");
                                    bool begin = false;
                                    for (int i = cpt + 1; !end && s[i] != 0; ++i)
                                    {
                                        if (s[i] == ' ')
                                        {
                                            if (!begin)
                                            {
                                                begin = true;
                                                continue;
                                            }
                                            else
                                            {
                                                m_Items.insert (num, format_name (name.str));
                                                end = true;
                                            }
                                        }
                                        else
                                        {
                                            name.append_unichar (s[i]);
                                        }
                                    }
                                }
                            }
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
                GLib.List<unowned int?> keys = m_Items.get_keys ();
                keys.reverse ();
                foreach (int num in keys)
                {
                    if (is_first)
                        ret += "\t%s".printf (m_Items[num]);
                    else
                        ret += ",\n\t%s".printf (m_Items[num]);
                    is_first = false;
                }
                ret += ";\n\n";
                ret += "`\tpublic void\n\tfrom_xerror (int inCode) throws Error\n";
                ret += "\t{\n";
                ret += "\t\tswitch (inCode)\n";
                ret += "\t\t{\n";
                foreach (int num in keys)
                {
                    ret += "\t\t\tcase %i:\n".printf (num);
                    ret += "\t\t\t\tthrow new Error.%s (\"\");\n".printf (m_Items[num]);
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
