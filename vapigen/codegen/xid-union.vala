/* xid-union.vala
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
    public class XIDUnion : XCBVala.XIDUnion, Member, Object
    {
        // accessors
        public Visibility visibility { get; construct set; default = Visibility.PUBLIC; }
        public XCBVala.Set<Accessor> accessors { get; set; default = new XCBVala.Set<Accessor> (Accessor.compare); }

        // methods
        public override string
        to_string (string inPrefix)
        {
            register ();

            return generate ();
        }
    }
}
