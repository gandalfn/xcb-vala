/* argument.vala
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
    public interface Argument : GLib.Object, XCBVala.XmlObject
    {
        public string
        generate_call ()
        {
            string ret = "";

            if (this is Field)
            {
                if ((this as Field).attrtype != null && XCBVala.ValueType.get ((this as Field).attrtype) != null)
                {
                    if (XCBVala.ValueType.is_xid_type ((this as Field).attrtype))
                        return "%s.xid".printf (name);
                    else
                        return "%s".printf (name);
                }
            }

            return ret;
        }

        public string
        generate_declaration ()
        {
            string ret = "";

            if (this is Field)
            {
                if ((this as Field).attrtype != null && XCBVala.ValueType.get ((this as Field).attrtype) != null)
                {
                    return "%s %s".printf (XCBVala.ValueType.get ((this as Field).attrtype), name);
                }
            }

            return ret;
        }
    }
}
