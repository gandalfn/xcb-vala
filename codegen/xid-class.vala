/* xid-class.vala
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

namespace XCBVala.Codegen
{
    public interface XidClass : GLib.Object, XmlObject
    {
        // accessors
        public string class_name {
            owned get {
               return Parser.format_vala_name (name);
            }
        }

        // methods
        protected void
        add_creation_method ()
        {
            // Add creation method
            var cm = new Vala.CreationMethod (class_name, null, Parser.get_source (), null);
            cm.access = Vala.SymbolAccessibility.PUBLIC;
            var connection_symbol = new Vala.UnresolvedSymbol (null, "Connection");
            var param = new Vala.Parameter ("connection", new Vala.UnresolvedType.from_symbol (connection_symbol), Parser.get_source ());
            cm.add_parameter (param);
            Parser.add_symbol (cm);

            // Add object chainup call
            cm.body = new Vala.Block (Parser.get_source ());
            var object_call = new Vala.MethodCall (new Vala.BaseAccess (Parser.get_source ()), Parser.get_source ());
            object_call.add_argument (new Vala.MemberAccess.simple ("connection", Parser.get_source ()));
            var stmt = new Vala.ExpressionStatement (object_call, Parser.get_source ());
            cm.body.insert_statement (0, stmt);
        }

        protected void
        add_class_declaration ()
        {
            // Add class
            var cl = new Vala.Class (class_name, Parser.get_source ());
            Parser.add_symbol (cl);
            var xid_symbol = new Vala.UnresolvedSymbol (new Vala.UnresolvedSymbol (null, "Core"), "Xid");
            cl.add_base_type (new Vala.UnresolvedType.from_symbol (xid_symbol));
            cl.access = Vala.SymbolAccessibility.PUBLIC;
            Parser.push (cl);

            add_creation_method ();
        }
    }
}
