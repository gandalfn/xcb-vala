/* value.vala
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
    internal interface Value
    {
        private static bool s_SimpleTypeRegistered = false;

        private static void
        register_simple_type ()
        {
            GLib.Value.register_transform_func (typeof (string), typeof (double),
                                                (ValueTransform)string_to_double);
            GLib.Value.register_transform_func (typeof (double), typeof (string),
                                                (ValueTransform)double_to_string);

            GLib.Value.register_transform_func (typeof (string), typeof (int),
                                                (ValueTransform)string_to_int);
            GLib.Value.register_transform_func (typeof (int), typeof (string),
                                                (ValueTransform)int_to_string);

            GLib.Value.register_transform_func (typeof (string), typeof (uint),
                                                (ValueTransform)string_to_uint);
            GLib.Value.register_transform_func (typeof (uint), typeof (string),
                                                (ValueTransform)uint_to_string);

            GLib.Value.register_transform_func (typeof (string), typeof (ulong),
                                                (ValueTransform)string_to_ulong);
            GLib.Value.register_transform_func (typeof (ulong), typeof (string),
                                                (ValueTransform)ulong_to_string);

            GLib.Value.register_transform_func (typeof (string), typeof (long),
                                                (ValueTransform)string_to_long);
            GLib.Value.register_transform_func (typeof (long), typeof (string),
                                                (ValueTransform)long_to_string);

            GLib.Value.register_transform_func (typeof (string), typeof (bool),
                                                (ValueTransform)string_to_bool);
            GLib.Value.register_transform_func (typeof (bool), typeof (string),
                                                (ValueTransform)bool_to_string);

            s_SimpleTypeRegistered = true;
        }

        private static void
        double_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (double)))
        {
            double val = (double)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_double (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = double.parse (val);
        }

        private static void
        int_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (int)))
        {
            int val = (int)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_int (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = int.parse (val);
        }

        private static void
        uint_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (uint)))
        {
            uint val = (uint)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_uint (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = (uint)int.parse (val);
        }

        private static void
        long_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (long)))
        {
            long val = (long)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_long (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = long.parse (val);
        }

        private static void
        ulong_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (ulong)))
        {
            ulong val = (ulong)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_ulong (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = (ulong)long.parse (val);
        }

        private static void
        bool_to_string (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (bool)))
        {
            bool val = (bool)inSrc;

            outDest = val.to_string ();
        }

        private static void
        string_to_bool (GLib.Value inSrc, out GLib.Value outDest)
            requires (inSrc.holds (typeof (string)))
            requires ((string)inSrc != null)
        {
            string val = (string)inSrc;

            outDest = bool.parse (val);
        }

        internal static GLib.Value
        from_string (GLib.Type inType, string inValue)
        {
            if (inType.is_classed ())
                inType.class_ref ();
            else if (!s_SimpleTypeRegistered)
                register_simple_type ();

            GLib.Value val = GLib.Value (inType);
            GLib.Value str = inValue;
            str.transform (ref val);

            return val;
        }
    }
}
