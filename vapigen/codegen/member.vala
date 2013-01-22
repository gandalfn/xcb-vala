/* member.vala
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
    // types
    public enum Visibility
    {
        PRIVATE,
        PROTECTED,
        PUBLIC,
        INTERNAL;

        public string
        to_string ()
        {
            switch (this)
            {
                case PRIVATE:
                    return "private";
                case PROTECTED:
                    return "protected";
                case PUBLIC:
                    return "public";
                case INTERNAL:
                    return "internal";
            }

            return "";
        }
    }

    public interface Member : GLib.Object
    {
        // accessors
        public abstract Visibility visibility { get; construct set; default = Visibility.PUBLIC; }
    }
}
