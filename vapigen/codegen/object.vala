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
    public interface Object : GLib.Object, XCBVala.XmlObject, Member
    {
        // accessors
        public abstract XCBVala.Set<Accessor> accessors { get; set; default = new XCBVala.Set<Accessor> (Accessor.compare); }

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

        protected void
        register ()
        {
            accessors.insert (new Accessor (Visibility.PUBLIC, "Xcb.Connection", "connection", Accessor.Flags.GET | Accessor.Flags.CONSTRUCT | Accessor.Flags.DEFAULT, "null"));
            accessors.insert (new Accessor (Visibility.PUBLIC, "Xcb." + XCBVala.Root.format_vala_name (name), "xid", Accessor.Flags.GET | Accessor.Flags.CONSTRUCT | Accessor.Flags.DEFAULT, "0"));
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
            ret += "%s class Xcb.Vala.%s : %s\n".printf (visibility.to_string (), XCBVala.Root.format_vala_name (name), derived_type != null ? derived_type : "GLib.Object");
            ret += "{\n";
            if (accessors.length > 0)
            {
                ret += "\t// accessors\n";
                foreach (unowned Accessor accessor in accessors)
                {
                    ret += "\t" + accessor.generate ();
                }
            }
            GLib.List<unowned Method> methods = find_childs_of_type<Method> ();
            methods.sort (Method.compare);
            string m = "";
            if (methods.length () > 0)
            {
                m += "\t// methods";
                foreach (unowned Method method in methods)
                {
                    string str = method.generate_declaration("\t");
                    if (str != "")
                        m += "\n" + str;
                }
            }
            if (m != "\t// methods")
                ret += "\n" + m;
            ret += "}";

            return ret;
        }
    }
}
