/* accessor.vala
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
    public class Accessor : GLib.Object, Member
    {
        // types
        [Flags]
        public enum Flags
        {
            GET       = 1 << 0,
            SET       = 1 << 1,
            CONSTRUCT = 1 << 2,
            DEFAULT   = 1 << 3;

            public string
            to_string (string? inDefault = null)
            {
                string ret = "{ ";
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

                return ret == "{ }" ? ";" : ret;
            }
        }

        // accessors
        public Visibility visibility    { get; construct set; default = Visibility.PUBLIC; }
        public string     type_name     { get; construct set; default = ""; }
        public string     name          { get; construct set; default = null; }
        public Flags      flags         { get; construct set; default = 0; }
        public string     default_value { get; construct set; default = null; }

        // methods
        public Accessor (Visibility inVisibility, string inType, string inName, Flags inFlags, string? inDefaultValue = null)
        {
            GLib.Object (visibility: inVisibility, type_name: inType, name: inName, flags: inFlags, default_value: inDefaultValue);
        }

        public string
        generate ()
        {
            return "%s %s %s %s\n".printf (visibility.to_string (), type_name, name, flags.to_string (default_value));
        }

        public int
        compare (Accessor inAccessor)
        {
            return GLib.strcmp (name, inAccessor.name);
        }
    }
}
