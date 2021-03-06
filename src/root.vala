/* root.vala
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
    public class Root : GLib.Object, XmlObject
    {
        // properties
        private Set<XmlObject>       m_Childs;
        private Connection           m_Connection = null;
        private GLib.List<XmlObject> m_Imports = new GLib.List<XmlObject> ();

        // accessors
        protected string tag_name {
            get {
                return "xcb";
            }
        }

        protected unowned XmlObject? parent { get; set; default = null; }

        protected unowned Set<XmlObject>? childs {
            get {
                return m_Childs;
            }
        }

        public string name            { get; set; default = null; }
        public int    pos             { get; set; default = 0; }
        public string characters      { get; set; default = null; }

        public string path            { get; set; default = null; }
        public string header          { get; set; default = null; }
        public string extension_name  { get; set; default = null; }
        public string extension_xname { get; set; default = null; }

        public string[] deps {
            owned get {
                string[] depends = {};

                foreach (unowned XmlObject import in m_Imports)
                {
                    if ((import as Root).extension_name != null)
                        depends += "xcb-%s".printf ((import as Root).extension_name.down ());
                    else
                        depends += "xcb";

                }

                return depends;
            }
        }

        // static methods
        public static string
        format_vala_name (string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            int is_first = 1;
            bool prev_is_lower = false;

            if (inName.has_prefix ("GC"))
            {
                is_first = 2;
            }
            else if (inName.has_prefix ("XF"))
            {
                is_first = 2;
            }
            else if (inName.has_prefix ("XI"))
            {
                is_first = 3;
            }

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (is_first > 0)
                {
                    ret.append_unichar (c.toupper ());
                    is_first--;
                }
                else if (!prev_is_lower)
                    ret.append_unichar (c.tolower());
                else
                    ret.append_unichar (c);

                prev_is_lower = is_first <= 0 && c.islower ();
            }

            return ret.str;
        }

        public static string
        format_vala_enum_name (string inName, out bool outIsNumeric)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;
            bool previous_is_underscore = false;
            outIsNumeric = true;

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (!c.isdigit () && outIsNumeric) outIsNumeric = false;
                if (c.isupper() || c.isdigit ())
                {
                    if (!previous_is_upper && !previous_is_underscore)
                        ret.append_unichar ('_');
                    else if (cpt != 0 && previous_is_upper && s[cpt + 1] != 0 && s[cpt + 1].islower ())
                        ret.append_unichar ('_');
                    ret.append_unichar (c.toupper());
                    previous_is_upper = true;
                }
                else
                {
                    ret.append_unichar (c.toupper());
                    previous_is_upper = false;
                }
                previous_is_underscore = c == '_';
            }

            if (outIsNumeric)
            {
                switch (int.parse (ret.str))
                {
                    case 1:
                        return "ONE";
                    case 2:
                        return "TWO";
                    case 3:
                        return "THREE";
                    case 4:
                        return "FOUR";
                    case 5:
                        return "FIVE";
                    case 6:
                        return "SIX";
                    case 7:
                        return "SEVEN";
                    case 8:
                        return "HEIGHT";
                    case 9:
                        return "NINE";
                    default:
                        return "E%i".printf (int.parse (ret.str));
                }
            }

            return ret.str;
        }

        public static string
        format_c_extension_name (string inExtensionName)
        {
            if (inExtensionName.down () == "randr")
                return "randr";
            if (inExtensionName.down () == "xfixes")
                return "xfixes";
            if (inExtensionName.down () == "xvmc")
                return "xvmc";
            if (inExtensionName.down () == "screensaver")
                return "screensaver";

            return format_c_name (null, inExtensionName);
        }

        public static string
        format_c_field_name (string inFieldName)
        {
            if (inFieldName.down () == "class")
                return "_class";
            if (inFieldName.down () == "delete")
                return "_delete";

            return inFieldName;
        }

        public static string
        format_c_name (string? inExtensionName, string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;
            bool previous_is_underscore = false;

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                char c2 = s [cpt + 1];
                if (c.isupper() || c.isdigit ())
                {
                    if (!previous_is_underscore && (!previous_is_upper || (cpt > 0 && c2.islower ())))
                        ret.append_unichar ('_');
                    ret.append_unichar (c.tolower());
                    previous_is_upper = true;
                }
                else
                {
                    ret.append_unichar (c);
                    previous_is_upper = false;
                }
                previous_is_underscore = c == '_';
            }

            return inExtensionName != null && inExtensionName != "proto" ? format_c_extension_name (inExtensionName) + "_" + ret.str : ret.str;
        }

        public static string
        format_c_enum_name (string? inExtensionName, string inName)
        {
            string extension_name = null;
            if (inExtensionName != null)
            {
                if (inExtensionName.down () == "randr")
                    extension_name = "randr";
                else if (inExtensionName.down () == "xfixes")
                    extension_name = "xfixes";
                else if (inExtensionName.down () == "xvmc")
                    extension_name = "xvmc";
                else if (inExtensionName.down () == "screensaver")
                    extension_name = "screensaver";
                else
                    extension_name = inExtensionName;
            }

            string name = inName;
            if (inName.down () == "dpmsmode")
                name = "DpmsMode";

            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;

            unowned char[] s = (char[])name;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (c.isupper() || c.isdigit ())
                {
                    if (!previous_is_upper) ret.append_unichar ('_');
                    ret.append_unichar (c.toupper());
                    previous_is_upper = true;
                }
                else
                {
                    ret.append_unichar (c.toupper());
                    previous_is_upper = false;
                }
            }

            return extension_name != null && extension_name != "proto" ? format_c_enum_name (null, extension_name) + "_" + ret.str : ret.str;
        }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);

            ValueType.add_simple ("INT8",   "int8",   extension_name);
            ValueType.add_simple ("INT16",  "int16",  extension_name);
            ValueType.add_simple ("INT32",  "int32",  extension_name);
            ValueType.add_simple ("CARD8",  "uint8",  extension_name);
            ValueType.add_simple ("CARD16", "uint16", extension_name);
            ValueType.add_simple ("CARD32", "uint32", extension_name);
            ValueType.add_simple ("CARD64", "uint64", extension_name);
            ValueType.add_simple ("BYTE",   "uint8",  extension_name);
            ValueType.add_simple ("BOOL",   "bool",   extension_name);
            ValueType.add_simple ("char",   "char",   extension_name);
            ValueType.add_simple ("float",  "float",  extension_name);
            ValueType.add_simple ("double", "double", extension_name);
            ValueType.add_simple ("void",   "void",   extension_name);
        }

        private void
        update_imports ()
        {
            if (path != null)
            {
                GLib.List<unowned Import> imports = find_childs_of_type<unowned Import> ();
                foreach (unowned Import import in imports)
                {
                    string filename = path + "/" + import.characters + ".xml";
                    if (GLib.FileUtils.test (filename, GLib.FileTest.EXISTS))
                    {
                        try
                        {
                            XmlParser parser = new XmlParser (filename);
                            XmlObject import_root = parser.parse ("xcb");

                            m_Imports.append (import_root);
                        }
                        catch (GLib.Error e)
                        {
                            warning ("%s", e.message);
                        }
                    }
                }
            }
        }

        private void
        update_field_types ()
        {
            GLib.List<unowned Field> fields = find_childs_of_type<unowned Field> ();
            GLib.List<unowned Enum> enums = find_childs_of_type<unowned Enum> ();

            foreach (unowned Field field in fields)
            {
                if (field.mask != null)
                {
                    foreach (unowned Enum @enum in enums)
                    {
                        if (@enum.name == field.mask)
                        {
                            @enum.is_mask = true;
                            field.attrtype = @enum.name;
                            break;
                        }
                    }
                }
                else if (field.@enum != null)
                {
                    foreach (unowned Enum @enum in enums)
                    {
                        if (@enum.name == field.@enum)
                        {
                            field.attrtype = @enum.name;
                            break;
                        }
                    }
                }
            }
        }

        private void
        update_events ()
        {
            GLib.List<unowned EventCopy> event_copys = find_childs_of_type<unowned EventCopy> ();
            GLib.List<unowned Event> events = find_childs_of_type<unowned Event> ();
            foreach (unowned EventCopy event_copy in event_copys)
            {
                if (event_copy.@ref != null)
                {
                    foreach (unowned Event event in events)
                    {
                        if (event.event_name == event_copy.@ref)
                        {
                            Event copy = event.copy (event_copy.name, event_copy.number);
                            remove_child (event_copy);
                            append_child (copy);
                            break;
                        }
                    }
                }
            }

            GLib.List<unowned Enum> enums = find_childs_of_type<unowned Enum> ();
            bool have_event_enum = false;
            foreach (unowned Enum @enum in enums)
            {
                if (@enum.name == "Event" && @enum.have_type_suffix)
                {
                    have_event_enum = true;
                    break;
                }
            }
            if (!have_event_enum)
            {
                events = find_childs_of_type<unowned Event> ();
                if (events.length () > 0)
                {
                    events.sort (Event.compare_number);

                    Enum event_enum = new Enum ();
                    event_enum.name = "EventType";
                    append_child (event_enum);

                    foreach (unowned Event event in events)
                    {
                        Item item = new Item ();
                        item.name = event.event_name;

                        event_enum.append_child (item);
                    }
                }
            }
        }

        private void
        update_errors ()
        {
            GLib.List<unowned ErrorCopy> error_copys = find_childs_of_type<unowned ErrorCopy> (false);
            GLib.List<unowned Error> errors = find_childs_of_type<unowned Error> (false);
            foreach (unowned ErrorCopy error_copy in error_copys)
            {
                if (error_copy.@ref != null)
                {
                    foreach (unowned Error error in errors)
                    {
                        if (error.name == error_copy.@ref)
                        {
                            Error copy = error.copy (error_copy.name, error_copy.number);
                            remove_child (error_copy);
                            append_child (copy);
                            break;
                        }
                    }
                }
            }
        }

        public void
        update_requests ()
        {
            GLib.List<unowned Request> requests = find_childs_of_type<unowned Request> (false);
            foreach (unowned Request request in requests)
            {
                if (request.owner != null || request.search_owner (this))
                {
                    request.owner.reparent (request);
                }
                else
                {
                    foreach (unowned XmlObject import in m_Imports)
                    {
                        if (request.search_owner (import))
                        {
                            unowned XmlObject? found = childs.search<string> (request.owner.name, XmlObject.compare_with_name);

                            if (found == null)
                            {
                                if (request.owner is XIDType)
                                {
                                    XIDType type = (request.owner as XIDType).copy (import as Root);
                                    append_child (type);
                                    type.on_end ();
                                    type.pos = -100;
                                }
                                else if (request.owner is XIDUnion)
                                {
                                    XIDType type = (request.owner as XIDUnion).copy (import as Root);
                                    append_child (type);
                                    type.on_end ();
                                    type.pos = -100;
                                }
                            }
                            request.search_owner (this);
                            request.owner.reparent (request);
                            break;
                        }
                    }

                    if (request.owner == null)
                    {
                        if (m_Connection == null)
                        {
                            m_Connection = new Connection ();
                            append_child (m_Connection);
                            m_Connection.pos = -100;
                        }
                        m_Connection.reparent (request);
                    }
                }
            }
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            update_imports ();

            update_errors ();

            update_field_types ();

            update_events ();

            update_requests ();
        }

        public string
        to_string (string inPrefix)
        {
            string ret = inPrefix + "/*\n" +
                          inPrefix + " * Copyright (C) 2012-2014  Nicolas Bruguier\n" +
                          inPrefix + " * All Rights Reserved.\n" +
                          inPrefix + " *\n" +
                          inPrefix + " * Permission is hereby granted, free of charge, to any person obtaining a\n" +
                          inPrefix + " * copy of this software and associated documentation files (the \"Software\"),\n" +
                          inPrefix + " * to deal in the Software without restriction, including without limitation\n" +
                          inPrefix + " * the rights to use, copy, modify, merge, publish, distribute, sublicense,\n" +
                          inPrefix + " * and/or sell copies of the Software, and to permit persons to whom the\n" +
                          inPrefix + " * Software is furnished to do so, subject to the following conditions:\n" +
                          inPrefix + " *\n" +
                          inPrefix + " * The above copyright notice and this permission notice shall be included in\n" +
                          inPrefix + " * all copies or substantial portions of the Software.\n" +
                          inPrefix + " *\n" +
                          inPrefix + " * THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n" +
                          inPrefix + " * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n" +
                          inPrefix + " * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n" +
                          inPrefix + " * AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN\n" +
                          inPrefix + " * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN\n" +
                          inPrefix + " * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n" +
                          inPrefix + " *\n" +
                          inPrefix + " * Except as contained in this notice, the names of the authors or their\n" +
                          inPrefix + " * institutions shall not be used in advertising or otherwise to promote the\n" +
                          inPrefix + " * sale, use or other dealings in this Software without prior written\n" +
                          inPrefix + " * authorization from the authors.\n" +
                          inPrefix + " */\n\n";

            ret += inPrefix + "using Xcb;\n";
            GLib.List<unowned Import> imports = find_childs_of_type<unowned Import> ();
            foreach (unowned Import import in imports)
            {
                ret += inPrefix + import.to_string (inPrefix);
            }
            ret += "\n";

            if (header != null)
                ret += inPrefix + "[CCode (cheader_filename=\"xcb/xcb.h,xcb/%s.h\")]\n".printf (header);

            if (extension_name != null)
            {
                if (extension_name == "GenericEvent")
                    ret += inPrefix + "namespace Xcb.GE\n";
                else
                    ret += inPrefix + "namespace Xcb.%s\n".printf (extension_name);
            }
            else
                ret += inPrefix + "namespace Xcb\n";

            ret += inPrefix + "{\n";

            if (extension_name != null)
            {
                ret += "\t[CCode (cname = \"xcb_%s_id\")]\n".printf (Root.format_c_extension_name (extension_name));
                ret += "\tpublic Xcb.Extension extension;\n\n";
            }

            bool nl = false;
            foreach (unowned XmlObject child in childs_unsorted)
            {
                if (!(child is Import))
                {
                    if (nl) ret += "\n";
                    string str = child.to_string (inPrefix + "\t");
                    nl = str.length != 0;
                    ret += str;
                }
            }
            ret += inPrefix + "}\n";

            return ret;
        }
    }
}
