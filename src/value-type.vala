/* type.vala
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
    public class ValueType : GLib.Object
    {
        // static properties
        private static Set<ValueType> s_Types = null;

        // properties
        private string m_Name;
        private string m_Val;

        // static methods
        public static void
        add (string inName, string inVal)
        {
            ValueType val = new ValueType (inName, inVal);
            message ("Insert %s %s", inName, inVal);
            s_Types.insert (val);
        }

        public static new string?
        @get (string inName)
        {
            unowned ValueType? val = s_Types.search<string> (inName, (o, v) => {
                return o.m_Name.ascii_casecmp (v);
            });

            message ("Search %s %s", inName, val != null ? val.m_Val : "not found");

            return val != null ? val.m_Val : null;
        }

        // methods
        static construct
        {
            s_Types = new Set<ValueType> (ValueType.compare);
        }

        private ValueType (string inName, string inVal)
        {
            m_Name = inName;
            m_Val = inVal;
        }

        private int
        compare (ValueType inType)
        {
            return m_Name.ascii_casecmp (inType.m_Name);
        }
    }
}
