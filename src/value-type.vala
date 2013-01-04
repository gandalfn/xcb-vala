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
        private string m_ExtensionName;
        private bool   m_IsXIDType;
        private bool   m_HaveIterator;

        // static methods
        public static void
        add (string inName, string inVal, string? inExtensionName, bool inIsXIDType, bool inHaveIterator = false)
        {
            ValueType val = new ValueType (inName, inVal, inExtensionName, inIsXIDType, inHaveIterator);
            s_Types.insert (val);
        }

        public static new string?
        @get (string inName)
        {
            string name;
            if (":" in inName)
            {
                name = inName.split (":")[1];
            }
            else
            {
                name = inName;
            }

            unowned ValueType? val = s_Types.search<string> (name, (o, v) => {
                return o.m_Name.ascii_casecmp (v);
            });

            if (val != null)
                return val.m_Val;

            return null;
        }

        public static string?
        get_derived (string inName)
        {
            unowned ValueType? val = s_Types.search<string> (inName, (o, v) => {
                return o.m_Name.ascii_casecmp (v);
            });

            if (val != null)
            {
                if (val.m_ExtensionName != null)
                {
                    if (val.m_ExtensionName == "proto")
                        return "Xcb." + val.m_Val;
                    else
                        return "Xcb." + Root.format_vala_name (val.m_ExtensionName) + "." + val.m_Val;
                }
                else
                    return val.m_Val;
            }

            return null;
        }

        public static bool
        is_xid_type (string inName)
        {
            unowned ValueType? val = s_Types.search<string> (inName, (o, v) => {
                return o.m_Name.ascii_casecmp (v);
            });

            if (val != null)
            {
                return val.m_IsXIDType;
            }

            return false;
        }

        public static bool
        have_iterator (string inName)
        {
            unowned ValueType? val = s_Types.search<string> (inName, (o, v) => {
                return o.m_Name.ascii_casecmp (v);
            });

            if (val != null)
            {
                return val.m_HaveIterator;
            }

            return false;
        }

        public static string?
        get_extension_name (string inName)
        {
            unowned ValueType? val = s_Types.search<string> (inName, (o, v) => {
                return o.m_Name.ascii_casecmp (v);
            });

            if (val != null)
            {
                return val.m_ExtensionName;
            }

            return null;
        }

        // methods
        static construct
        {
            s_Types = new Set<ValueType> (ValueType.compare);
        }

        private ValueType (string inName, string inVal, string? inExtensionName, bool inIsXIDType, bool inHaveIterator = false)
        {
            m_Name = inName;
            m_Val = inVal;
            m_ExtensionName = inExtensionName;
            m_IsXIDType = inIsXIDType;
            m_HaveIterator = inHaveIterator;
        }

        private int
        compare (ValueType inType)
        {
            return m_Name.ascii_casecmp (inType.m_Name);
        }
    }
}
