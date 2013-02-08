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

namespace XCBVala.Codegen
{
    public class Root : GLib.Object, XmlObject
    {
        // properties
        private Vala.Symbol    m_Symbol;
        private Set<XmlObject> m_Childs;

        // accessors
        protected string tag_name {
            get {
                return "xcb";
            }
        }

        protected unowned XmlObject? parent { get; set; default = null; }

        protected unowned Set<XmlObject>? childs {
            get {
                return m_Childs;
            }
        }

        public string name            { get; set; default = null; }
        public int    pos             { get; set; default = 0; }
        public string characters      { get; set; default = null; }

        public string path            { get; set; default = null; }
        public string header          { get; set; default = null; }
        public string extension_name  { get; set; default = null; }
        public string extension_xname { get; set; default = null; }

        public Vala.Symbol symbol {
            get {
                return m_Symbol;
            }
        }

        // methods
        construct
        {
            m_Childs = new Set<XmlObject> (XmlObject.compare);
        }

        private void
        add_connection ()
        {
            var cl = new Vala.Class ("Connection", Parser.get_source ());
            var gobject_symbol = new Vala.UnresolvedSymbol (new Vala.UnresolvedSymbol (null, "Core"), "Connection");
            cl.add_base_type (new Vala.UnresolvedType.from_symbol (gobject_symbol));
            cl.access = Vala.SymbolAccessibility.PUBLIC;

            Parser.add_symbol (cl);
            Parser.push (cl);

            // Add creation method
            var cm = new Vala.CreationMethod ("Connection", null, Parser.get_source (), null);
            cm.access = Vala.SymbolAccessibility.PUBLIC;
            var param_type = new Vala.UnresolvedType.from_symbol (new Vala.UnresolvedSymbol (null, "string"));
            param_type.nullable = true;
            var param = new Vala.Parameter ("display", param_type, Parser.get_source ());
            cm.add_parameter (param);
            var error_type = new Vala.UnresolvedType.from_symbol (new Vala.UnresolvedSymbol (new Vala.UnresolvedSymbol (null, "Core"), "ConnectionError"));
            cm.add_error_type (error_type);
            Parser.add_symbol (cm);

            // Add object chainup call
            cm.body = new Vala.Block (Parser.get_source ());
            var object_call = new Vala.MethodCall (new Vala.BaseAccess (Parser.get_source ()), Parser.get_source ());
            object_call.add_argument (new Vala.MemberAccess.simple ("display", Parser.get_source ()));
            var stmt = new Vala.ExpressionStatement (object_call, Parser.get_source ());
            cm.body.insert_statement (0, stmt);

            Parser.pop ();
        }

        public void
        on_created ()
        {
            // Add extension namespace
            if (extension_name != null)
            {
                message ("Add namespace %s", extension_name);
                var ns = new Vala.Namespace (extension_name, Parser.get_source ());
                Parser.add_symbol (ns);
                Parser.push (ns);
            }

            m_Symbol = Parser.get ();

            // Add connection class
            add_connection ();
        }

        public void
        on_child_added (XmlObject inChild)
        {
        }

        public void
        on_end ()
        {
            if (extension_name != null)
            {
                Parser.pop ();
            }
        }

        public string
        to_string (string inPrefix)
        {
            return "";
        }

        public Vala.Symbol
        lookup_symbol (string inName)
        {
            return m_Symbol.scope.lookup(inName);
        }
    }
}
