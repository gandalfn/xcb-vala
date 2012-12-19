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

namespace XCBValaCodegen
{
    // methods
    public class Root : XCBVala.Root
    {
        public void
        generate (string inPath)
        {
            foreach (unowned XCBVala.XmlObject child in childs_unsorted)
            {
                if (child is Object)
                {
                    try
                    {
                        string filename = "%s/%s.vala".printf (inPath, child.name.down ());

                        GLib.FileUtils.set_contents (filename, child.to_string (""));
                    }
                    catch (GLib.Error e)
                    {
                        warning ("%s", e.message);
                    }
                }
            }
        }
    }
}
