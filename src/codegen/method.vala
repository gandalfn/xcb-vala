/* method.vala
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
    public class Method : XCBVala.Request
    {
        public string
        generate_call ()
        {
            string ret = "xid.%s (connection".printf (function_name);

            foreach (unowned XCBVala.XmlObject child in childs_unsorted)
            {
                if (!(child is XCBVala.Reply))
                {
                    if (child.pos != owner_pos)
                    {
                        if (child is XCBVala.Field && !(child as XCBVala.Field).is_ref)
                        {
                            ret += ", %s".printf (child.name);
                        }
                        else if (child is XCBVala.ValueParam)
                        {
                            bool found = false;
                            GLib.List<unowned XCBVala.Field> fields = find_childs_of_type<XCBVala.Field> ();

                            foreach (unowned XCBVala.Field field in fields)
                            {
                                if (field.name == (child as XCBVala.ValueParam).value_mask_name)
                                {
                                    found = true;
                                    break;
                                }
                            }
                            if (!found)
                            {
                                ret += ", %s".printf ((child as XCBVala.ValueParam).value_mask_name);
                            }

                            ret += ", %s".printf ((child as XCBVala.ValueParam).value_list_name);
                        }
                    }
                }
            }
            ret += ");\n";

            return ret;
        }
    }
}
