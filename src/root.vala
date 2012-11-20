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
        private Set<XmlObject> m_Childs;

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

        public string header          { get; set; default = null; }
        public string extension_name  { get; set; default = null; }
        public string extension_xname { get; set; default = null; }

        // static methods
        public static string
        format_vala_name (string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool is_first = true;
            bool prev_is_lower = false;

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (is_first)
                {
                    ret.append_unichar (c.toupper ());
                    is_first = false;
                }
                else if (!prev_is_lower)
                    ret.append_unichar (c.tolower());
                else
                    ret.append_unichar (c);

                prev_is_lower = !is_first && c.islower ();
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
        format_c_name (string? inExtensionName, string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (c.isupper() || c.isdigit ())
                {
                    if (!previous_is_upper) ret.append_unichar ('_');
                    ret.append_unichar (c.tolower());
                    previous_is_upper = true;
                }
                else
                {
                    ret.append_unichar (c);
                    previous_is_upper = false;
                }
            }

            return inExtensionName != null ? format_c_name (null, inExtensionName) + "_" + ret.str : ret.str;
        }

        public static string
        format_c_enum_name (string? inExtensionName, string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;

            unowned char[] s = (char[])inName;
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

            return inExtensionName != null ? format_c_enum_name (null, inExtensionName) + "_" + ret.str : ret.str;
        }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);

            ValueType.add ("INT8", "int8");
            ValueType.add ("INT16", "int16");
            ValueType.add ("INT32", "int32");
            ValueType.add ("CARD8", "uint8");
            ValueType.add ("CARD16", "uint16");
            ValueType.add ("CARD32", "uint32");
            ValueType.add ("BYTE", "uint8");
            ValueType.add ("BOOL", "bool");
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
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

            GLib.List<unowned EventCopy> event_copys = find_childs_of_type<unowned EventCopy> ();
            GLib.List<unowned Event> events = find_childs_of_type<unowned Event> ();
            foreach (unowned EventCopy event_copy in event_copys)
            {
                if (event_copy.@ref != null)
                {
                    foreach (unowned Event event in events)
                    {
                        if (event.name == event_copy.@ref)
                        {
                            Event copy = event.copy (event_copy.name, event_copy.number);
                            remove_child (event_copy);
                            append_child (copy);
                            break;
                        }
                    }
                }
            }

            events = find_childs_of_type<unowned Event> ();
            events.sort (Event.compare_number);

            Enum event_enum = new Enum ();
            event_enum.name = "EventType";
            append_child (event_enum);

            foreach (unowned Event event in events)
            {
                Item item = new Item ();
                item.name = event.name;

                event_enum.append_child (item);
            }
        }

        public string
        to_string (string inPrefix)
        {
            string ret = "";

            if (header != null)
                ret += inPrefix + "[CCode (cheader_filename=\"xcb/%s.h\")]\n".printf (header);

            if (extension_name != null)
                ret += inPrefix + "namespace Xcb.%s\n".printf (extension_name);
            else
                ret += inPrefix + "namespace Xcb\n";

            ret += inPrefix + "{\n";

            foreach (unowned XmlObject child in childs_unsorted)
            {
                ret += child.to_string (inPrefix + "\t");
                ret += "\n";
            }
            ret += inPrefix + "}\n";

            return ret;
        }
    }
}
